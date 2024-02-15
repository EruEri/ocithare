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

let name = "generate-password"

module Gen = Libcithare.Password.Generate
module CharSet = Gen.CharSet

let numbers = Gen.numbers
let uppercases = Gen.uppercases
let lowercases = Gen.lowercases
let symbols = Gen.symbols
let create = Gen.create

type t = {
  number : bool;
  uppercase : bool;
  lowercase : bool;
  symbole : bool;
  exclude : CharSet.t;
  count : int;
}

let rec is_password_satifying ?(exclude = CharSet.empty) ~number ~uppercase
    ~lowercase ~symbole count =
  let open Libcithare in
  let module P = Input.Prompt in
  let password = create ~exclude ~number ~uppercase ~lowercase ~symbole count in
  let () = Printf.printf "Generated Password\n%s\n" password in
  let response =
    Input.validate_input ~default_message:P.password_satifying
      ~error_message:P.wrong_choice ~empty_line_message:P.empty_choice
  in
  match response with
  | true ->
      Some password
  | false ->
      let try_again =
        Input.validate_input ~default_message:P.try_again
          ~error_message:P.wrong_choice ~empty_line_message:P.empty_choice
      in
      if try_again then
        is_password_satifying ~exclude ~number ~uppercase ~lowercase ~symbole
          count
      else
        None

let default_count = Some 8

let term_number =
  Arg.(value & flag & info [ "d" ] ~doc:"Include digit set [0-9]")

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

let man =
  [
    `S Manpage.s_description;
    `P doc;
    `P
      "If no charset is given, $(iname) will use the $(b,alphanumeric \
       charaset), which is equivalent to $(iname) $(b,-nlu)";
  ]

let cmd run =
  let info = Cmd.info ~man ~doc name in
  Cmd.v info @@ term_cmd run

let run t =
  let { number; uppercase; lowercase; symbole; exclude; count } = t in
  let s = create ~exclude ~number ~uppercase ~lowercase ~symbole count in
  let () = Printf.printf "%s\n%!" s in
  ()

let command = cmd run
