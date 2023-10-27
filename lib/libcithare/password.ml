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
