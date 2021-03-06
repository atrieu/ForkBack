open Core_kernel.Std
open Opium.Std
open Db
open Scoring

let add_cors_headers (headers: Cohttp.Header.t): Cohttp.Header.t =
  Cohttp.Header.add_list headers [
    ("access-control-allow-origin", "*");
    ("access-control-allow-headers", "Accept, Content-Type");
    ("access-control-allow-methods", "GET, HEAD, POST, DELETE, OPTIONS, PUT, PATCH")
  ]

let allow_cors =
  let filter handler req =
    handler req >>| fun response -> 
    response 
    |> Response.headers
    |> add_cors_headers
    |> Field.fset Response.Fields.headers response
  in 
    Rock.Middleware.create ~name:(Info.of_string "allow cors") ~filter
       
let print_json req =
  App.string_of_body_exn req >>| fun s ->
  let json = try Ezjsonm.from_string s with
	     | _ -> Ezjsonm.from_string "{\"message\": \"Ill-formed json\"}" in
  respond (`Json json)

let print_scores n req =
  let scores = scores n in
  let s = Array.foldi ~f:(fun n acc a -> acc ^ (string_of_int (n + 1)) ^ ". " ^ a.(0) ^ " " ^ a.(1) ^ "\\n") ~init:"" scores in
  let json = Ezjsonm.from_string (Printf.sprintf "{\"status\": 1, \"message\": \"%s\"}" s) in
  respond' (`Json json)
	  
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

let submit req =
  App.string_of_body_exn req >>| fun s ->
  let json = try
      let dict = Ezjsonm.from_string s |> Ezjsonm.value |> Ezjsonm.get_dict in
      match List.Assoc.find_exn dict "username", List.Assoc.find_exn dict "password", List.Assoc.find_exn dict "data" with
      | `String username, `String password, `String data ->
	 let password = Digest.string password |> Digest.to_hex in
	 if is_registered username then
	   if has_score username password 0 then
	     let score = score data in
	     let _ = change_score username password 0 score in
	     Ezjsonm.from_string (Printf.sprintf "{\"status\": 1, \"message\": \"Your score is %d.\"}" score)
	   else Ezjsonm.from_string "{\"status\": 0, \"message\": \"Wrong password\"}"
	 else Ezjsonm.from_string "{\"status\": 0, \"message\": \"Unregistered user, please register first\"}"
      | _ -> Ezjsonm.from_string "{\"status\": 0, \"message\": \"Ill-formed json\"}"
    with
    | _ -> Ezjsonm.from_string "{\"status\": 0, \"message\": \"Ill-formed json\"}" in
  respond (`Json json)
      
let _ =
  let _ = create_table_if_not_exists () in
  App.empty
  |> middleware allow_cors
  |> post "/register" register
  |> post "/submit" submit
  |> post "/" print_json
  |> get "/" (print_scores 0)
  |> App.run_command
       
