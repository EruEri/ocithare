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

let fpaste ~regex ~paste password =
  match paste with
  | false ->
      let () = print_endline password.Libcithare.Password.password in
      ()
  | true ->
      let code =
        Sys.command
        @@ Printf.sprintf "echo \'%s\' | xclip -i -selection clipboard"
             password.password
      in
      let () =
        match code with
        | 0 ->
            let () =
              if regex then
                Printf.printf "For : %s\n" password.website
            in
            Printf.printf "Password successfully written in pasteboard\n"
        | _ ->
            raise @@ Libcithare.Error.set_pastboard_content_error
      in
      ()

let validate _export =
  let () = Libcithare.Manager.check_initialized () in
  ()

let term_xclip =
  Arg.(
    value & flag
    & info [ "x" ]
        ~doc:
          "Write the password into the clipboard X selection by invoking \
           $(b,xclip(1))"
  )

let term_website = CexportCommon.term_website
let term_regex = CexportCommon.term_regex
let term_output = CexportCommon.term_output
let term_display_time = CexportCommon.term_display_time
let term_show_password = CexportCommon.term_show_password

let term_cmd () =
  let combine website regex paste output =
    let export =
      new CexportCommon.export_t validate fpaste website regex paste output
    in
    export#run ()
  in
  Term.(const combine $ term_website $ term_regex $ term_xclip $ term_output)

let doc = CexportCommon.doc
let man = [ `S Manpage.s_description; `P "Export passwords" ]

let cmd () =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd ())

let command = cmd ()
