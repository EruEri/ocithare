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

let draw ?(v_offset = 0) ?(h_offset = 0) (winsize : Cbindings.Winsize.t) items =
  let () = Cbindings.Termove.redraw_empty () in
  let v_offset = max v_offset 0 in
  let h_offset = max h_offset 0 in
  let items = List.filteri (fun i _ -> i + h_offset < winsize.ws_row) items in
  List.iteri
    (fun i line ->
      let strlen = String.length line in
      let maxlen = winsize.ws_col in
      let line =
        match v_offset >= strlen with
        | true ->
            line
        | false ->
            String.sub line v_offset (strlen - v_offset)
      in
      let strlen = String.length line in
      let line = String.sub line 0 (min maxlen strlen) in
      let () = Cbindings.Termove.draw_string line in
      let () = Cbindings.Termove.set_cursor_at (i + 1) 0 in
      ()
    )
    items
