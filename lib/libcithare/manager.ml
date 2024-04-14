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

module Inner = struct
  type t = { passwords : Password.t list } [@@deriving yojson]
end

module Passwords = Set.Make (struct
  type t = Password.t

  let compare lhs rhs =
    let open Password in
    let compare_website lhs rhs = String.compare lhs.website rhs.website in
    let compare_mail lhs rhs =
      Option.compare String.compare lhs.mail rhs.mail
    in
    let compare_user lhs rhs =
      Option.compare String.compare lhs.username rhs.username
    in
    Util.Misc.compares [ compare_website; compare_mail; compare_user ] lhs rhs
end)

type t = { passwords_set : Passwords.t }
type change_status = CsAdded | CsChanged

let to_inner t =
  let passwords = List.of_seq @@ Passwords.to_seq t.passwords_set in
  Inner.{ passwords }

let of_inner inner =
  let passwords_set = Passwords.of_list inner.Inner.passwords in
  { passwords_set }

let empty = { passwords_set = Passwords.empty }

(**
  [elements manager] returns the list of passwords record stored in [manager]
*)
let elements manager = Passwords.elements manager.passwords_set

let to_data manager =
  Yojson.Safe.to_string @@ Inner.to_yojson @@ to_inner manager

let to_file path manager =
  Yojson.Safe.to_file path @@ Inner.to_yojson @@ to_inner manager

let of_json_file file =
  let json = Yojson.Safe.from_file file in
  match Inner.of_yojson json with
  | Ok e ->
      of_inner e
  | Error e ->
      raise @@ Error.import_file_wrong_formatted e

let of_json_string string =
  let json = Yojson.Safe.from_string string in
  match Inner.of_yojson json with
  | Ok e ->
      of_inner e
  | Error _ ->
      raise @@ Error.password_file_wrong_formatted

let check_initialized () =
  match Util.FileSys.file_exists Config.cithare_password_file with
  | false ->
      raise @@ Error.cithare_not_configured
  | true ->
      ()

(**
    [encrypt ?encrypt_key password manager] encrypt [manager] with [password] and store bytes [Config.cithare_password_file]
    if [encrypt_key], [password] is encrypted with [aes256]
*)
let encrypt ?(encrypt_key = false) ?(where = Config.cithare_password_file)
    password manager =
  let key =
    match encrypt_key with
    | true ->
        Crypto.aes_string_encrypt password ()
    | false ->
        password
  in
  let _ = Crypto.encrypt ~where ~key ~iv:Crypto.default_iv (to_data manager) in
  ()

(**
    [decrypt ?encrypt_key password] decrypts the manager with [password] and stored at [Config.cithare_password_file]
    if [encrypt_key], [password] is encrypted with [aes256]
*)
let decrypt ?(encrypt_key = false) ?(where = Config.cithare_password_file)
    password =
  let key =
    match encrypt_key with
    | true ->
        Crypto.aes_string_encrypt password ()
    | false ->
        password
  in
  let t =
    match Crypto.decrpty_file ~key ~iv:Crypto.default_iv where with
    | Error e ->
        raise e
    | Ok None ->
        raise @@ Error.decryption_error
    | Ok (Some content) ->
        of_json_string content
  in
  t

let save_state ?(encrypt_key = false) master_password manager =
  match Config.cithare_save_state () with
  | false ->
      ()
  | true ->
      let time = Unix.gmtime (Unix.time ()) in
      let random_name =
        Password.Generate.create ~number:true ~uppercase:true ~lowercase:true
          ~symbole:false 8
      in
      let name =
        Printf.sprintf "%s %s %02u-%02u-%02u %02u-%02u-%02u" Config.cithare_name
          random_name (time.tm_year + 1900) (time.tm_mon + 1) time.tm_mday
          time.tm_hour time.tm_min time.tm_sec
      in
      let path = Filename.concat Config.cithare_state_dir name in
      let () =
        match
          Util.FileSys.mkfilep Config.xdg_state [ Config.cithare_name ] name
        with
        | Error path ->
            let () = Error.emit_cannot_save_state path in
            ()
        | Ok () -> (
            try encrypt ~encrypt_key ~where:path master_password manager
            with _ ->
              let () = Error.emit_cannot_save_state path in
              ()
          )
      in
      ()

let create_password website username mail password =
  Password.create website username mail password

(**
    [add password manager] adds [password] to [manager]
*)
let add password manager =
  { passwords_set = Passwords.add password manager.passwords_set }

(**
    [(<<)] is the same as [add] with the arguments reversed
*)
let ( << ) manager password = add password manager

let count manager = Passwords.cardinal manager.passwords_set

let diff lhs rhs =
  let passwords_set = Passwords.diff lhs.passwords_set rhs.passwords_set in
  { passwords_set }

let map f manager =
  let passwords_set = Passwords.map f manager.passwords_set in
  if manager.passwords_set == passwords_set then
    manager
  else
    { passwords_set }

let iter f manager = Passwords.iter f manager.passwords_set

let fold f default manager =
  Passwords.fold (fun elt acc -> f acc elt) manager.passwords_set default

let mem password manager = Passwords.mem password manager.passwords_set

let insert ?mail ?username ~replace (password : Password.t) manager =
  match replace with
  | true ->
      let is_password_replacement (new_password : Password.t)
          (old_password : Password.t) =
        let are_field_matched =
          match (mail, username) with
          | None, None ->
              true
          | Some _, None ->
              Option.equal String.equal new_password.mail old_password.mail
          | None, Some _ ->
              Option.equal String.equal new_password.username
                old_password.username
          | Some _, Some _ ->
              Option.equal String.equal new_password.mail old_password.mail
              && Option.equal String.equal new_password.username
                   old_password.username
        in
        new_password.Password.website = old_password.Password.website
        && are_field_matched
      in
      (* Take one string if one if None or take the newer*)
      let merge old recent =
        match (old, recent) with
        | None, None ->
            None
        | (Some _ as p), None | (None | Some _), (Some _ as p) ->
            p
      in
      let manager_mapped =
        map
          (fun p ->
            if is_password_replacement password p then
              Password.merge merge merge p password
            else
              p
          )
          manager
      in
      if manager_mapped == manager then
        (* No element were changed (ie. replaced), so we add the password  *)
        (Some CsAdded, manager << password)
      else
        (Some CsChanged, manager_mapped)
  | false ->
      if mem password manager then
        (None, manager)
      else
        let manager = manager << password in
        (Some CsAdded, manager)

let password_match ~regex ?mail ?username website (password : Password.t) =
  let string_match r to_match =
    match regex with
    | false ->
        String.equal r to_match
    | true ->
        let str_regex = Str.regexp r in
        Str.string_match str_regex to_match 0
  in
  let ( =? ) = string_match in
  let optional_match r to_match =
    match (r, to_match) with
    | None, (None | Some _) ->
        true
    | Some _, None ->
        false
    | Some lhs, Some rhs ->
        lhs =? rhs
  in
  let ( =?? ) = optional_match in
  website =? password.website
  && mail =?? password.mail
  && username =?? password.username

(**
  [matches ?(negate) ?mail ?username ~regex website manager] matches passwords within [manager] with
  [website]. [mail] and [username] allows to narrow down the matchings by also matching the mail and username
  field in password.
  - If [regex] is provided, [mail], [username] and [website] are treaded as regex.
  - If [negate] is provided, the returns all the passwords that `doesn't match` with [mail], [username] and [website].
  - If all the elements are matched, manager is unchanged (the result of the function is then physically equal to [manager])
*)
let matches ?(negate = false) ?mail ?username ~regex website manager =
  let transformer =
    if negate then
      Fun.negate
    else
      Fun.id
  in
  let f = transformer @@ password_match ~regex ?mail ?username website in
  let passwords_set = Passwords.filter f manager.passwords_set in
  if manager.passwords_set == passwords_set then
    manager
  else
    { passwords_set }

let hide_password manager = map Password.hide manager

(**
    [website_max_length manager] returns the max between the longest website in [manager] and [String.length "website"]
*)
let website_max_length manager =
  let str_webitse = "website" in
  let len_website = String.length str_webitse in
  fold
    (fun len password -> max len @@ String.length @@ Password.website password)
    len_website manager

(**
    [password_max_length manager] returns the max between the longest password in [manager] and [String.length "password"]
*)
let password_max_length manager =
  let str = "paswword" in
  let len_website = String.length str in
  fold
    (fun len password -> max len @@ String.length @@ Password.password password)
    len_website manager

(**
    [password_max_length manager] returns the max between the longest password in [manager] and [String.length "username"]
*)
let username_max_length manager =
  let str = "username" in
  let len_website = String.length str in
  fold
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
  fold
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

let error_format password =
  let truncate = Util.Ustring.truncate 20 in
  let str_none = "None" in
  Printf.sprintf "%s, %s, %s"
    (truncate password.Password.website)
    (Option.fold ~none:str_none ~some:truncate password.username)
    (Option.fold ~none:str_none ~some:truncate password.mail)

let line_description ~len_website ~len_username ~len_mail ~len_password password
    =
  let s = Buffer.create 17 in
  let w = Password.website password in
  let m = Option.value ~default:String.empty @@ Password.mail password in
  let u = Option.value ~default:String.empty @@ Password.username password in
  let p = Password.password password in

  let () = Buffer.add_char s '|' in
  let () = Buffer.add_string s w in
  let () =
    Buffer.add_string s @@ Util.Ustring.spaces @@ (len_website - String.length w)
  in
  let () = Buffer.add_char s '|' in
  let () = Buffer.add_string s u in
  let () =
    Buffer.add_string s @@ Util.Ustring.spaces
    @@ (len_username - String.length u)
  in
  let () = Buffer.add_char s '|' in
  let () = Buffer.add_string s m in
  let () =
    Buffer.add_string s @@ Util.Ustring.spaces @@ (len_mail - String.length m)
  in
  let () = Buffer.add_char s '|' in
  let () = Buffer.add_string s p in
  let () =
    Buffer.add_string s @@ Util.Ustring.spaces
    @@ (len_password - String.length p)
  in
  let () = Buffer.add_char s '|' in
  Buffer.contents s

let repr_lines ?(show_password = false) manager =
  let len_website = website_max_length manager in
  let len_username = username_max_length manager in
  let len_mail = mail_max_length manager in
  let len_password = password_max_length manager in
  List.map (fun password ->
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
  @@ (to_inner manager).passwords

let restrict_size dimension offsets =
  let v_offset, h_offset = offsets in
  let v_len, h_len = dimension in
  let v_offset = max v_offset 0 in
  let v_offset = min v_offset (v_len - 1) in
  let h_offset = max h_offset 0 in
  let h_offset = min h_offset (h_len - 1) in
  (v_offset, h_offset)

let rec loop ?old_winsize ?info dim input lines =
  let w = Cbindings.Winsize.get () in
  let winsize, did_change =
    match old_winsize with None -> (w, true) | Some old -> (w, w <> old)
  in
  match info with
  | None ->
      ()
  | Some (r, v_offset, h_offset) -> (
      let () =
        match r || did_change with
        | true ->
            Draw.draw ~v_offset ~h_offset w lines
        | false ->
            ()
      in

      match input v_offset h_offset with
      | None ->
          ()
      | Some t ->
          let new_v_offset, new_h_offset = restrict_size dim t in
          let r = not (new_v_offset = v_offset && new_h_offset = h_offset) in
          let info = (r, new_v_offset, new_h_offset) in
          loop ~old_winsize:winsize ~info dim input lines
    )

let finput old_v_offset old_h_offset =
  let bytes = Bytes.create 1 in
  let _rread = Unix.read Unix.stdin bytes 0 1 in
  match Bytes.get bytes 0 with
  | 'q' ->
      None
  | 'i' ->
      Some (old_v_offset - 1, old_h_offset)
  | 'k' ->
      Some (old_v_offset + 1, old_h_offset)
  | 'l' ->
      Some (old_v_offset, old_h_offset + 1)
  | 'j' ->
      Some (old_v_offset, old_h_offset - 1)
  | _ ->
      Some (old_v_offset, old_h_offset)

let display ?(show_password = false) manager =
  let lines = repr_lines ~show_password manager in
  let len = display_line_width manager in
  let vertical_line = Util.Ustring.line ~first:'|' ~last:'|' len '-' in
  let lines =
    List.cons vertical_line
    @@ List.concat_map (fun l -> [ vertical_line; l ]) lines
  in
  let lines = List.append lines [ vertical_line ] in
  let dim = (List.length lines, len) in
  let () = Cbindings.Termove.start_window () in
  let () = loop ~info:(true, 0, 0) dim finput lines in
  let () = Cbindings.Termove.end_window () in
  ()

let display ?(show_password = false) ?display_time manager =
  let () = at_exit Cbindings.Termove.end_window in
  let () =
    match display_time with
    | None ->
        let () = display ~show_password manager in
        ()
    | Some t ->
        let t = abs t in
        let _ = Thread.create (display ~show_password) manager in
        let () = Thread.delay @@ Float.of_int t in
        ()
  in
  ()
