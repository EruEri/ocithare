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

external enable_raw_mode : unit -> unit = "caml_enable_raw_mode"
external disable_raw_mode : unit -> unit = "caml_disable_raw_mode"
external enable_canonic : unit -> unit = "caml_enable_canonic"
external disable_canonic : unit -> unit = "caml_disable_canonic"

let seq_new_screen_buf = "\u{001B}[?1049h\u{001B}[H"
let seq_end_screen_buf = "\u{001B}[?1049l"
let seq_clear_saved_line = "\u{001B}[3J"
let seq_clear_screen = "\u{001B}[2J"
let clear_console = "\u{001B}[2J"
let upper_left_corner = "┌"
let upper_right_corner = "┐"
let lower_left_corner = "└"
let lower_right_corner = "┘"
let horizontal_line = "─" (* "─" != '-' *)
let vertical_line = "│"
let set_cursor_at = Printf.printf "\u{001B}[%u;%uf%!"
let move_down = Printf.printf "\u{001B}[%uB%!"
let clear () = Printf.printf "%s%!" clear_console
let draw_vertical_line () = Printf.printf "%s%!" vertical_line
let draw_horizontal_line () = Printf.printf "%s%!" horizontal_line
let move_forward_column = Printf.printf "\u{001B}[%uC%!"
let draw_string = Printf.printf "%s%!"
let draw_char = Printf.printf "%c%!"
let set_cursor_next_line line = set_cursor_at (line + 1) 0
let hide_cursor () = Printf.printf "\u{001B}[?25l"
let show_cursor () = Printf.printf "\u{001B}[?25h"
let ascii_color_reset = "\u{001B}[0m"

let sprintf color s =
  Printf.sprintf "\u{001B}[%um%s%s" color s ascii_color_reset

let fg_red = 31
let fg_yellow = 33
let fg_magenta = 35
let sprintf_red s = sprintf fg_red s

let rec draw_line length s =
  match length with
  | n when n <= 0 ->
      ()
  | n ->
      let () = draw_string s in
      draw_line (n - 1) s

let draw_top_line length =
  let () = draw_string upper_left_corner in
  let () = draw_line length vertical_line in
  let () = draw_string upper_right_corner in
  ()

let redraw_empty () =
  let () = draw_string seq_clear_saved_line in
  let () = draw_string seq_clear_screen in
  let () = set_cursor_at 0 0 in
  ()

let start_window () =
  let () = enable_raw_mode () in
  Printf.printf "%s%!" seq_new_screen_buf

let end_window () =
  let () = Printf.printf "%s%!" seq_end_screen_buf in
  let () = disable_raw_mode () in
  ()
