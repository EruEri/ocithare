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
    method regex = regex
    method paste = paste
    method website = website
    method output = output

    method process_website
        : regex:bool -> paste:bool -> Libcithare.Manager.t -> string -> unit =
      fun ~regex ~paste manager website ->
        let manager = Libcithare.Manager.matches ~regex ?mail ?username website manager in
        let passwords = Libcithare.Manager.elements manager in
        let () =
          match passwords with
          | password :: [] ->
              fpaste ~regex ~paste password
          | [] ->
              Libcithare.Error.emit_no_matching_password ()
          | _ :: _ as list ->
              Libcithare.Error.emit_too_many_matching_password
              @@ List.map Libcithare.Password.website list
        in
        ()

    method export : Libcithare.Manager.t -> string -> unit =
      fun manager path ->
        let () =
          Libcithare.Manager.to_file path manager
        in
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

let term_website =
  Arg.(
    value
    & opt (some string) None
    & info [ "w"; "website" ] ~docv:"WEBSITE" ~doc:"Specify the site"
  )

let term_regex =
  Arg.(
    value & flag
    & info [ "r"; "regex" ] ~doc:"Find the website by matching its name"
  )

let term_paste =
  Arg.(
    value & flag
    & info [ "p"; "paste" ] ~doc:"Write the password into the pasteboard"
  )

let term_output =
  Arg.(
    value
    & opt (some string) None
    & info [ "o" ] ~docv:"<OUTFILE>" ~doc:"Export passwords as json into $(docv)"
  )

  let term_name = 
    Arg.(
      value
      & opt (some string) None
      & info ["n"; "name"; "username"] ~docv:"<NAME>" ~doc:"Match the username"
    )

  let term_mail = 
    Arg.(
      value
      & opt (some string) None
      & info ["m"; "mail"] ~docv:"<MAIL>" ~doc:"Match the mail"
    )


  let term_cmd validate fpaste =
    let combine mail username website regex paste output =
      let export =
        new export_t ?mail ?username validate fpaste website regex paste output
      in
      export#run ()
    in
    Term.(const combine $ term_mail $ term_name $ term_website $ term_regex $ term_paste $ term_output)
