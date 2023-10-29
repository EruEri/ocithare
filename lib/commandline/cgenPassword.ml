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
  let all = CharSet.diff all numbers in
  let all = CharSet.diff all uppercases in
  let all = CharSet.diff all lowercases in
  all

type character_set = Number | LowerCaseLetter | UppercaseLetter | Symbol

type t = {
  number : bool;
  uppercase : bool;
  lowercase : bool;
  symbole : bool;
  exclude : CharSet.t;
  count : int;
}

(**
    [create ?(exclude = CharSet.empty) ~number ~uppercase ~lowercase ~symbole] creates a password using several charsets.
    if [number], [uppercase], [lowercase] and [symbole] are all false, [create] defaults to use [alphanumerical] charset
    @raise Invalid_argument if the char set after all the filter is empty or [count <= 0]
*)
let create ?(exclude = CharSet.empty) ~number ~uppercase ~lowercase ~symbole
    count =
  let number, uppercase, lowercase, symbole =
    match number && uppercase && lowercase && symbole with
    | true ->
        (number, uppercase, lowercase, symbole)
    | false ->
        (true, true, true, symbole)
  in
  let set = match number with true -> numbers | false -> CharSet.empty in
  let set =
    match uppercase with true -> CharSet.union set uppercases | false -> set
  in
  let set =
    match lowercase with true -> CharSet.union set lowercases | false -> set
  in
  let set =
    match symbole with true -> CharSet.union set symbols | false -> set
  in
  let set = CharSet.diff set exclude in
  let () =
    match set = CharSet.empty with
    | true ->
        invalid_arg "Empty Char Set"
    | false ->
        ()
  in
  let () =
    match count with n when n <= 0 -> invalid_arg "Negative count" | _ -> ()
  in
  let chars = Array.of_seq @@ CharSet.to_seq set in
  let len = Array.length chars in
  let () = Random.self_init () in
  let rec gen s n =
    match n with
    | 0 ->
        s
    | n ->
        let i = Random.full_int len in
        let c = Array.unsafe_get chars i in
        let s = Printf.sprintf "%s%c" s c in
        gen s (n - 1)
  in
  gen String.empty count

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

let man =
  [
    `S Manpage.s_description;
    `P doc;
    `P
      "If no charset is given, $(iname) will use the $(b,alphanumeric \
       charaset), which is like $(b,-nlu)";
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
