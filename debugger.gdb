# debug_script.gdb

# Disable pagination
set pagination off

# Connect to the QEMU GDB server
target remote localhost:1234

# Set a breakpoint at the start of the bootloader
break *0x7C00

# Continue
c

# Define a command to step one instruction
define step_once
x/i $pc
si
end

# Define a command to print register status
define show_register
# Print only general purpose registers (not MMX/floating point)
info registers rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 rip cs ss ds es fs gs
end
define show_all_register
# Print all registers
info registers
end

# Read RAM from position A to B
define ram_read
    x/8xg 0x7C00
end
# To read memory in GDB, you can specify the size of the memory units you want to read. The `x` command in GDB allows you to specify the format and size of the memory units. By default, if you don't specify a size, GDB assumes a word size, which is typically 4 bytes on a 32-bit system or 8 bytes on a 64-bit system. However, you can explicitly specify the size you want to read using the size modifiers.

# ### Key Points to Consider for reading RAM
# 
# - **Size Modifiers**: The `x` command supports several size modifiers:
#   - `b`: byte (1 byte)
#   - `h`: halfword (2 bytes)
#   - `w`: word (4 bytes)
#   - `g`: giant word (8 bytes)
# 
# - **Format Specifiers**: You can also specify the format in which you want the memory to be displayed:
#   - `x`: hexadecimal
#   - `d`: decimal
#   - `u`: unsigned decimal
#   - `o`: octal
#   - `t`: binary
#   - `f`: floating point
#   - `a`: address
#   - `i`: instruction
#   - `c`: character
#   - `s`: string

# Python script to listen for key presses (Windows version)
python
import sys
import os
import msvcrt

ram_set = """
- **Size Modifiers**: The `x` command supports several size modifiers:
  - `b`: byte (1 byte)
  - `h`: halfword (2 bytes)
  - `w`: word (4 bytes)
  - `g`: giant word (8 bytes)

- **Format Specifiers**: You can also specify the format in which you want the memory to be displayed:
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
"""

format_spec = "xb"

def wait_for_key():
    # Wait for a single key press.
    while True:
        if msvcrt.kbhit():
            return msvcrt.getch().decode('utf-8')

print("<| s : step_once | r : show_register | a : show_all_register | c : cls | q : quit | b : set_break |>")

while True:
    key = wait_for_key()

    if key == 's':
        gdb.execute("step_once")

    elif key == 'f':
        gdb.execute("c")

    elif key == 'r':
        gdb.execute("show_register")

    elif key == 'a':
        gdb.execute("show_all_register")

    elif key == 'b':
        bp = input("set breakpoint: ")
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
        print(ram_set)
        print()
        ram_a = input("start address eg., 0x7C00: ")
        ram_b = input("length address read: ")
        n_0 = input("specify format and size? Y/N: ")
        if n_0 in ["Y","y"]:
            format_spec = input("eg., xb: ")
        # REF x/8xg 0x7C00
        gdb.execute("x/"+ ram_b + format_spec + " " + ram_a)

    else:
        print("<| s : step_once | r : show_register | a : show_all_register | c : cls | q : quit | b : set_break |>")
end




