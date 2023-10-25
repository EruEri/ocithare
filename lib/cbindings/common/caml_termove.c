// /////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                            //
// This file is part of ocithare: a commandline password manager                              //
// Copyright (C) 2023 Yves Ndiaye                                                             //
//                                                                                            //
// ocithare is free software: you can redistribute it and/or modify it under the terms        //
// of the GNU General Public License as published by the Free Software Foundation,            //
// either version 3 of the License, or (at your option) any later version.                    //
//                                                                                            //
// ocithare is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;      //
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           //
// PURPOSE.  See the GNU General Public License for more details.                             //
// You should have received a copy of the GNU General Public License along with ocithare.     //
// If not, see <http://www.gnu.org/licenses/>.                                                //
//                                                                                            //
// /////////////////////////////////////////////////////////////////////////////////////////////

#include "caml/memory.h"
#include "caml/mlvalues.h"
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>

const char* NEW_SCREEN_BUFF_SEQ = "\033[?1049h\033[H";
const char* END_SRCEEN_BUFF_SEQ = "\033[?1049l";


struct termios raw;
struct termios orig_termios;

void enableRawMode() {
    tcgetattr(STDIN_FILENO, &orig_termios);
    raw = orig_termios;
    raw.c_lflag &= ~(ECHO | ICANON);
    // raw.c_lflag &= ~(ICANON);
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void disableCanonic() {
    raw.c_lflag &= ~(ICANON);
}

void enableCanonic() {
    raw.c_lflag |= ICANON;
}

void disableRawMode() {
  raw.c_lflag |= (ECHO | ICANON);  
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

CAMLprim value caml_enable_raw_mode(value unit) {
    CAMLparam1(unit);
    enableRawMode();
    CAMLreturn(unit);
}

CAMLprim value caml_disable_raw_mode(value unit) {
    CAMLparam1(unit);
    disableRawMode();
    CAMLreturn(unit);
}

CAMLprim value caml_enable_canonic(value unit) {
    CAMLparam1(unit);
    enableCanonic();
    CAMLreturn(unit);
}

CAMLprim value caml_disable_canonic(value unit) {
    CAMLparam1(unit);
    disableCanonic();
    CAMLreturn(unit);
}