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

let term_website = Arg.(value & opt (some string) None & info [ "w"; "website" ])

let term_cmd run =
  let combine all website = run { all; website } in
  Term.(const combine $ term_all $ term_website)

let doc = "Delete password from the password manager"
let man = []

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let run _t = ()
let command = cmd run
