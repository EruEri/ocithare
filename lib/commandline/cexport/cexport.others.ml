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
  let () = ignore paste in
  let () = ignore regex in
  let () = print_endline password.Libcithare.Password.password in
  ()

let validate _export = ()
let term_website = CexportCommon.term_website
let term_regex = CexportCommon.term_regex
let term_output = CexportCommon.term_output
let term_display_time = CexportCommon.term_display_time
let term_show_password = CexportCommon.term_show_password

let term_cmd () =
  let combine website regex output =
    let export =
      new CexportCommon.export_t validate fpaste website regex false output
    in
    export#run
  in
  Term.(const combine $ term_website $ term_regex $ term_output)

let doc = CexportCommon.doc
let man = [ `S Manpage.s_description; `P "Export or display passwords" ]

let cmd () =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd ())

let command = cmd ()
