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
  website : string option;
  regex : bool;
  paste : bool;
  output : string option;
  display_time : int option;
  show_passord : bool;
}

let term_website = CshowCommon.term_website
let term_regex = CshowCommon.term_regex

let term_paste =
  Arg.(
    value & flag
    & info [ "p"; "paste" ] ~doc:"Write the password into the pasteboard"
  )

let term_output = CshowCommon.term_output
let term_display_time = CshowCommon.term_display_time
let term_show_password = CshowCommon.term_show_password

let term_cmd run =
  let combine website regex paste output display_time show_passord =
    run { website; regex; paste; output; display_time; show_passord }
  in
  Term.(
    const combine $ term_website $ term_regex $ term_paste $ term_output
    $ term_display_time $ term_show_password
  )

let doc = CshowCommon.doc
let man = [ `S Manpage.s_description; `P "Export or display passwords" ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let run _t = ()
let command = cmd run
