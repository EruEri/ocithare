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

let name = "add"

type t = {
  replace : bool;
  website : string;
  username : string option;
  mail : string option;
  gen_password : CgenPassword.t;
}

let term_replace =
  Arg.(value & flag & info [ "r"; "replace" ] ~doc:"Replace a password")

let term_website =
  Arg.(
    required
    & opt (some string) None
    & info [ "w"; "website" ] ~doc:"Chosen $(docv)" ~docv:"WEBSITE"
  )

let term_username =
  Arg.(
    value
    & opt (some string) None
    & info [ "n"; "name"; "username" ] ~doc:"Chosen $(docv)" ~docv:"NAME"
  )

let term_mail =
  Arg.(
    value
    & opt (some string) None
    & info [ "m"; "mail" ] ~doc:"Chosen $(docv)" ~docv:"MAIL"
  )

let term_cmd run =
  let combine replace website username mail gen_password =
    run @@ { replace; website; username; mail; gen_password }
  in
  Term.(
    const combine $ term_replace $ term_website $ term_username $ term_mail
    $ CgenPassword.term_cmd Fun.id
  )

let doc = "Add passwords to $(mname)"

let man =
  [
    `S Manpage.s_description;
    `P doc;
    `P "At least $(b,--website) or $(b,--username) must be present";
    `P
      "If one of the following option is provided $(b,-c, -d, -e, -l, -s, -u), \
       cithare-add(1) will automatically generate a password and the options \
       to generate the password are the same than cithare-generate-password(1)";
    `S Manpage.s_see_also;
    `P "cithare-generate-password(1)";
  ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info @@ term_cmd run

let getpassword = Common.getpassword

let validate t =
  let () = Libcithare.Manager.check_initialized () in
  let { replace; website = _; username; mail; gen_password = _ } = t in
  let () =
    match (username, mail) with
    | None, None when not replace ->
        raise @@ Libcithare.Error.option_simult_none [| "-username"; "-mail" |]
    | _ ->
        ()
  in
  ()

let run t =
  let { replace; website; username; mail; gen_password } = t in
  let () = validate t in
  let password = getpassword gen_password in
  let password =
    match password with
    | Some p ->
        p
    | None ->
        raise @@ Libcithare.Error.password_not_satisfaying
  in
  let master_password =
    Libcithare.Input.ask_password_encrypted
      ~prompt:Libcithare.Input.Prompt.master_password ()
  in
  let manager = Libcithare.Manager.decrypt master_password in
  let () = Libcithare.Manager.save_state master_password manager in
  let new_password =
    Libcithare.Manager.create_password website username mail password
  in
  let status, manager =
    Libcithare.Manager.insert ?mail ?username ~replace new_password manager
  in
  let () = Libcithare.Manager.encrypt master_password manager in
  let () =
    match status with
    | Some CsAdded ->
        print_endline "Password added"
    | Some CsChanged ->
        print_endline "Password replaced"
    | None ->
        Libcithare.Error.emit_already_existing_password
          ~exit:Libcithare.Error.Code.cithare_warning_code ()
  in
  ()

let command = cmd run
