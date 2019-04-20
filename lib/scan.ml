(* look into these libraries for creating
 * custom packets to do more advanced port scans:
 *   - https://github.com/mirage/mirage-tcpip
 *   - https://github.com/frenetic-lang/ocaml-packet
 *   - https://mirage.io/blog/intro-tcpip
 *)

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
  | "tcp-connect" -> TCP_Connect
  | _ -> failwith "Invalid probe selected"
                   
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

let create_socket host port probe_type =
    let inet_address = Unix.Inet_addr.of_string_or_getbyname host in
    let socket_address = Unix.ADDR_INET (inet_address, port) in
    let socket = match probe_type with
      | TCP_Syn | TCP_Connect -> Unix.socket
                                   ~domain:Unix.PF_INET
                                   ~kind:Unix.SOCK_STREAM
                                   ~protocol:0
      | UDP -> Unix.socket
                 ~domain:Unix.PF_INET
                 ~kind:Unix.SOCK_DGRAM
                 ~protocol:(UnixLabels.getprotobyname "udp").p_proto
    in
    (socket, socket_address)
      
let connect ~probe_fn ~host ~port ~probe_type =  
  let socket, socket_address = create_socket host port probe_type in

  try
    Unix.connect socket ~addr:socket_address;
    probe_fn socket socket_address;
    Unix.shutdown socket ~mode:Unix.SHUTDOWN_ALL;
    Open;
  with
  | Unix.Unix_error (Unix.ECONNREFUSED, _, _) -> Closed
  | Unix.Unix_error (e, _, _) -> Error e
    
(* Use `_` prefix to supress unsued warnings since this is not implemented yet *)
let tcp_syn_probe _host _port = Open
                              
let tcp_connect_probe host port = 
  connect
    ~host:host
    ~port:port
    ~probe_type:TCP_Connect
    ~probe_fn:(fun _ _ -> ())

let udp_probe host port =
  connect
    ~host:host
    ~port:port
    ~probe_type:UDP
    ~probe_fn:(fun socket socket_address ->
      let msg = "\x00" in
        Unix.sendto
           socket
           ~buf:(Bytes.of_string msg)
           ~pos:0
           ~len:(String.length msg)
           ~mode:[]
           ~addr:socket_address
        |> ignore
      
    )

let probe_type_fn = function
  | TCP_Connect -> tcp_connect_probe
  | TCP_Syn -> tcp_syn_probe
  | UDP -> udp_probe

let initialize config =
  (* recursion would be nice, but it doesn't make sense to use here *)
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
