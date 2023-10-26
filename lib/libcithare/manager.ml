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

module Prompt = struct
  let master_password = "Enter the master password : "
  let new_password = "Enter the new master password : "
  let confirm_new_password = "Confirm the new master password : "
end

type t = { passwords : Password.t list } [@@deriving yojson]

let empty = { passwords = [] }
let to_data manager = Yojson.Safe.to_string @@ to_yojson manager

(**
    [ask_password ?(prompt = prompt) ()] gets the password from the user using [c getpass]
    @raise Error.CithareError if c pointer is null
*)
let ask_password ?(prompt = Prompt.master_password) () =
  match Cbindings.Libc.getpass prompt with
  | Some s ->
      s
  | None ->
      raise @@ Error.getpass_error

let of_json_file file =
  let json = Yojson.Safe.from_file file in
  match of_yojson json with
  | Ok e ->
      e
  | Error e ->
      raise @@ Error.import_file_wrong_formatted e

(**
    [encrypt password manager] encrypt [manager] with [password] and store bytes [Config.cithare_password_file]
*)
let encrypt password manager =
  let _ =
    Crypto.encrypt ~where:Config.cithare_password_file ~key:password
      ~iv:Crypto.default_iv (to_data manager)
  in
  ()
