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
  Core.Out_channel.newline stdout
