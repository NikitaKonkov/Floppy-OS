### Loading Code from Floppy to RAM

1. **Bootloader Stage:**
   - **Initial Load:** The BIOS loads the first sector (512 bytes) of the bootable floppy disk into memory at address `0x7C00`. This sector is known as the boot sector and contains the bootloader.
   - **Execution:** The BIOS then transfers control to the bootloader by jumping to `0x7C00`.

2. **Bootloader Responsibilities:**
   - **Setup:** The bootloader sets up the CPU environment, including initializing the stack pointer and enabling the A20 line if necessary.
   - **Loading Additional Code:** The bootloader reads additional sectors from the floppy disk into RAM. This typically includes:
     - **Kernel:** The main part of the operating system, which is loaded into a higher memory address (e.g., `0x10000`).
     - **Other Components:** Additional components like display and input handlers may also be loaded into specific memory locations.
   - **Transition:** Once the necessary components are loaded, the bootloader transfers control to the kernel or the next stage of the boot process.

3. **Kernel and Other Components:**
   - **Execution in RAM:** Once loaded into RAM, the kernel and other components execute from there. They do not need to be "unloaded" in the traditional sense, as they remain in RAM for the duration of their execution.
   - **Resource Management:** The kernel is responsible for managing memory and other resources, including loading additional modules or drivers if needed.

### Unloading Code

- **Unloading in Traditional Sense:** In the context of a simple bootloader and kernel, "unloading" isn't typically necessary. Once code is loaded into RAM, it stays there until the system is powered off or reset.
- **Dynamic Loading/Unloading:** More advanced operating systems may support dynamic loading and unloading of modules or drivers, but this is managed by the kernel and not typically part of the initial boot process.

### Summary

- **Loading:** The bootloader is responsible for loading the necessary code from the floppy disk into RAM.
- **Execution:** Once in RAM, the code executes directly from there.
- **Unloading:** In a simple bootloader/kernel setup, unloading isn't typically required. More advanced systems may handle dynamic loading/unloading of components as needed.

This process is fundamental to booting an operating system from a floppy disk, and understanding it is crucial for developing your own bootloader or operating system.