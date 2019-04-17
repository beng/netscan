open Core

type probe_type =
  | TCP_Connect
  | TCP_Syn
  | UDP
  
type scan_config = {
    host: string;
    min_port: int;
    max_port: int;
    probe_type: probe_type;
  }
                 
type port_status =
  | Open
  | Closed
  | Error of Unix.Error.t

type scan_result = {
    host: string;
    port: int;
    status: port_status;
  }

let probe_type_of_string = function
  | "tcp-syn" -> TCP_Syn
  | "udp" -> UDP
  | "tcp-connect" | _ -> TCP_Connect
           
let string_of_port_status = function
  | Open -> "open"
  | Closed -> "closed"
  | Error e -> Printf.sprintf "%s" (Unix.Error.message e)

let scan_result_line_color = function
  | Open -> ANSITerminal.green
  | Closed | Error _ -> ANSITerminal.red

let print_scan_result result =
  let color = scan_result_line_color result.status in
  ANSITerminal.printf [color] "[+] Port [%d] is [%s]\n"
    result.port (string_of_port_status result.status)

let tcp_connect_probe host port =
  let inet_address = Unix.Inet_addr.of_string_or_getbyname host in
  let socket_address = Unix.ADDR_INET (inet_address, port) in
  let socket = Unix.socket ~domain:Unix.PF_INET ~kind:Unix.SOCK_STREAM ~protocol:0 in
  try
    Unix.connect socket ~addr:socket_address;
    Unix.shutdown socket ~mode:Unix.SHUTDOWN_ALL;
    Open;
  with
  | Unix.Unix_error (Unix.ECONNREFUSED, _, _) -> Closed
  | Unix.Unix_error (e, _, _) -> Error e

(* Use _ prefix to supress unsued warnings since this is not implemented yet *)
let tcp_syn_probe _host _port = Open

(* Use _ prefix to supress unsued warnings since this is not implemented yet *)
let udp_probe _host _port = Open 
              
let probe_type_fn = function
  | TCP_Connect -> tcp_connect_probe
  | TCP_Syn -> tcp_syn_probe
  | UDP -> udp_probe

let initialize config =
  (* recursion would be nice, but does it make sense to use here? *)
  let probe_fn = probe_type_fn config.probe_type in
  for port = config.min_port to config.max_port do
    let status = probe_fn config.host port in
    {
      host = config.host;
      port = port;
      status = status;
    }
    |> print_scan_result
  done
