open Core_kernel.Std
open Opium.Std
open Db

let print_hello s req =
  App.respond' (`String ("hello" ^ s))

let print_json req =
  App.string_of_body_exn req >>| fun s ->
  let json = try Ezjsonm.from_string s with
	     | _ -> Ezjsonm.from_string "{\"message\": \"Ill-formed json\"}" in
  respond (`Json json)
	    
let register req =
  App.string_of_body_exn req >>| fun s ->
  let json = try
      let dict = Ezjsonm.from_string s |> Ezjsonm.value |> Ezjsonm.get_dict in
      match List.Assoc.find_exn dict "username", List.Assoc.find_exn dict "password" with
      | `String username, `String password ->
	 let password = Digest.string password |> Digest.to_hex in
	 if is_registered username then
	   Ezjsonm.from_string "{\"status\": 0, \"message\": \"Already registered user\"}"
	 else let _ = insert username password 0 0 in Ezjsonm.from_string "{\"status\": 1, \"message\": \"Registered\"}"
      | _ -> Ezjsonm.from_string "{\"status\": 0, \"message\": \"Ill-formed json\"}"
    with
    | _ -> Ezjsonm.from_string "{\"status\": 0, \"message\": \"Ill-formed json\"}" in
  respond (`Json json)
  
let _ =
  App.empty
  |> post "/register" register
  |> post "/" print_json
  |> get "/" (print_hello " world")
  |> App.run_command
       
