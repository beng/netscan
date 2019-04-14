open Core
   
(*
TODO:
- allow for a range of ports like nmap
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
                   ~doc: "Host to scan"
    in
    fun () -> Netscan.Scan.port_scan host
  )
      
let () =
  Command.run ~version: "0.0.1" command

