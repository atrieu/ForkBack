open Postgresql

(* user, password, problem, score *)
       
let connect () =
  let url = Sys.getenv "DATABASE_URL" in
  let (dbtype, user, password, host, port, dbname) =
    Scanf.sscanf url "%s@://%s@:%s@@%s@:%d/%s" (fun a b c d e f -> (a, b, c, d, e, f)) in
  new connection ~user ~password ~host ~port:(string_of_int port) ~dbname ~requiressl:"true" ()

let create_table_if_not_exists () =
  let c = connect () in
  let req = "CREATE TABLE IF NOT EXISTS table (
	     user varchar NOT NULL,
	     password varchar NOT NULL,
	     problem integer NOT NULL,
	     score integer NOT NULL
	     )" in
  ignore (c#exec req);
  c#finish
  
let scores n =  
  let c = connect () in
  let req = Printf.sprintf "SELECT user, score FROM table WHERE problem = %d ORDER BY score;" n in
  let res = c#exec req in
  let scores = res#get_all in
  c#finish; scores

let has_score user password =
  let c = connect () in
  let req = Printf.sprintf "SELECT * FROM table where user = '%s' AND password = '%s';" user password in
  let res = c#exec req in
  let has_score = Array.length res#get_all > 0 in
  c#finish; has_score

let insert user password problem score =
  let c = connect () in
  let req = Printf.sprintf "INSERT INTO table VALUES ('%s', '%s', %d, %d);" user password problem score in
  ignore (c#exec req);
  c#finish
 
