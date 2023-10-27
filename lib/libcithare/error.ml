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
  | ImportFileWrongFormatted of string
  | OptionSimultNone of string array
  | MissingExpectedWhen of (string array * string array)
  | NegativeGivenLength
  | PasswordFileWrongFormatted
  | PasswordNotSatistying
  | DeleteActionAbort

exception CithareError of cithare_error

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

let missing_expecting_when missing when_set =
  CithareError (MissingExpectedWhen (missing, when_set))
