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

default_format = "ib"

def wait_for_key():
    """Wait for a single key press."""
    while True:
        if msvcrt.kbhit():
            return msvcrt.getch().decode('utf-8')

def print_menu():
    """Print the command menu."""
    print("<| s: Step Once | r: Show Registers | a: Show All Registers | c: Clear Screen | q: Quit | b: Set Breakpoint | x: Examine Memory | w: Write Memory | f: Continue |>")
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
    
    elif key == 'm':
        print(memory_info)
        print()
        start_address = input("Start address (press Enter for 0x7C00): ")
        if start_address == "":
            start_address = "0x7C00"
        length = input("Length of memory to read: ")
        specify_format = input("Specify format and size? (Y/N): ")
        if specify_format.lower() == "y":
            default_format = input("Enter format and size (e.g., ib): ")
        gdb.execute(f"x/{length}{default_format} {start_address}")

    elif key == 'w':
        print("Memory Write Function")
        print()
        address = input("Address to write to (e.g., 0x7C00): ")
        if address == "":
            print("Error: Address required")
            continue

        format_info = """
        Available formats:
        - b: byte (1 byte)
        - h: halfword (2 bytes)
        - w: word (4 bytes)
        - g: giant word (8 bytes)
        """
        print(format_info)

        data_format = input("Format (b/h/w/g): ").lower()
        if data_format not in ['b', 'h', 'w', 'g']:
            print("Error: Invalid format")
            continue

        value = input("Value to write (in hex, e.g., 0xFF): ")
        if not value.startswith("0x"):
            value = "0x" + value

        try:
            # Get the inferior (target process)
            inferior = gdb.selected_inferior()

            # Determine size based on format
            size_map = {'b': 1, 'h': 2, 'w': 4, 'g': 8}
            size = size_map[data_format]

            # Convert value to bytes
            int_value = int(value, 16)
            byte_value = int_value.to_bytes(size, byteorder='little')

            # Write to memory
            inferior.write_memory(int(address, 16), byte_value)

            # Verify the write by reading back
            written = inferior.read_memory(int(address, 16), size)
            print(f"Successfully wrote to memory. Verification: {written.tobytes().hex()}")

            # Show the instruction at this address if it might be code
            try:
                gdb.execute(f"x/i {address}")
            except:
                pass

        except Exception as e:
            print(f"Error writing to memory: {str(e)}")

    else:
        print_menu()
end