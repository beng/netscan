open Unix
open Core
open ANSITerminal
   
let version = "0.0.1"
            
let print_banner =
  Printf.printf {|
********************************                 
   _  __    __  ____            
  / |/ /__ / /_/ __/______ ____ 
 /    / -_) __/\ \/ __/ _ `/ _ \
/_/|_/\__/\__/___/\__/\_,_/_//_/

        netscan (v%s)

********************************|} version;
  Out_channel.newline stdout


let parse_port_range port_range =
  let ports = String.split port_range ~on: '-' in
  let ps = List.map ports ~f: int_of_string in
  match ps with
  | [start_port] -> List.range start_port (start_port + 1)                  
  | start :: stop :: _ -> List.range start stop
  | [] -> []

let port_scan host ports =
  (* If i break List.iter ports out into its own thing outside of the port scan call, then it breaks
  because of what I suspect are scoping issues? *)
  ANSITerminal.printf [green] "[*] Executing TCP port scan against host: [%s]\n" host;
  
  (* List.iter  ~f:(Printf.printf "%d\n") ports;   *)
  (* Using List.iter results in everything getting printed to stdout AFTER the entire list
      has been operated on. Use a different approach if I want to see a printout after
     each iteration *)
  List.iter ports ~f:(fun port ->
      let inet_addr =
        try (gethostbyname host).h_addr_list.(0)
        with Not_found_s _ ->
          (* TODO: use Printf.eprintf to print to stderr *)
          Printf.printf "Error scanning host: [%s]. Invalid host provided\n" host;
          exit 2 in
      let sockaddr = ADDR_INET (inet_addr, port) in
      let sock = socket PF_INET SOCK_STREAM 0 in             
      try
        connect sock sockaddr;
        shutdown sock SHUTDOWN_ALL;      
        ANSITerminal.printf [blue] "[+] Port [%d] is open\n" port;
      with Unix_error (err, _, _) ->
        ANSITerminal.eprintf [red] "[-] Port [%d] is closed -> %s\n" port (error_message err);
        Unix.close sock;        
    )
