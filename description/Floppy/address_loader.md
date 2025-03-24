# Memory Layout from 0x0000 to 0x7C00

This README explains the memory layout for IBM PC–compatible machines in real mode, covering the address range from 0x0000 to 0x7C00. Each section of memory is described along with its functionality and significance during system boot.

---

## Table of Contents

- [Overview](#overview)
- [Memory Map](#memory-map)
- [Region Details](#region-details)
  - [Interrupt Vector Table (IVT)](#interrupt-vector-table-ivt)
  - [BIOS Data Area (BDA)](#bios-data-area-bda)
  - [Conventional Memory (0x0500–0x7BFF)](#conventional-memory-00500-0x7bff)
  - [Boot Sector (0x7C00–0x7DFF)](#boot-sector-0x7c00-0x7dff)
- [Final Notes](#final-notes)

---

## Overview

During the early stages of booting an IBM PC–compatible system in real mode, the operating system and bootloader must interact with various critical regions of memory. This guide details the layout:

- **0x0000 to 0x03FF:** Interrupt Vector Table (IVT)
- **0x0400 to 0x04FF:** BIOS Data Area (BDA)
- **0x0500 to 0x7BFF:** Conventional (low) Memory
- **0x7C00 to 0x7DFF:** Boot Sector (Bootloader)

Each region is carefully reserved and used by the BIOS or operating system to ensure stability and proper operation during system startup.

---

## Memory Map

| Address Range        | Size                    | Description                          |
|----------------------|-------------------------|--------------------------------------|
| **0x0000–0x03FF**    | 1 KiB (1024 bytes)      | Interrupt Vector Table (IVT)         |
| **0x0400–0x04FF**    | 256 bytes               | BIOS Data Area (BDA)                 |
| **0x0500–0x7BFF**    | ~29.75 KiB (≈31,744 bytes) | Conventional Memory (Low Memory)  |
| **0x7C00–0x7DFF**    | 512 bytes               | Boot Sector (Bootloader)             |

---

## Region Details

### Interrupt Vector Table (IVT)

- **Address Range:** 0x0000–0x03FF  
- **Size:** 1 KiB (1024 bytes)  
- **Functionality:**
  - The IVT is an array of 256 interrupt vectors, where each vector is 4 bytes (2 bytes for segment and 2 bytes for offset).
  - When an interrupt or exception occurs, the CPU multiplies the interrupt number by 4 and uses that location in the IVT to retrieve the address of the corresponding interrupt service routine (ISR).
  - Critical for fast response to hardware interrupts and system exceptions during boot and operation.
  
---

### BIOS Data Area (BDA)

- **Address Range:** 0x0400–0x04FF  
- **Size:** 256 bytes  
- **Functionality:**
  - Contains essential system information provided by the BIOS during POST (Power-On Self-Test).
  - Stores hardware data such as COM port addresses, display settings, equipment flags, and other configuration parameters.
  - BIOS routines reference the BDA to manage hardware during early system initialization.

---

### Conventional Memory (0x0500–0x7BFF)

- **Address Range:** 0x0500–0x7BFF  
- **Size:** Approximately 29.75 KiB (≈31,744 bytes)  
- **Functionality:**
  - This area is generally available for use by the operating system and bootloader after system startup.
  - Often used for temporary buffers, the bootloader’s runtime stack, data structures, and additional code that is loaded during early boot.
  - Though considered "free" or "conventional" memory, some portions may already be reserved by the BIOS for internal usage.

---

### Boot Sector (0x7C00–0x7DFF)

- **Address Range:** 0x7C00–0x7DFF  
- **Size:** 512 bytes  
- **Functionality:**
  - The BIOS loads the first 512-byte sector of the bootable drive (typically the bootloader) into this address.
  - This bootloader is executed from 0x7C00 once the BIOS verifies the boot signature (0x55AA at the end of the sector).
  - The fixed address (0x7C00) is a longstanding convention that ensures the bootloader has a known and safe location to execute without conflicting with other critical system areas.

---

## Final Notes

- **Real Mode Limitations:**  
  In real mode, the CPU is limited to the first 1 MiB of memory. The layout described above is designed to fit within these constraints while providing dedicated areas for the BIOS, bootloader, and early OS initialization.
  
- **Legacy and Compatibility:**  
  Maintaining this memory organization is essential for backward compatibility and for the proper functioning of BIOS routines and legacy software.
  
- **Importance of Each Region:**  
  - The **IVT** ensures quick interrupt servicing.
  - The **BDA** helps the BIOS and OS manage hardware configuration.
  - The **Conventional Memory** provides space for dynamic code and data during boot.
  - The **Boot Sector** is the launchpad for the bootloader and subsequent operating system initialization.

Understanding this layout is crucial for developers working with bootloaders and operating system kernels on legacy or emulated hardware environments.

---