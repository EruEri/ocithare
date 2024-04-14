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

let name = "show"

type t = {
  show_password : bool;
  display_time : int option;
  cithare_file : string option;
}

let term_display_time =
  Arg.(
    value
    & opt (some int) None
    & info [ "d"; "display-time" ] ~docv:"DURATION"
        ~doc:"Show password to stdout for $(docv)"
  )

let term_show_password =
  Arg.(value & flag & info [ "show-password" ] ~doc:"Show plain passwords")

let term_cithare_file =
  Arg.(
    value
    & pos 0 (some non_dir_file) None
    & info [] ~docv:"<CITHARE-CIPHER>" ~doc:"Use $(docv) instead"
  )

let term_cmd run =
  let combine show_password display_time cithare_file =
    run { show_password; display_time; cithare_file }
  in
  Term.(
    const combine $ term_show_password $ term_display_time $ term_cithare_file
  )

let doc = "Display passwords"

let man =
  [
    `S Manpage.s_description;
    `P doc;
    `P
      "$(mname)-show(1) shows password records in your terminal in a table \
       format and by default hides the password string unless \
       $(b,--show-password) option is provided";
    `P
      (Printf.sprintf
         "$(mname)-show(1) can take a file as parameter. If provided, \
          $(mname)-show(1) will read the content of this file instead of the \
          usual $(b,%s)"
         Libcithare.Config.password_file
      );
    `S Manpage.s_examples;
    `I
      ( "Read the content of older state of cithare state in \
         XDG_STATE_HOME/cithare",
        "$(iname) \"~/.local/state/cithare/cithare Bl0ti4nf 2024-01-01 \
         00-00-00\""
      );
  ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let run t =
  let { show_password; display_time; cithare_file } = t in
  let () =
    match cithare_file with
    | Some _ ->
        ()
    | None ->
        Libcithare.Manager.check_initialized ()
  in
  let master_password = Libcithare.Input.ask_password_encrypted () in
  let manager =
    Libcithare.Manager.decrypt ?where:cithare_file master_password
  in
  let () = Libcithare.Manager.display ~show_password ?display_time manager in
  ()

let command = cmd run
