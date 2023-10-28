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
        raise @@ Error.decryption_error
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
            (fun (find, passwords) (elt : Password.t) ->
              match find with
              | true ->
                  (find, elt :: passwords)
              | false ->
                  if elt.website = password.Password.website then
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

let length manager = List.length manager.passwords
let map f manager = { passwords = List.map f manager.passwords }
let iter f manager = List.iter f manager.passwords
let fold_left f default manager = List.fold_left f default manager.passwords

(**
    [filter website manager] removes passwords in [manager] with the website [website]
    if no password are removed in [manager], [manager] is physical equal to [manager]
*)
let filter website manager =
  let base = length manager in
  let new_manager =
    {
      passwords =
        List.filter
          (fun password -> password.Password.website <> website)
          manager.passwords;
    }
  in
  let new_length = length new_manager in
  if base = new_length then
    (0, manager)
  else
    (base - new_length, new_manager)

(**
    [filter_rexp website manager] filters [manager] with the website matching the regex [website]
*)
let filter_rexp website manager =
  let passwords =
    List.filter
      (fun password -> Str.string_match website password.Password.website 0)
      manager.passwords
  in
  { passwords }

let hide_password manager = map Password.hide manager

(**
    [website_max_length manager] returns the max between the longest website in [manager] and [String.length "website"]
*)
let website_max_length manager =
  let str_webitse = "website" in
  let len_website = String.length str_webitse in
  fold_left
    (fun len password -> max len @@ String.length @@ Password.website password)
    len_website manager

(**
    [password_max_length manager] returns the max between the longest password in [manager] and [String.length "password"]
*)
let password_max_length manager =
  let str = "paswword" in
  let len_website = String.length str in
  fold_left
    (fun len password -> max len @@ String.length @@ Password.password password)
    len_website manager

(**
    [password_max_length manager] returns the max between the longest password in [manager] and [String.length "username"]
*)
let username_max_length manager =
  let str = "username" in
  let len_website = String.length str in
  fold_left
    (fun len password ->
      max len @@ String.length
      @@ Option.value ~default:String.empty
      @@ Password.username password
    )
    len_website manager

(**
    [mail_max_length manager] returns the max between the longest mail in [manager] and [String.length "mail"]
*)
let mail_max_length manager =
  let str = "mail" in
  let len_website = String.length str in
  fold_left
    (fun len password ->
      max len @@ String.length
      @@ Option.value ~default:String.empty
      @@ Password.mail password
    )
    len_website manager

let display_line_width manager =
  let w = website_max_length manager in
  let u = username_max_length manager in
  let m = mail_max_length manager in
  let p = password_max_length manager in
  let spliter_count = 5 in
  w + u + m + p + spliter_count

let line_description ~len_website ~len_username ~len_mail ~len_password password
    =
  let s = Buffer.create 17 in
  let () = Buffer.add_string s Cbindings.Termove.vertical_line in
  let () = Buffer.add_string s @@ Password.website password in
  let () =
    Buffer.add_string s @@ Util.Ustring.spaces
    @@ (len_website - (String.length @@ Password.website password))
  in
  let () = Buffer.add_string s Cbindings.Termove.vertical_line in
  let () = Option.iter (Buffer.add_string s) @@ Password.username password in
  let () =
    Option.iter (Buffer.add_string s)
    @@ Option.map
         (fun username ->
           Util.Ustring.spaces @@ (len_username - String.length username)
         )
         (Password.username password)
  in
  let () = Buffer.add_string s Cbindings.Termove.vertical_line in
  let () = Option.iter (Buffer.add_string s) @@ Password.mail password in
  let () =
    Option.iter (Buffer.add_string s)
    @@ Option.map
         (fun mail -> Util.Ustring.spaces @@ (len_mail - String.length mail))
         (Password.mail password)
  in
  let () = Buffer.add_string s Cbindings.Termove.vertical_line in
  let () = Buffer.add_string s @@ Password.password password in
  let () =
    Buffer.add_string s @@ Util.Ustring.spaces
    @@ (len_password - (String.length @@ Password.password password))
  in
  let () = Buffer.add_string s Cbindings.Termove.vertical_line in
  Buffer.contents s

let repr_lines ?(show_password = false) manager =
  let len_website = website_max_length manager in
  let len_username = username_max_length manager in
  let len_mail = mail_max_length manager in
  let len_password = password_max_length manager in
  List.map
    (fun password ->
      let password =
        match show_password with
        | true ->
            password
        | false ->
            Password.hide password
      in
      line_description ~len_website ~len_username ~len_mail ~len_password
        password
    )
    manager.passwords
