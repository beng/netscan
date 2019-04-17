open Core
      
let command =
  Command.basic
    ~summary: "Simple port scanner project to learn about OCaml"
    ~readme: (fun () -> "Scan a host to find out what ports are open")
    Command.Let_syntax.(
    let%map_open
          host = flag "--host" (required string)
                   ~doc: "Host to scan, eg: `127.0.0.1` or `localhost`"
    and min_port = flag "--min-port" (required int)
                     ~doc: "Port to start scan"
    and max_port = flag "--max-port" (required int)
                     ~doc: "Port to end scan"
    and probe_type = flag "--probe-type" (required string)
                       ~doc: "Type of scan to initiate (tcp-connect, tcp-syn, udp)"
    in
    fun () ->
    Netscan.Config.print_banner;
    let config = {
        Netscan.Scan.host = host;
        min_port = min_port;
        max_port = max_port;
        probe_type = Netscan.Scan.probe_type_of_string probe_type;
      }
    in
    Netscan.Scan.initialize config
  )
      
let () =
  Command.run ~version: Netscan.Config.version command

