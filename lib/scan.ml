open Unix
   
let port_scan host =
  Printf.printf "Scanning host: [%s]\n" host;
  let inet_addr =
    try (gethostbyname host).h_addr_list.(0)
    with Not_found ->
      (* TODO: use Printf.eprintf to print to stderr *)
      Printf.printf "Error scanning host: [%s]. Invalid host provided\n" host;
      exit 2
  in
  let sockaddr = ADDR_INET (inet_addr, 8000) in
  let sock = socket PF_INET SOCK_STREAM 0 in
  connect sock sockaddr;
  match fork () with
  | 0 ->
     print_endline "Connection has been closed";
     shutdown sock SHUTDOWN_SEND;
     exit 0
  | _ ->
     print_endline "Not too sure...";
     
      
 
