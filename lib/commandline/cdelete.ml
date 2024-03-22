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

type t = {
  all : bool;
  website : string option;
  username : string option;
  mail : string option;
}

let term_all =
  Arg.(value & flag & info [ "a"; "all" ] ~doc:"Delete all passwords")

let term_website =
  Arg.(
    value
    & opt (some string) None
    & info [ "w"; "website" ] ~docv:"<WEBSITE>"
        ~doc:"Delete passwords matching $(docv)"
  )

let term_username =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "n"; "name"; "username" ]
        ~docv:"<NAME>" ~doc:"Delete password by also matching $(docv)"
  )

let term_mail =
  Arg.(
    value
    & opt (some string) None
    & info [ "m"; "mail" ] ~docv:"<MAIL>"
        ~doc:"Delete password by also matching $(docv)"
  )

let term_cmd run =
  let combine all website username mail =
    run { all; website; username; mail }
  in
  Term.(const combine $ term_all $ term_website $ term_username $ term_mail)

let doc = "Delete passwords to $(mname)"
let man = [ `S Manpage.s_description; `P doc ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let validate t =
  let { all; website; username = _; mail = _ } = t in
  let () = Libcithare.Manager.check_initialized () in
  match website with
  | None when not all ->
      raise
      @@ Libcithare.Error.missing_expecting_when_absent [| "-website" |]
           [| "-all" |]
  | _ ->
      ()

let validate_delete ~default_message ~error_message ~empty_line_message =
  let module P = Libcithare.Input.Prompt in
  let delete =
    Libcithare.Input.validate_input ~default_message ~error_message
      ~empty_line_message
  in
  match delete with
  | false ->
      raise @@ Libcithare.Error.delete_password_cancel
  | true ->
      ()

let run t =
  let { all; website; username; mail } = t in
  let () = validate t in
  let master_password = Libcithare.Input.ask_password_encrypted () in
  let manager = Libcithare.Manager.decrypt master_password in
  let base_len = Libcithare.Manager.count manager in
  let diff =
    match all with
    | true ->
        let module P = Libcithare.Input.Prompt in
        let () =
          validate_delete ~default_message:P.delete_password
            ~error_message:P.wrong_choice ~empty_line_message:P.empty_choice
        in
        let manager = Libcithare.Manager.empty in
        let () = Libcithare.Manager.encrypt master_password manager in
        base_len
    | false ->
        let manager_deleted =
          Option.value ~default:manager
          @@ Option.map
               (fun website ->
                 Libcithare.Manager.matches ~negate:true ?mail ?username
                   ~regex:false website manager
               )
               website
        in
        (* Can use physical equal since filter returns physical manager if no diff*)
        let change =
          match manager_deleted == manager with
          | true ->
              0
          | false ->
              let changes =
                Libcithare.Manager.(count manager - count manager_deleted)
              in
              let changes =
                match changes with
                | changes when changes <= 1 ->
                    changes
                | changes ->
                    let module P = Libcithare.Input.Prompt in
                    let deleted =
                      Libcithare.Manager.elements
                      @@ Libcithare.Manager.diff manager manager_deleted
                    in
                    let message_fmt =
                      List.map Libcithare.Manager.error_format deleted
                    in
                    let () =
                      validate_delete
                        ~default_message:(P.delete_password_list message_fmt)
                        ~error_message:P.wrong_choice
                        ~empty_line_message:P.empty_choice
                    in
                    changes
              in
              let () =
                Libcithare.Manager.encrypt master_password manager_deleted
              in
              changes
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
