#!/bin/bash

# Assemble the bootloader
nasm -f bin -o bin/bootloader.bin bootloader.asm

# Assemble the os stage
nasm -f bin -o bin/os.bin os.asm

# Assemble the display stage
nasm -f bin -o bin/display.bin display.asm

# Create a blank floppy disk image 8192 * 512 = 4MB [4.194.304 BYTE]
dd if=/dev/zero of=floppy.img bs=512 count=8192

# Write the bootloader to the first sector
dd if=bin/bootloader.bin of=floppy.img conv=notrunc

# Write the second stage to the second sector
dd if=bin/os.bin of=floppy.img bs=512 seek=1 conv=notrunc


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