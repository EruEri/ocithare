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
module CharSet = Set.Make (Char)

let name = "generate-password"

let numbers =
  CharSet.of_seq @@ Seq.init 10 @@ fun n -> Char.chr (n + Char.code '0')

let lowercases =
  CharSet.of_seq @@ Seq.init 26 @@ fun n -> Char.chr (n + Char.code 'a')

let uppercases =
  CharSet.of_seq @@ Seq.init 26 @@ fun n -> Char.chr (n + Char.code 'A')

let symbols =
  (* 34 because ascii printable char start a 34*)
  let all =
    CharSet.of_seq @@ Seq.init (127 - 32) @@ fun n -> Char.chr (n + 32)
  in
  all |> CharSet.diff numbers |> CharSet.diff lowercases
  |> CharSet.diff uppercases

type character_set = Number | LowerCaseLetter | UppercaseLetter | Symbol

type t = {
  number : bool;
  uppercase : bool;
  lowercase : bool;
  symbole : bool;
  exclude : CharSet.t;
  count : int;
}

let default_count = Some 8

let term_number =
  Arg.(value & flag & info [ "n" ] ~doc:"Include number set [0-9]")

let term_uppercase =
  Arg.(value & flag & info [ "u" ] ~doc:"Include uppercased letter set [A-Z]")

let term_lowercase =
  Arg.(value & flag & info [ "l" ] ~doc:"Include lowercase letter set [a-z]")

let term_symbole =
  Arg.(
    value & flag
    & info [ "s" ]
        ~doc:"Include all printable character that aren't a number or a letter"
  )

let term_exclude =
  Arg.(
    value & opt_all char []
    & info [ "e"; "exclude" ] ~docv:"<Char>"
        ~doc:"Exclude $(docv) from character set"
  )

let term_cout =
  Arg.(
    required
    & opt ~vopt:default_count (some int) default_count
    & info [ "c"; "count" ] ~docv:"<LENGTH>"
        ~doc:"Set the length of the generated password"
  )

let term_cmd run =
  let combine number uppercase lowercase symbole exclude count =
    let exclude = CharSet.of_list exclude in
    run { number; uppercase; lowercase; symbole; count; exclude }
  in
  Term.(
    const combine $ term_number $ term_uppercase $ term_lowercase $ term_symbole
    $ term_exclude $ term_cout
  )

let doc = "Generate a random password"
let man = []

let cmd run =
  let info = Cmd.info ~man ~doc name in
  Cmd.v info @@ term_cmd run

let run _t = ()
let command = cmd run
