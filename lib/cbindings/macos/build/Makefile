OCAML_HEADER=$(shell ocamlc -where)
LIBNAME=libmacos.a
CC=cc
AR=ar
C_FLAGS=-Wall -fPIC -O2 -objc
# C_LIBS=-framework AppKit -framework Foundation

all: libmacos.a

libmacos.a: caml_macos.o
	$(AR) rcs $@ $<

# libmacos.dylib: caml_macos.o
# 	$(CC) -I$(OCAML_HEADER) $(C_FLAGS) $(C_LIBS) -dynamiclib -o $@ $<

caml_macos.o: caml_macos.m
	$(CC) -I$(OCAML_HEADER) $(C_FLAGS) $(C_LIBS) -c -o $@ $<