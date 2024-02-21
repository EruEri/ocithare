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

let getpassword gen_password =
  let CgenPassword.{ number; uppercase; lowercase; symbole; exclude; count } =
    gen_password
  in
  match
    (not (CgenPassword.CharSet.is_empty exclude))
    || Option.is_some count
    || Libcithare.Password.Generate.has_options ~number ~uppercase ~lowercase
         ~symbole
  with
  | true ->
      let count = Option.value ~default:CgenPassword.default_count count in
      CgenPassword.is_password_satifying ~exclude ~number ~uppercase ~lowercase
        ~symbole count
  | false ->
      let first =
        Libcithare.Input.ask_password
          ~prompt:Libcithare.Input.Prompt.new_password ()
      in
      let confirm =
        Libcithare.Input.ask_password
          ~prompt:Libcithare.Input.Prompt.confirm_password ()
      in
      let () =
        match first = confirm with
        | true ->
            ()
        | false ->
            raise @@ Libcithare.Error.unmatched_password
      in
      Some first

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
  let () =
    match Util.FileSys.file_exists Libcithare.Config.cithare_password_file with
    | false ->
        raise @@ Libcithare.Error.cithare_not_configured
    | true ->
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
    Libcithare.Manager.replace_or_add ~replace new_password manager
  in
  let () = Libcithare.Manager.encrypt master_password manager in
  let () =
    match status with
    | CsAdded ->
        print_endline "Password added"
    | CsChanged ->
        print_endline "Password replaced"
  in
  ()

let command = cmd run
