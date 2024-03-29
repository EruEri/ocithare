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

module Prompt = struct
  let master_password = "Enter the master password : "
  let master_new_password = "Enter the new master password : "
  let master_confirm_new_password = "Confirm the new master password : "
  let new_password = "Enter a password :"
  let confirm_password = "Confirm password : "
  let password_satifying = "Is password satisfying ? [y/n]"
  let wrong_choice = "Wrong Input!\nSelect between [y/n]"
  let empty_choice = "No Input!\nPlease select a reponse"
  let try_again = "Do you want to try again ? [y/n]"
  let delete_password = "Do you want to delete all your password? [y/n]"

  let delete_password_list s =
    Printf.sprintf "Do you want to delete the following passwords ? [y/n]\n%s"
    @@ String.concat "\n"
    @@ List.map (Printf.sprintf "  - %s") s
end

(**
    [ask_password ?(prompt = prompt) ()] gets the password from the user using [c getpass]
    @raise Error.CithareError if c pointer is null
*)
let ask_password ?(prompt = Prompt.master_password) () =
  match Cbindings.Libc.getpass prompt with
  | Some s ->
      s
  | None ->
      raise @@ Error.getpass_error

let ask_password_encrypted ?(prompt = Prompt.master_password) () =
  let s = ask_password ~prompt () in
  Crypto.aes_string_encrypt s ()

let rec validate_input ~default_message ~error_message ~empty_line_message =
  let () = print_endline default_message in
  let s = read_line () in
  match s with
  | "" ->
      let () = prerr_endline empty_line_message in
      validate_input ~default_message ~error_message ~empty_line_message
  | "y" | "Y" ->
      true
  | "n" | "N" ->
      false
  | _ ->
      let () = prerr_endline error_message in
      validate_input ~default_message ~error_message ~empty_line_message
