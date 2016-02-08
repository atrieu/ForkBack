open Core_kernel.Std
open Opium.Std
open Db

let print_hello s req =
  App.respond' (`String ("hello" ^ s))
       
let print_json req =
  try
    App.json_of_body_exn req >>| fun json ->
    respond (`String ("Received response\n" ^ Ezjsonm.to_string json ^ "\n"))
  with
  | _ -> let json = Ezjsonm.from_string "{\"message\": \"Ill-formed json\"}" in
	   respond' (`Json json)
	    
(*let string_of_scores scores =
  scores.(0).(0)
  
let print_scores req =
  let scores = scores 0 in
  App.respond' (`String (string_of_scores scores))*)
  
let _ =
  try
    let c = connect () in
    c#finish;
    App.empty
    |> post "/" print_json
    |> get "/" (print_hello " world")
    |> App.run_command
  with
  | _ -> App.empty
	 |> post "/" print_json
	 |> get "/" (print_hello " people")
	 |> App.run_command
