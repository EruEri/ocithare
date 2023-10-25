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

let name = "add"

type t = {
  replace : bool;
  website : string;
  username : string option;
  mail : string option;
  autogen : int option;
}

let term_replace =
  Arg.(
    value & flag
    & info [ "r"; "replace" ] ~doc:"Use in order to replace a password"
  )

let term_website =
  Arg.(
    required
    & opt (some string) None
    & info [ "w"; "website" ] ~doc:"" ~docv:"WEBSITE"
  )

let term_username =
  Arg.(
    value
    & opt ~vopt:None (some string) None
    & info [ "u"; "username" ] ~doc:"" ~docv:"USERNAME"
  )

let term_mail =
  Arg.(
    value & opt (some string) None & info [ "m"; "mail" ] ~doc:"" ~docv:"MAIL"
  )

let term_autogen =
  Arg.(
    value
    & opt (some int) None
    & info [ "g"; "autogen" ]
        ~doc:"Generate an automatic password with a given length" ~docv:"LENGTH"
  )

let term_cmd run =
  let combine replace website username mail autogen =
    run @@ { replace; website; username; mail; autogen }
  in
  Term.(
    const combine $ term_replace $ term_website $ term_username $ term_mail
    $ term_autogen
  )

let doc = "Add passwords to $(mname)"
let man = [ (* `S Manpage.s_description; *) ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info @@ term_cmd run

let run _t =
  (* let {replace; website; username; mail; autogen} = t in *)
  ()

let command = cmd run
