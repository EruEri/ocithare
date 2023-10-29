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

type t = { change_master_password : bool } [@@unboxed]

let term_change_master_password =
  Arg.(
    value & flag
    & info [ "change-master-password" ] ~doc:"Change the master password"
  )

let term_cmd run =
  let combine change_master_password = run { change_master_password } in
  Term.(const combine $ term_change_master_password)

let run t =
  let { change_master_password } = t in
  let () = Libcithare.Manager.check_initialized () in
  let () =
    match change_master_password with
    | false ->
        ()
    | true ->
        let master_password = Libcithare.Input.ask_password_encrypted () in
        let manager = Libcithare.Manager.decrypt master_password in
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
        let () = Printf.printf "Master password sucessfully changed\n%!" in
        ()
  in
  ()

let default = term_cmd run
let name = Libcithare.Config.cithare_name
let version = Libcithare.Config.version
let doc = "A command-line password manager"

let man =
  [
    `S Manpage.s_description;
    `P "$(mname) is a commandline password manager";
    `P
      "To use $(mname), you need to initialize it. Use the $(mname) init \
       subcommand";
    `S Manpage.s_examples;
    `I
      ( "To add an autogenerated password of length 20 for the website \
         $(b,site_a)",
        "$(mname) $(b,add -w website -m mail -a 20)"
      );
    `I ("To export your password as a json", "$(mname) $(b,export -o password)");
    `I
      ( "To select the password matching the name sit",
        "$(mname) $(b,export -rw sit)"
      );
    `S Manpage.s_environment;
    `I
      ( Printf.sprintf "$(b,%s)" Libcithare.Config.cithare_env_save_state,
        {|If set to No, 0 or false (case insensible), $(mname) doesn't save the password file before modification|}
      );
  ]

let info = Cmd.info ~doc ~version ~man name

let subcommands =
  Cmd.group ~default info
    [
      Cinit.command;
      Cadd.command;
      Cdelete.command;
      Cexport.command;
      Cshow.command;
      CgenPassword.command;
    ]

let eval () =
  let () = Libcithare.Error.register_cithare_error () in
  Cmd.eval ~catch:false subcommands
