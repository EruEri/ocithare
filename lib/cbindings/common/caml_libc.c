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


#include "caml/alloc.h"
#include "caml/memory.h"
#include "caml/misc.h"
#include "caml/mlvalues.h"
#include <string.h>
#include <unistd.h>

// string -> string option
CAMLprim value caml_getpass(value caml_prompt) {
    CAMLparam1(caml_prompt);
    CAMLlocal2(caml_pass, ret);
    const char* prompt = String_val(caml_prompt);
    const char* pass = getpass(prompt);
    if (pass == NULL) {
        ret = Val_none;
    } else {
        size_t len = strlen(pass);
        caml_pass = caml_copy_string(pass);
        memset((void *) pass, 0, len);
        ret = caml_alloc(1, 0);
        Store_field(ret, 0, caml_pass);
    }

    CAMLreturn(ret);
}