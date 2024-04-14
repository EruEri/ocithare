(**********************************************************************************************)
(*                                                                                            *)
(* This file is part of ocithare: a commandline password manager                              *)
(* Copyright (C) 2024 Yves Ndiaye                                                             *)
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
