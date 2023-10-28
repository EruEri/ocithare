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

type t = { change_master_password : bool } [@@unboxed]

let term_change_master_password =
  Arg.(
    value & flag
    & info [ "change-master-password" ] ~doc:"Change the master password"
  )

let term_cmd run =
  let combine change_master_password = run { change_master_password } in
  Term.(const combine $ term_change_master_password)

let run _t = ()
let default = term_cmd run
let name = Libcithare.Config.cithare_name
let version = Libcithare.Config.version
let doc = "A command-line password manager"
let man = []
let info = Cmd.info ~doc ~version ~man name

let subcommands =
  Cmd.group ~default info
    [
      Cinit.command;
      Cadd.command;
      Cdelete.command;
      Cexport.command;
      Cshow.command;
      CgenPassword.command;
    ]

let eval () = Cmd.eval subcommands
