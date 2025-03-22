# debug_script.gdb

# Disable pagination
set pagination off

# Connect to the QEMU GDB server
target remote localhost:1234

# Set a breakpoint at the start of the bootloader
break *0x7C00

# Continue execution
c

# Python script to listen for key presses (Windows version)
python
import sys
import os
import msvcrt

# Information about format specifiers and size modifiers
memory_info = """
- **Format Specifiers**: You can specify the format in which you want the memory to be displayed:
  - `x`: hexadecimal
  - `d`: decimal
  - `u`: unsigned decimal
  - `o`: octal
  - `t`: binary
  - `f`: floating point
  - `a`: address
  - `i`: instruction
  - `c`: character
  - `s`: string
  
- **Size Modifiers**: The `x` command supports several size modifiers:
  - `b`: byte (1 byte)
  - `h`: halfword (2 bytes)
  - `w`: word (4 bytes)
  - `g`: giant word (8 bytes)
"""

default_format = "xb"

def wait_for_key():
    """Wait for a single key press."""
    while True:
        if msvcrt.kbhit():
            return msvcrt.getch().decode('utf-8')

def print_menu():
    """Print the command menu."""
    print("<| s: Step Once | r: Show Registers | a: Show All Registers | c: Clear Screen | q: Quit | b: Set Breakpoint | x: Examine Memory | f: Continue |>")

print_menu()

while True:
    key = wait_for_key()

    if key == 's':
        gdb.execute("x/i $pc")
        gdb.execute("si")

    elif key == 'f':
        gdb.execute("continue")

    elif key == 'r':
        gdb.execute("info registers rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 rip cs ss ds es fs gs")

    elif key == 'a':
        gdb.execute("info registers")

    elif key == 'b':
        bp = input("Set breakpoint at address (e.g., 0x7C00): ")
        try:
            if not bp.startswith("0x"):
                bp = "0x" + bp
            gdb.execute("break *" + bp)
        except gdb.error as e:
            print("Error setting breakpoint:", str(e))

    elif key == 'c':
        os.system("cls")

    elif key == 'q':
        break
    
    elif key == 'x':
        print(memory_info)
        print()
        start_address = input("Start address (press Enter for 0x7C00): ")
        if start_address == "":
            start_address = "0x7C00"
        length = input("Length of memory to read: ")
        specify_format = input("Specify format and size? (Y/N): ")
        if specify_format.lower() == "y":
            default_format = input("Enter format and size (e.g., xb): ")
        gdb.execute(f"x/{length}{default_format} {start_address}")

    else:
        print_menu()
end