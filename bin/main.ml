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
    in
    fun () ->

    Netscan.Config.print_banner;
    Netscan.Scan.initialize host min_port max_port;
  )
      
let () =
  Command.run ~version: Netscan.Config.version command

