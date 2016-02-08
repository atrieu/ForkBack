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
    let req = "CREATE TABLE IF NOT EXISTS my_table (
	       user varchar NOT NULL,
	       password varchar NOT NULL,
	       problem integer NOT NULL,
	       score integer NOT NULL
	     )" in
    let res = c#exec req in
    App.empty
      |> post "/" print_json
      |> get "/" (print_hello res#error)
      |> App.run_command
  with
  | _ -> App.empty
	 |> post "/" print_json
	 |> get "/" (print_hello " people")
	 |> App.run_command
