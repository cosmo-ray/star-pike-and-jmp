#!/bin/sh
sed s/int\ 0x20/jmp\ init/g $1.asm > $1.tmp.asm
nasm -f bin $1.tmp.asm -l $1.lst -o $1.img
