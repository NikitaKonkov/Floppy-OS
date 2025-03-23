#!/bin/bash

## Naming
# bootloader.asm
# B0.asm
# B1.asm
# B2.asm

# Clear bin folder and delete floppy.img file
rm -f floppy.img
rm -f bin/*


# Assemble the bootloader
nasm -f bin -o bin/bootloader.bin bootloader.asm
# B0
nasm -f bin -o bin/B0.bin B0.asm
# B1
nasm -f bin -o bin/B1.bin B1.asm
# B2
nasm -f bin -o bin/B2.bin B2.asm
# B3
nasm -f bin -o bin/B3.bin B3.asm


# Create a blank floppy disk image 2880 * 512 = 1.44MB
dd if=/dev/zero of=floppy.img bs=512 count=2880


# Write the bootloader to the first sector
dd if=bin/bootloader.bin of=floppy.img conv=notrunc
# B0
dd if=bin/B0.bin of=floppy.img bs=512 seek=1 conv=notrunc
# B1
dd if=bin/B1.bin of=floppy.img bs=512 seek=2 conv=notrunc
# B2
dd if=bin/B2.bin of=floppy.img bs=512 seek=3 conv=notrunc
# B3
dd if=bin/B3.bin of=floppy.img bs=512 count=8 seek=4 conv=notrunc

if [ "$1" == "-d" ]; then
  echo "Building debug version..."

  qemu-system-x86_64 -s -S -drive format=raw,file=floppy.img -icount shift=1 &

  # Wait a moment to ensure QEMU has started
  sleep 2 

  # Launch another MSYS2 terminal and run GDB with the script
  mintty -e gdb -x debugger.gdb


elif [ "$1" == "-n" ]; then
  echo "Building non-debug version..."
  qemu-system-x86_64 -drive format=raw,file=floppy.img -icount shift=1

  
else
  echo "Invalid argument. Use '-d' or '-n'."
  exit 1
fi