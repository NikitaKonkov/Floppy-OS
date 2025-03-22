# Floppy Disk Bootloader Guide

## Understanding Floppy Disk Structure and Sector Access

This README explains how floppy disks are structured, how sectors are accessed in bootloaders, and how to properly set up a multi-stage boot process.

### Floppy Disk Physical Structure

A standard 3.5" 1.44MB floppy disk has the following physical characteristics:

- **Total capacity**: 1.44MB (1,474,560 bytes)
- **Sectors per track**: 18
- **Tracks per side**: 80
- **Sides**: 2
- **Sector size**: 512 bytes
- **Total sectors**: 2,880 (1.44MB ÷ 512 bytes)

### Cylinder-Head-Sector (CHS) Addressing

BIOS uses CHS addressing to access specific sectors on a floppy disk:

- **Cylinder (C)**: Concentric circular tracks on the disk (0-79)
- **Head (H)**: Which side of the disk (0-1)
- **Sector (S)**: Which sector within a track (1-18)

The CHS values map to physical locations on the disk:

```
Sector = (C × Heads × SectorsPerTrack) + (H × SectorsPerTrack) + (S - 1) + 1
```

### BIOS Disk Access (INT 13h)

The primary way to read sectors in a bootloader is using BIOS interrupt 13h:

```asm
mov ah, 0x02        ; Function: read sectors
mov al, N           ; Number of sectors to read
mov ch, C           ; Cylinder number
mov cl, S           ; Sector number (1-based)
mov dh, H           ; Head number
mov dl, DRIVE       ; Drive number (0=A:, 80h=first hard disk)
mov bx, OFFSET      ; Buffer offset
mov es, SEGMENT     ; Buffer segment
int 0x13            ; Call BIOS
```

After the call:
- Carry flag (CF) is set if an error occurred
- AH contains the error code if CF is set
- AL contains the number of sectors actually read

### Linear Sector Addressing

When writing to a disk image with tools like `dd`, we use linear sector numbers:

| Linear Sector | CHS Address | Description |
|---------------|-------------|-------------|
| 0             | 0/0/1       | Boot sector |
| 1             | 0/0/2       | Second sector |
| 2             | 0/0/3       | Third sector |
| ...           | ...         | ... |
| 17            | 0/0/18      | Last sector on first track |
| 18            | 0/1/1       | First sector on second track |

### Memory Map in Boot Process

When developing a bootloader, be aware of this memory layout:

- **0x0000 - 0x04FF**: Interrupt Vector Table and BIOS Data Area
- **0x0500 - 0x7BFF**: Free memory for your use
- **0x7C00 - 0x7DFF**: Bootloader (loaded by BIOS)
- **0x7E00 - 0x9FFFF**: Free memory for your use
- **0xA0000 - 0xFFFFF**: BIOS, video memory, etc.

### Multi-Stage Boot Process

A typical multi-stage boot process works as follows:

1. **Stage 1 (Boot Sector)**:
   - Loaded by BIOS at 0x7C00
   - Limited to 512 bytes (one sector)
   - Responsible for loading Stage 2

2. **Stage 2 (Second Stage Loader)**:
   - Loaded by Stage 1 at a chosen address (e.g., 0x8000)
   - Can be multiple sectors in size
   - Performs more complex initialization
   - Loads the actual OS kernel

3. **Kernel**:
   - Loaded by Stage 2 at a suitable address
   - Takes control of the system

### Example: Loading a Sector in a Bootloader

```asm
; Load sector 2 into memory at 0x8000
mov ax, 0x0000      ; Set ES:BX = 0x0000:0x8000
mov es, ax
mov bx, 0x8000      ; Destination address
    
mov ah, 0x02        ; BIOS read sector function
mov al, 1           ; Number of sectors to read
mov ch, 0           ; Cylinder 0
mov cl, 2           ; Sector 2 (sectors are 1-based)
mov dh, 0           ; Head 0
mov dl, 0           ; Drive 0 (floppy)
int 0x13            ; Call BIOS
```

### Creating a Bootable Floppy Image

To create a bootable floppy image with multiple stages:

1. **Assemble your code**:
   ```bash
   nasm -f bin -o bootloader.bin bootloader.asm
   nasm -f bin -o stage2.bin stage2.asm
   ```

2. **Create an empty floppy image**:
   ```bash
   dd if=/dev/zero of=floppy.img bs=512 count=2880
   ```

3. **Write the bootloader to the first sector**:
   ```bash
   dd if=bootloader.bin of=floppy.img conv=notrunc
   ```

4. **Write the second stage to subsequent sectors**:
   ```bash
   dd if=stage2.bin of=floppy.img bs=512 seek=1 conv=notrunc
   ```

### Calculating Sector Positions

When loading multiple components, you need to track where each one is stored:

1. **Bootloader**: Always at sector 1 (linear sector 0)
2. **Second Stage**: Typically starts at sector 2 (linear sector 1)
3. **Additional Components**: Start at sector (1 + size_of_previous_components)

Example calculation:
- If Stage 2 is 3 sectors long, the next component would start at sector 5 (linear sector 4)
- Calculate using: `start_sector = previous_start + ceiling(previous_size / 512)`

### Common Pitfalls

1. **Sector Numbering**: BIOS uses 1-based sector numbering, while tools like `dd` use 0-based
2. **Segment:Offset Addressing**: Remember physical address = segment × 16 + offset
3. **Stack Setup**: Always set up a proper stack before making function calls
4. **Segment Register Initialization**: Initialize DS, ES, SS at the start of each stage
5. **Error Handling**: Always check for disk read errors and implement retry logic

### Debugging Tips

1. **Print Messages**: Use BIOS INT 10h to print debug messages
2. **Use QEMU Debug Options**: 
   ```bash
   qemu-system-i386 -s -S -fda floppy.img
   ```
3. **Connect with GDB**:
   ```bash
   gdb -ex "target remote localhost:1234" -ex "set architecture i8086"
   ```

### Example Memory Layout for Multi-Stage Boot

| Component | Start Address | Size | Sectors | Linear Sector |
|-----------|--------------|------|---------|---------------|
| Bootloader | 0x7C00 | 512 bytes | 1 | 0 |
| Stage 2 | 0x8000 | 2048 bytes | 4 | 1-4 |
| Kernel | 0x10000 | Variable | Variable | 5+ |

By understanding these concepts, you can create a robust bootloader that properly loads and executes multiple stages from a floppy disk.