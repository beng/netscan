open Core
      
(*
TODO:
- allow for list of hosts and use concurrency for simulatenous scan
 *)

let host_param = Command.Param.(anon ("host to scan" %: string))

let command =
  Command.basic
    ~summary: "Simple port scanner project to learn about OCaml"
    ~readme: (fun () -> "Scan a host to find out what ports are open")
    Command.Let_syntax.(
    let%map_open
          host = flag "--host" (required string)
                   ~doc: "Host to scan, eg: `127.0.0.1` or `localhost`"
    and port_range = flag "--port-range" (required string)
             ~doc: "Port range to scan denoted by `-`, eg: `22-8000`"
    in
    fun () ->
    Netscan.Scan.print_banner;
    let ports = Netscan.Scan.parse_port_range port_range in
    Netscan.Scan.port_scan host ports
  )
      
let () =
  Command.run ~version: Netscan.Scan.version command

