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

let name = CexportCommon.name

type t = CexportCommon.export_t

let validate t =
  let () = Libcithare.Manager.check_initialized () in
  let () =
    match (t#website, t#paste) with
    | None, true ->
        raise
        @@ Libcithare.Error.missing_expecting_when_present [| "website" |]
             [| "paste" |]
    | _ ->
        ()
  in
  ()

let fpaste ?mail ?username ~regex ~paste password =
  match paste with
  | false ->
      let () = print_endline password.Libcithare.Password.password in
      ()
  | true ->
      let () =
        match Macos.set_pastboard_content password.password with
        | false ->
            raise @@ Libcithare.Error.set_pastboard_content_error
        | true ->
            let () =
              if regex then
                Printf.printf "For : %s\n" password.website
              else
                ()
            in
            let () =
              if Option.is_some mail then
                Printf.printf "For : %s\n"
                @@ Option.value ~default:String.empty password.mail
            in
            let () =
              if Option.is_some username then
                Printf.printf "For : %s\n"
                @@ Option.value ~default:String.empty password.username
            in

            let () =
              Printf.printf "Password successfully written in pasteboard\n"
            in
            ()
      in

      ()

let term_paste =
  Arg.(
    value & flag
    & info [ "p"; "paste" ] ~doc:"Write the password into the pasteboard"
  )

let term_cmd = CexportCommon.term_cmd ~term_paste validate fpaste
let doc = CexportCommon.doc
let man = CexportCommon.man

let cmd () =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info term_cmd

let command = cmd ()
