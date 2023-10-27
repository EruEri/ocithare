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

type t = { passwords : Password.t list } [@@deriving yojson]
type change_status = CsAdded | CsChanged

let empty = { passwords = [] }
let to_data manager = Yojson.Safe.to_string @@ to_yojson manager

let of_json_file file =
  let json = Yojson.Safe.from_file file in
  match of_yojson json with
  | Ok e ->
      e
  | Error e ->
      raise @@ Error.import_file_wrong_formatted e

let of_json_string string =
  let json = Yojson.Safe.from_string string in
  match of_yojson json with
  | Ok e ->
      e
  | Error _ ->
      raise @@ Error.password_file_wrong_formatted

(**
    [encrypt ?encrypt_key password manager] encrypt [manager] with [password] and store bytes [Config.cithare_password_file]
    if [encrypt_key], [password] is encrypted with [aes256]
*)
let encrypt ?(encrypt_key = false) password manager =
  let key =
    match encrypt_key with
    | true ->
        Crypto.aes_string_encrypt password ()
    | false ->
        password
  in
  let _ =
    Crypto.encrypt ~where:Config.cithare_password_file ~key
      ~iv:Crypto.default_iv (to_data manager)
  in
  ()

(**
    [decrypt ?encrypt_key password] decrypts the manager with [password] and stored at [Config.cithare_password_file]
    if [encrypt_key], [password] is encrypted with [aes256]
*)
let decrypt ?(encrypt_key = false) password =
  let key =
    match encrypt_key with
    | true ->
        Crypto.aes_string_encrypt password ()
    | false ->
        password
  in
  let t =
    match
      Crypto.decrpty_file ~key ~iv:Crypto.default_iv
        Config.cithare_password_file
    with
    | Error e ->
        raise e
    | Ok None ->
        failwith "I dont known what to do"
    | Ok (Some content) ->
        of_json_string content
  in
  t

let create_password website username mail password =
  Password.create website username mail password

(**
    [add password manager] adds [password] to [manager]
*)
let add password manager = { passwords = password :: manager.passwords }

(**
    [(<<)] is the same as [add] with the arguments reversed
*)
let ( << ) manager password = add password manager

let replace_or_add ~replace password manager =
  let manager =
    match replace with
    | true ->
        let find, passwords =
          List.fold_left
            (fun (find, passwords) elt ->
              let open Password in
              match find with
              | true ->
                  (find, elt :: passwords)
              | false ->
                  if elt.website = password.website then
                    (true, Password.replace elt password :: passwords)
                  else
                    (false, elt :: passwords)
            )
            (false, []) manager.passwords
        in
        let manager =
          match find with
          | true ->
              (CsChanged, { passwords })
          | false ->
              (CsAdded, { passwords = password :: passwords })
        in
        manager
    | false ->
        (CsAdded, manager << password)
  in
  manager
