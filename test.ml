open Core_kernel.Std
open Opium.Std

let print_json req =
  App.json_of_body_exn req >>| fun json ->
  respond (`String ("Received response\n" ^ Ezjsonm.to_string json ^ "\n"))

let _ =
  App.empty
  |> post "/" print_json
  |> put "/" print_json
  |> App.run_command
