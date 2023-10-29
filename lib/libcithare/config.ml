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
let version =
  match Build_info.V1.version () with
  | Some s ->
      Build_info.V1.Version.to_string s
  | None ->
      "[n/a]"

let cithare_name = "cithare"
let password_file = ".citharerc"
let cithare_env_save_state = "CITHARE_SAVE_STATE"
let ( / ) = Filename.concat
let xdg = Xdg.create ~env:Sys.getenv_opt ()
let xdg_data = Xdg.data_dir xdg
let xdg_config = Xdg.config_dir xdg
let xdg_state = Xdg.state_dir xdg
let cithare_share_dir = xdg_data / cithare_name
let cithare_state_dir = xdg_state / cithare_name

(**
   [$XDG_DATA_HOME/share/cithare/.citharerc]
*)
let cithare_password_file = cithare_share_dir / password_file

let cithare_save_state () =
  cithare_env_save_state |> Sys.getenv_opt
  |> Option.map (fun s ->
         let s = String.lowercase_ascii s in
         match s with "no" | "false" | "0" -> false | _ -> true
     )
  |> Option.value ~default:true
