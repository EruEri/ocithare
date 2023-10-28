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

let name = "export"

type t = {
  website : string option;
  regex : bool;
  paste : bool;
  output : string option;
}

let term_website = CexportCommon.term_website
let term_regex = CexportCommon.term_regex

let term_paste =
  Arg.(
    value & flag
    & info [ "p"; "paste" ] ~doc:"Write the password into the pasteboard"
  )

let term_output = CexportCommon.term_output
let term_display_time = CexportCommon.term_display_time
let term_show_password = CexportCommon.term_show_password

let term_cmd run =
  let combine website regex paste output =
    run { website; regex; paste; output }
  in
  Term.(const combine $ term_website $ term_regex $ term_paste $ term_output)

let doc = CexportCommon.doc
let man = [ `S Manpage.s_description; `P "Export passwords" ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info (term_cmd run)

let validate t =
  let { website; paste; regex = _; output = _ } = t in
  let () =
    match (website, paste) with
    | None, true ->
        raise
        @@ Libcithare.Error.missing_expecting_when_present [| "website" |]
             [| "paste" |]
    | _ ->
        ()
  in
  ()

let process_paste ~paste ~regex password =
  match paste with
  | true ->
      let () =
        match
          Macos.set_pastboard_content password.Libcithare.Password.password
        with
        | true ->
            let () =
              if regex then
                Printf.printf "For : %s\n" password.website
              else
                ()
            in
            let () =
              Printf.printf "Password successfully written in pasteboard\n"
            in
            ()
        | false ->
            raise @@ Libcithare.Error.set_pastboard_content_error
      in
      ()
  | false ->
      ()

let process_website ~regex ~paste manager website =
  let r =
    if regex then
      Str.regexp website
    else
      Str.regexp_string website
  in
  let manager = Libcithare.Manager.filter_rexp r manager in
  let () =
    match manager.passwords with
    | password :: [] ->
        process_paste ~regex ~paste password
    | [] ->
        Libcithare.Error.emit_no_matching_password ()
    | _ :: _ as list ->
        Libcithare.Error.emit_too_many_matching_password
        @@ List.map Libcithare.Password.website list
  in
  ()

let regex_paste manager t =
  let { website; paste; regex; output = _ } = t in
  let () = Option.iter (process_website ~regex ~paste manager) website in
  ()

let export manager path =
  let () = Yojson.Safe.to_file path @@ Libcithare.Manager.to_yojson manager in
  ()

let run t =
  let { website; paste; regex; output } = t in
  let master_password = Libcithare.Input.ask_password_encrypted () in
  let manager = Libcithare.Manager.decrypt master_password in
  let () = Option.iter (process_website ~regex ~paste manager) website in
  let () = Option.iter (export manager) output in
  (* let () = Printf.printf "%b\n" @@ Macos.set_pastboard_content "Hello Caml" in *)
  ()

let command = cmd run
