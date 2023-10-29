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

let name = "init"

type t = { force : bool; import : string option }

let term_force =
  Arg.(value & flag & info [ "f"; "force" ] ~doc:"Force the initialisation")

let term_import =
  Arg.(
    value
    & opt (some file) None
    & info [ "i"; "import" ] ~docv:"<FILE>"
        ~doc:"Initialize with a formatted password file"
  )

let term_cmd run =
  let combine force import = run @@ { force; import } in
  Term.(const combine $ term_force $ term_import)

let p e = `P e
let i a b = `I (a, b)
let noblank = `Noblank
let doc = "Initialize $(mname)"
let pre s = `Pre s

let json_description =
  "passwords: array of passwords\n\
  \    password : object\n\
  \      website: string (required)\n\
  \      username : string (optional)\n\
  \      mail : string (optional)\n\
  \      password : (required)"

let man =
  [
    `S Manpage.s_description;
    p
    @@ Printf.sprintf
         "Initialize $(mname) by creating $(b,XDG_DATA_HOME/cithare/%s) file"
         Libcithare.Config.password_file;
    p
      "If $(mname) has already been initialized, $(iname) will raise an \
       exception unless the $(b,--force) option is given which will delete the \
       existing $(mname) installation";
    p "To import existing passwords, use $(b,--import <FILE>)";
    noblank;
    p
      "Imported passwords $(b,must be) formatted as a json according to the \
       following structure :";
    pre json_description;
    p "Passwords exported throught $(mname)$(b,-export(1)) can be imported";
  ]

let cmd run =
  let info = Cmd.info ~doc ~man name in
  Cmd.v info @@ term_cmd run

let run t =
  let { force; import } = t in
  let citharecf_exist =
    Util.FileSys.file_exists Libcithare.Config.cithare_password_file
  in
  let () =
    match force with
    | false when citharecf_exist ->
        raise @@ Libcithare.Error.cithare_already_configured
    | true | false ->
        ()
  in
  let () =
    match
      Util.FileSys.mkdirp Libcithare.Config.xdg_data
        [ Libcithare.Config.cithare_name ]
    with
    | Ok () ->
        ()
    | Error s ->
        failwith s
  in
  let () =
    match force with
    | true when citharecf_exist ->
        Sys.remove Libcithare.Config.cithare_password_file
    | true | false ->
        ()
  in
  let manager =
    match import with
    | Some file ->
        Libcithare.Manager.of_json_file file
    | None ->
        Libcithare.Manager.empty
  in
  let pass1 =
    Libcithare.Input.ask_password
      ~prompt:Libcithare.Input.Prompt.master_new_password ()
  in
  let pass2 =
    Libcithare.Input.ask_password
      ~prompt:Libcithare.Input.Prompt.master_confirm_new_password ()
  in
  let pass =
    match pass1 = pass2 with
    | true ->
        pass1
    | false ->
        raise @@ Libcithare.Error.unmatched_password
  in
  let () = Libcithare.Manager.encrypt ~encrypt_key:true pass manager in
  let extension =
    match Option.is_some import with true -> "with passwords" | false -> ""
  in
  let () =
    Printf.printf "%s initiliazed %s\n%!" Libcithare.Config.cithare_name
      extension
  in
  ()

let command = cmd run
