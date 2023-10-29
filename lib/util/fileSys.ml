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

(**
    [file_exists path] checks if the file at [path] exists and is a file and not a directory
*)
let file_exists path =
  match Sys.file_exists path with
  | false ->
      false
  | true ->
      not @@ Sys.is_directory path

(**
    [dir_exists path] checks if the file at [path] exists and is a directory
*)
let dir_exists path =
  match Sys.file_exists path with
  | false ->
      false
  | true ->
      Sys.is_directory path

(**
    [mkdirp root componenent] creates directories which start at [root] and recursively [componenent]
*)
let rec mkdirp root componenent =
  let ( let* ) = Result.bind in
  let ok = Result.ok in
  let err = Result.error in
  match componenent with
  | [] ->
      ok ()
  | t :: q ->
      let path = Filename.concat root t in
      let* () =
        match dir_exists path with
        | true ->
            ok ()
        | false -> (
            match Sys.mkdir path 0o755 with
            | () ->
                ok ()
            | exception _ ->
                err path
          )
      in
      mkdirp path q

let mkfilep root componenent file =
  let ( let* ) = Result.bind in

  let* () = mkdirp root componenent in
  let path = List.fold_left Filename.concat root componenent in
  let path = Filename.concat path file in
  try
    let chan = Out_channel.open_text path in
    let () = close_out chan in
    Ok ()
  with _ -> Error path
