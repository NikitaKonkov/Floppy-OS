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
# Assemble the os stage
nasm -f bin -o bin/B0.bin B0.asm
# Assemble the display stage
nasm -f bin -o bin/B1.bin B1.asm
# Assemble the display stage
nasm -f bin -o bin/B2.bin B2.asm


# Create a blank floppy disk image 2880 * 512 = 1.44MB
dd if=/dev/zero of=floppy.img bs=512 count=2880


# Write the bootloader to the first sector
dd if=bin/bootloader.bin of=floppy.img conv=notrunc
# Write the second stage to the second sector
dd if=bin/B0.bin of=floppy.img bs=512 seek=1 conv=notrunc
# Write the third stage to the third sector
dd if=bin/B1.bin of=floppy.img bs=512 seek=2 conv=notrunc
# Write the third stage to the third sector
dd if=bin/B2.bin of=floppy.img bs=512 seek=3 conv=notrunc


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