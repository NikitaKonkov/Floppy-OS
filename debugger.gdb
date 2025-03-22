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

# Python script to listen for key presses (Windows version)
python
import sys
import os
import msvcrt

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

    else:
        print("<| s : step_once | r : show_register | a : show_all_register | c : cls | q : quit | b : set_break |>")
end