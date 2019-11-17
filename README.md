small boot sector game in 8086 asm

you can either play this game as a dosbox game using
the com file or as a boot sector game using img file

# compiling for dosbox:

./compile.sh jumper

# compiling as boot sector:

./compile-img.sh jumper

# start with qemu:

qemu-system-x86_64 -fda jumper.img -full-screen

# start with dosbox:

dosbox jumper.com

# NOTE:

I've just recently learn asm, thanks to "PROGRAMING BOOT SECTOR GAME" book by OSCAR TOLEDO G.
