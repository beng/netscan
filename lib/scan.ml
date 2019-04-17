open Core

type port_status = | Open
                   | Closed
                   | Error of Unix.Error.t

type scan_result = {
    host: string;
    port: int;
    status: port_status;
  }

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

let probe host port =
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

let initialize host min_port max_port =
  (* recursion would be nice, but does it make sense to use here? *)
  for port = min_port to max_port do
    let status = probe host port in
    {
      host = host;
      port = port;
      status = status;
    }
    |> print_scan_result
  done
