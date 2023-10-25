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

let term_website =
  Arg.(
    value & opt (some string) None & info ["w"; "website"] ~docv:"WEBSITE" ~doc:"Specify the site"
  )

let term_regex = 
  Arg.(
    value & flag & info ["r"; "regex"] ~doc:"Find the website by matching its name"
  )

let term_paste = 
  Arg.(
    value & flag & info ["p"; "paste"] ~doc:"Write the password into the pasteboard"
  )

let term_output = 
  Arg.(
    value & opt (some string) None & info ["o"; "output"] ~docv:"OUTFILE" ~doc:"Export passwords as json into $(docv)"
  )

let term_display_time = 
  Arg.(
    value & opt (some int) None & info ["d"; "display-time"] ~docv:"DURATION" ~doc:"Show password to stdout for $(docv)"
  )

let term_show_password = 
  Arg.(
    value & flag & info ["show-password"] ~doc:"Show plain passwords"
  )

let doc = "Show password"