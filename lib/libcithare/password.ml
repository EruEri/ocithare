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

module Generate = struct
  module CharSet = Set.Make (Char)

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

  (**
    [has_options ~number ~uppercase ~lowercase ~symbole] returns true if at least one of the arguments is true,
    false otherwise.
  *)
  let has_options ~number ~uppercase ~lowercase ~symbole =
    number || uppercase || lowercase || symbole

  (**
    [create ?(exclude = CharSet.empty) ~number ~uppercase ~lowercase ~symbole] creates a password using several charsets.
    if [number], [uppercase], [lowercase] and [symbole] are all false, [create] defaults to use [alphanumerical] charset
    @raise [Error.CithareError EmptyCharSet] if the char set after all the filter is empty
    @raise Invalid_argument is [cout <= 0]
*)
  let create ?(exclude = CharSet.empty) ~number ~uppercase ~lowercase ~symbole
      count =
    let number, uppercase, lowercase, symbole =
      match number || uppercase || lowercase || symbole with
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
          raise @@ Error.empty_char_set
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
end

type t = {
  website : string;
  username : (string option[@default None]);
  mail : (string option[@default None]);
  password : string;
}
[@@deriving yojson]

let create website username mail password =
  { website; username; mail; password }

(**
  [merge old newp] replaces [old] by [newp] and default to [old] if the [newp] are [None]
*)
let replace old newp =
  let ( |? ) base default =
    match base with Some _ -> base | None -> default
  in
  {
    website = newp.website;
    username = newp.username |? old.username;
    mail = newp.mail |? old.mail;
    password = newp.password;
  }

let website { website; _ } = website
let username { username; _ } = username
let password { password; _ } = password
let mail { mail; _ } = mail

let hide password =
  { password with password = String.map (fun _ -> '*') password.password }
