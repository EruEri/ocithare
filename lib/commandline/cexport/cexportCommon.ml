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

class export_t ?mail ?username validate fpaste website regex paste output =
  object (self)
    method paste = paste
    method website = website

    method process_website
        : regex:bool -> paste:bool -> Libcithare.Manager.t -> string -> unit =
      fun ~regex ~paste manager website ->
        let manager =
          Libcithare.Manager.matches ~regex ?mail ?username website manager
        in
        let passwords = Libcithare.Manager.elements manager in
        let () =
          match passwords with
          | password :: [] ->
              fpaste ?mail ?username ~regex ~paste password
          | [] ->
              Libcithare.Error.emit_no_matching_password ()
          | _ :: _ as list ->
              Libcithare.Error.emit_too_many_matching_password
              @@ List.map Libcithare.Password.website list
        in
        ()

    method export : Libcithare.Manager.t -> string -> unit =
      fun manager path ->
        let () = Libcithare.Manager.to_file path manager in
        ()

    method run : unit -> unit =
      fun () ->
        let () = validate self in
        let master_password = Libcithare.Input.ask_password_encrypted () in
        let manager = Libcithare.Manager.decrypt master_password in
        let () =
          Option.iter (self#process_website ~regex ~paste manager) website
        in
        let () = Option.iter (self#export manager) output in
        ()
  end

let name = "export"
let doc = "Export passwords"

let man =
  [
    `S Manpage.s_description;
    `P
      "$(iname) retrieves passwords from $(mname), either the password for one \
       entry or export all the passwords stored in a json formatted file";
    `P "$(b,-m) and $(b,-n) options further narrows down the matching.";
    `Noblank;
    `P
      "Narrow down the matching is mandatory if you try to retrieve a password \
       from an entry where the website appears more than once.";
    `P
      "Regex option (ie. $(b,-r)) if provided, treats individually \
       $(b,website), $(b,name) and $(b,mail) as a regex string";
    `S Manpage.s_examples;
    `I
      ( "Export all the password into a file named passwords.json",
        "$(iname) -o passwords.json"
      );
    `I ("Export password for the website sitea", "$(iname) -w sitea");
    `I
      ( "Export password for the a website matching $(b,sit) and a username \
         matching $(b,user)",
        "$(iname) -rw 'sit*' -u 'user*' "
      );
  ]

let term_website =
  Arg.(
    value
    & opt (some string) None
    & info [ "w"; "website" ] ~docv:"WEBSITE" ~doc:"Match the website"
  )

let term_regex =
  Arg.(
    value & flag
    & info [ "r"; "regex" ] ~doc:"Treat each field as a regex string"
  )

let term_output =
  Arg.(
    value
    & opt (some string) None
    & info [ "o" ] ~docv:"<OUTFILE>"
        ~doc:"Export passwords as json into $(docv)"
  )

let term_name =
  Arg.(
    value
    & opt (some string) None
    & info [ "n"; "name"; "username" ] ~docv:"<NAME>" ~doc:"Match the username"
  )

let term_mail =
  Arg.(
    value
    & opt (some string) None
    & info [ "m"; "mail" ] ~docv:"<MAIL>" ~doc:"Match the mail"
  )

let term_cmd ~term_paste validate fpaste =
  let combine mail username website regex paste output =
    let export =
      new export_t ?mail ?username validate fpaste website regex paste output
    in
    export#run ()
  in
  Term.(
    const combine $ term_mail $ term_name $ term_website $ term_regex
    $ term_paste $ term_output
  )
