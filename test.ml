open Core_kernel.Std
open Opium.Std
open Db

let print_hello req =
  App.respond' (`String "hello")
       
let print_json req =
  App.json_of_body_exn req >>| fun json ->
  respond (`String ("Received response\n" ^ Ezjsonm.to_string json ^ "\n"))

let string_of_scores scores =
  scores.(0).(0)
  
let print_scores req =
  let scores = scores 0 in
  App.respond' (`String (string_of_scores scores))
  
let _ =
  try
    create_table_if_not_exists ();
    insert "abc" "lol" 0 0;
    App.empty
    |> post "/" print_json
    |> get "/" print_scores
    |> App.run_command
  with
  | _ -> App.empty
	 |> get "/" print_hello
	 |> App.run_command
