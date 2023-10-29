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

type t = { show_password : bool; display_time : int option }

let term_display_time =
  Arg.(
    value
    & opt (some int) None
    & info [ "d"; "display-time" ] ~docv:"DURATION"
        ~doc:"Show password to stdout for $(docv)"
  )

let term_show_password =
  Arg.(value & flag & info [ "show-password" ] ~doc:"Show plain passwords")

let term_cmd run =
  let combine show_password display_time =
    run { show_password; display_time }
  in
  Term.(const combine $ term_show_password $ term_display_time)

let doc = "Display passwords"
let man = []

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let run t =
  let { show_password; display_time } = t in
  let () = Libcithare.Manager.check_initialized () in
  let master_password = Libcithare.Input.ask_password_encrypted () in
  let manager = Libcithare.Manager.decrypt master_password in
  let () = Libcithare.Manager.display ~show_password ?display_time manager in
  ()

let command = cmd run
