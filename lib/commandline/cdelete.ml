(**********************************************************************************************)
(*                                                                                            *)
(* This file is part of ocithare: a commandline password manager                              *)
(* Copyright (C) 2023 Yves Ndiaye                                                             *)
(*                                                                                            *)
(* ocithare is free software: you can redistribute it and/or modify it under the terms        *)
(* of the GNU General Public License as published by the Free Software Foundation,            *)
(* either version 3 of the License, or (at your option) any later version.                    *)
(*                                                                                            *)
(* ocithare is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;      *)
(* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           *)
(* PURPOSE.  See the GNU General Public License for more details.                             *)
(* You should have received a copy of the GNU General Public License along with ocithare.     *)
(* If not, see <http://www.gnu.org/licenses/>.                                                *)
(*                                                                                            *)
(**********************************************************************************************)

open Cmdliner

let name = "delete"

type t = { all : bool; website : string option }

let term_all =
  Arg.(value & flag & info [ "a"; "all" ] ~doc:"Delete all passwords")

let term_website =
  Arg.(
    value
    & opt (some string) None
    & info [ "w"; "website" ] ~docv:"WEBSITE"
        ~doc:"Delete passwords matching $(docv)"
  )

let term_cmd run =
  let combine all website = run { all; website } in
  Term.(const combine $ term_all $ term_website)

let doc = "Delete password from the password manager"
let man = []

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let validate t =
  let { all; website } = t in
  let () = Libcithare.Manager.check_initialized () in
  match website with
  | None when not all ->
      raise
      @@ Libcithare.Error.missing_expecting_when_absent [| "website" |]
           [| "all" |]
  | _ ->
      ()

let run t =
  let { all; website } = t in
  let () = validate t in
  let master_password = Libcithare.Input.ask_password_encrypted () in
  let manager = Libcithare.Manager.decrypt master_password in
  let base_len = Libcithare.Manager.length manager in
  let diff =
    match all with
    | true ->
        let module P = Libcithare.Input.Prompt in
        let delete =
          Libcithare.Input.validate_input ~default_message:P.delete_password
            ~error_message:P.wrong_choice ~empty_line_message:P.empty_choice
        in
        let () =
          match delete with
          | false ->
              raise @@ Libcithare.Error.delete_password_cancel
          | true ->
              ()
        in
        let manager = Libcithare.Manager.empty in
        let () = Libcithare.Manager.encrypt master_password manager in
        base_len
    | false ->
        let change, m =
          website
          |> Option.map (fun website ->
                 Libcithare.Manager.filter website manager
             )
          |> Option.value ~default:(0, manager)
        in
        (* Can use physical equal since filter returns physical manager if no diff*)
        let () =
          match m == manager with
          | true ->
              ()
          | false ->
              let () = Libcithare.Manager.encrypt master_password m in
              ()
        in
        change
  in
  let () =
    match diff with
    | 0 when Option.is_some website ->
        print_endline "No website matched"
    | 0 ->
        print_endline "No password deleted"
    | n ->
        let () = Libcithare.Manager.save_state master_password manager in
        Printf.printf "Passwords deleted = %u\n" n
  in
  ()

let command = cmd run
