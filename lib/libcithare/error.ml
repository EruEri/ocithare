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

type cithare_error =
  | CithareAlreadyConfigured
  | CithareNotConfigured
  | GetPasswordError
  | UnmatchedPassword
  | DecryptionError
  | ImportFileWrongFormatted of string
  | OptionSimultNone of string array
  | MissingExpectedWhenAbsent of (string array * string array)
  | MissingExpectedWhenPresent of (string array * string array)
  | NegativeGivenLength
  | PasswordFileWrongFormatted
  | PasswordNotSatistying
  | DeleteActionAbort
  | SetPasswordContentError
  | EmptyCharSet

type cithare_warning =
  | NoMatchingPassword
  | TooManyMatchingPasswords of string list
  | CannotSaveState of string

exception CithareError of cithare_error

module Repr = struct
  let string_of_warning = function
    | NoMatchingPassword ->
        "No matching password"
    | TooManyMatchingPasswords website ->
        Printf.sprintf "Conflicting matching passwords:\n\t- %s"
        @@ String.concat "\n\t- " website
    | CannotSaveState p ->
        Printf.sprintf "Can’t save state at %s" p

  let string_of_options array =
    String.concat ", " @@ List.map (Printf.sprintf "-%s") @@ Array.to_list array

  let string_of_cithare_error =
    let sprintf = Printf.sprintf in
    function
    | CithareAlreadyConfigured ->
        sprintf "%s is already configured" Config.cithare_name
    | CithareNotConfigured ->
        sprintf "%s is not configured\n run cithare-init" Config.cithare_name
    | GetPasswordError ->
        sprintf "getpass(3) failed"
    | UnmatchedPassword ->
        sprintf "Passwords doesn't match"
    | DecryptionError ->
        sprintf "Decryption Error, you probabily mistyped your password"
    | ImportFileWrongFormatted file ->
        sprintf "The file %s is not formatted as expected" file
    | OptionSimultNone options ->
        sprintf "Those options can't be absent at the same time %s"
        @@ string_of_options options
    | MissingExpectedWhenAbsent (options, absents) ->
        let be = match Array.length absents with 0 | 1 -> "is" | _ -> "are" in
        sprintf "This options %s must be present if %s %s absent"
          (string_of_options options)
          (string_of_options absents)
          be
    | MissingExpectedWhenPresent (options, present) ->
        let be = match Array.length present with 0 | 1 -> "is" | _ -> "are" in
        sprintf "This options %s must be present if %s %s present"
          (string_of_options options)
          (string_of_options present)
          be
    | NegativeGivenLength ->
        sprintf "Can't give a negative length"
    | PasswordFileWrongFormatted ->
        sprintf "Password file is not formatted as expected"
    | PasswordNotSatistying ->
        "Abort password not satisfying"
    | DeleteActionAbort ->
        "Delete aborted"
    | SetPasswordContentError ->
        "Fail to write to the clipboard"
    | EmptyCharSet ->
        "The charset is empty"

  let string_of_color_cithare_error e =
    Printf.sprintf "%s : %s"
      (Cbindings.Termove.sprintf Cbindings.Termove.fg_red "error")
      (string_of_cithare_error e)
end

let cithare_already_configured = CithareError CithareAlreadyConfigured
let cithare_not_configured = CithareError CithareNotConfigured
let import_file_wrong_formatted e = CithareError (ImportFileWrongFormatted e)
let getpass_error = CithareError GetPasswordError
let unmatched_password = CithareError UnmatchedPassword
let option_simult_none a = CithareError (OptionSimultNone a)
let negative_given_length = CithareError NegativeGivenLength
let password_file_wrong_formatted = CithareError PasswordFileWrongFormatted
let password_not_satisfaying = CithareError PasswordNotSatistying
let delete_password_cancel = CithareError DeleteActionAbort
let set_pastboard_content_error = CithareError SetPasswordContentError
let empty_char_set = CithareError EmptyCharSet

let missing_expecting_when_absent missing when_set =
  CithareError (MissingExpectedWhenAbsent (missing, when_set))

let missing_expecting_when_present missing when_set =
  CithareError (MissingExpectedWhenPresent (missing, when_set))

let decryption_error = CithareError DecryptionError

let emit_warning e =
  Printf.printf "%s : %s\n"
    (Cbindings.Termove.sprintf Cbindings.Termove.fg_magenta "warning")
    (Repr.string_of_warning e)

let emit_no_matching_password () = emit_warning NoMatchingPassword
let emit_cannot_save_state path = emit_warning @@ CannotSaveState path

let emit_too_many_matching_password list =
  emit_warning @@ TooManyMatchingPasswords list

let register_cithare_error () =
  Printexc.register_printer (function
    | CithareError e ->
        Option.some @@ Printf.sprintf "\n%s"
        @@ Repr.string_of_color_cithare_error e
    | _ ->
        None
    )
