#!/bin/sh
gcc -o allegro.fsx allegro-fsi.c
./allegro.fsx -gforth     > allegro-gforth.f
./allegro.fsx -vfx        > allegro-vfx.f
./allegro.fsx -swiftforth > allegro-sf.f
