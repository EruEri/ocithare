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


#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "caml/misc.h"
#include "caml/mlvalues.h"
#include "caml/memory.h"

CAMLprim value caml_set_pastboard_content(value string) {
    CAMLparam1(string);
    CAMLlocal1(ret);
    const char* content = String_val(string);
    NSString* s = [NSString stringWithUTF8String:content];
    NSPasteboard* pasterboard = [NSPasteboard generalPasteboard];
    BOOL b = [pasterboard setString:s forType:NSPasteboardTypeString];

    // It can be simplifity but since it 2 differente language
    // I prefer the explicit way
    ret =  b ? Val_true : Val_false;
    CAMLreturn(ret); 
}