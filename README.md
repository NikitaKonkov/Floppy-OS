# Floppy OS Bootloader Project

This project demonstrates a multi-stage bootloader for a floppy disk image. It includes a bootloader and additional stages that are loaded sequentially from the floppy disk. The project is designed to run on an emulated x86 environment using QEMU and can be built and debugged using the MSYS2 UCRT64 environment.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Setup Instructions](#setup-instructions)
5. [Building the Project](#building-the-project)
6. [Running the Bootloader](#running-the-bootloader)
7. [Debugging with GDB](#debugging-with-gdb)
8. [File Structure](#file-structure)
9. [How It Works](#how-it-works)
10. [Acknowledgments](#acknowledgments)

---

## Project Overview

This project implements a bootloader for a floppy disk image. The bootloader is responsible for loading and executing additional stages from the disk. Each stage performs specific tasks, such as displaying messages or performing operations, and then returns control to the bootloader.

The project is written in x86 assembly and is designed to run in real mode. It uses BIOS interrupts for disk I/O and screen output.

---

## Features

- Multi-stage bootloader:
  - **Stage 1 (Bootloader):** Loads subsequent stages from the floppy disk.
  - **Stage 2 (OS Stage):** Displays a message (`B0`).
  - **Stage 3 (Display Stage):** Displays another message (`B1`).
  - **Stage 4 (Dword Stage):** Demonstrates memory operations (`B2`).
- Floppy disk image creation and management.
- Debugging support using QEMU and GDB.
- Modular assembly code for easy customization.

---

## Requirements

To build and run this project, you need the following tools:

1. **MSYS2 UCRT64 Environment**:
   - Install MSYS2 from [https://www.msys2.org/](https://www.msys2.org/).
   - Use the `ucrt64` environment for compatibility with QEMU.

2. **NASM (Netwide Assembler)**:
   - Install NASM using the MSYS2 package manager:
     ```bash
     pacman -S nasm
     ```

3. **QEMU**:
   - Install QEMU using the MSYS2 package manager:
     ```bash
     pacman -S qemu
     ```

4. **GDB (GNU Debugger)**:
   - Install GDB using the MSYS2 package manager:
     ```bash
     pacman -S gdb
     ```

---

## Setup Instructions

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-repo/floppy-os.git
   cd floppy-os
   ```

2. Ensure the `build.sh` script is executable:
   ```bash
   chmod +x build.sh
   ```

3. Install the required tools as mentioned in the [Requirements](#requirements) section.

---

## Building the Project

To build the project, run the `build.sh` script:

```bash
build.sh
```

This script performs the following steps:
- Assembles the bootloader and stages (`B0.asm`, `B1.asm`, `B2.asm`) using NASM.
- Creates a blank floppy disk image (`floppy.img`).
- Writes the bootloader and stages to the floppy disk image.

---

## Running the Bootloader

To run the bootloader in QEMU, use the following command:

```bash
build.sh -n
```

This will launch QEMU and boot the floppy disk image (`floppy.img`). You should see the bootloader and subsequent stages execute sequentially.

---

## Debugging with GDB

To debug the bootloader using GDB, follow these steps:

1. Start QEMU in debug mode:
   ```bash
   ./build.sh -d
   ```

2. Open a new terminal and connect GDB to QEMU:
   ```bash
   gdb -x debugger.gdb
   ```

3. Use the GDB commands defined in `debugger.gdb` to step through the code, examine memory, and set breakpoints.

---

## File Structure

Here is an overview of the project's file structure:

```
.
├── bootloader.asm       # Bootloader code
├── B0.asm               # OS stage
├── B1.asm               # Display stage
├── B2.asm               # Dword stage
├── build.sh             # Build script
├── floppy.img           # Floppy disk image (generated)
├── bin/                 # Compiled binary files
├── debugger.gdb         # GDB script for debugging
├── sc.py                # CHS to linear sector calculator
├── description/         # Documentation files
└── README.md            # Project documentation
```

---

## How It Works

1. **Bootloader**:
   - The BIOS loads the bootloader from the first sector of the floppy disk into memory at `0x7C00`.
   - The bootloader initializes the stack and loads the next stage from the disk.

2. **Stages**:
   - Each stage is loaded into memory by the bootloader and executed.
   - After execution, control is returned to the bootloader.

3. **Disk Layout**:
   - The floppy disk image is divided into sectors:
     - Sector 0: Bootloader
     - Sector 1: OS Stage (`B0`)
     - Sector 2: Display Stage (`B1`)
     - Sector 3: Dword Stage (`B2`)

4. **Debugging**:
   - QEMU emulates the x86 environment, and GDB is used to debug the bootloader and stages.

---

## Acknowledgments

This project was created by Nikita Konkov as a learning exercise in x86 assembly and bootloader development. It is inspired by the structure and functionality of legacy bootloaders used in early operating systems.