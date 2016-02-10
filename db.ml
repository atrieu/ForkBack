open Postgresql

(* username, password, problem, score *)
       
let connect () =
  let url = Sys.getenv "DATABASE_URL" in
  let (dbtype, user, password, host, port, dbname) =
    Scanf.sscanf url "%s@://%s@:%s@@%s@:%d/%s" (fun a b c d e f -> (a, b, c, d, e, f)) in
  new connection ~user ~password ~host ~port:(string_of_int port) ~dbname ~requiressl:"true" ()

let create_table_if_not_exists () =
  let c = connect () in
  let req = "CREATE TABLE IF NOT EXISTS my_table (
	     username varchar NOT NULL,
	     password varchar NOT NULL,
	     problem integer NOT NULL,
	     score integer NOT NULL
	     )" in
  ignore (c#exec req);
  c#finish
  
let scores n =  
  let c = connect () in
  let req = Printf.sprintf "SELECT username, score FROM my_table WHERE problem = %d ORDER BY score DESC;" n in
  let res = c#exec req in
  let scores = res#get_all in
  c#finish; scores

let is_registered username =
  let c = connect () in
  let req = Printf.sprintf "SELECT * FROM my_table where username = '%s';" username in
  let res = c#exec req in
  let is_registered = Array.length res#get_all > 0 in
  c#finish; is_registered
	      
let has_score user password problem =
  let c = connect () in
  let req = Printf.sprintf "SELECT * FROM my_table where username = '%s' AND password = '%s' AND problem = %d;" user password problem in
  let res = c#exec req in
  let has_score = Array.length res#get_all > 0 in
  c#finish; has_score

let insert user password problem score =
  let c = connect () in
  let req = Printf.sprintf "INSERT INTO my_table VALUES ('%s', '%s', %d, %d);" user password problem score in
  ignore (c#exec req);
  c#finish
 
let change_score username password problem score =
  let c = connect () in
  let req = Printf.sprintf "UPDATE my_table SET score = %d WHERE username = '%s' AND password = '%s' AND problem = %d;" score username password problem in
  ignore (c#exec req);
  c#finish
