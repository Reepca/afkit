#!/bin/sh
gcc -o xlib.fsx xlib-fsi.c
./xlib.fsx -gforth     > xlib-gforth.f
./xlib.fsx -vfx        > xlib-vfx.f
./xlib.fsx -swiftforth > xlib-sf.f
