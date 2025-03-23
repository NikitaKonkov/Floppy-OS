; bootloader.asm
bits 16
org 0x7c00

start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INIT
    ; Control flow
    call keypress
    mov al, [tracker]
    cmp al, 0
    je B0
    cmp al, 1
    je B1
    cmp al, 2
    je B2
    cmp al, 3
    je B3

    ; Initialize the stack pointer (SP) 
    mov ax, 0
    mov ss, ax
    mov sp, 0x9000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; B0.asm
    B0:
    mov al, 1
    add [tracker], al
    
    mov ah, 0x02                    ; BIOS function to read sectors
    mov al, 1                       ; Number of sectors to read [1]
    mov ch, 0                       ; Cylinder
    mov cl, 2                       ; Sector [2]
    mov dh, 0                       ; Head
    mov bx, 0x7c00 + 512 * 1        ; Destination buffer
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang

    jmp 0x7c00 + 512 * 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; B1.asm
    B1:
    mov al, 1
    add [tracker], al

    mov ah, 0x02                    ; BIOS function to read sectors
    mov al, 1                       ; Number of sectors to read [1]
    mov ch, 0                       ; Cylinder
    mov cl, 3                       ; Sector [3]
    mov dh, 0                       ; Head
    mov bx, 0x7c00 + 512 * 2        ; Destination buffer
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang

    jmp 0x7c00 + 512 * 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; B2.asm
    B2:
    mov al, 1
    add [tracker], al

    mov ah, 0x02                    ; BIOS function to read sectors
    mov al, 1                       ; Number of sectors to read [1]
    mov ch, 0                       ; Cylinder
    mov cl, 4                       ; Sector [4]
    mov dh, 0                       ; Head
    mov bx, 0x7c00 + 512 * 3        ; Destination buffer
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang

    jmp 0x7c00 + 512 * 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; B3.asm
    B3:
    mov al, 1
    add [tracker], al

    mov ah, 0x02                    ; BIOS function to read sectors
    mov al, 8                       ; Number of sectors to read [8]
    mov ch, 0                       ; Cylinder
    mov cl, 5                       ; Sector [5]
    mov dh, 0                       ; Head
    mov bx, 0x7c00 + 512 * 4        ; Destination buffer
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang
    
    jmp 0x7c00 + 512 * 4

jmp EOF

disk_error:
    mov si, error_msg
    call print_string
    jmp EOF      

keypress:
    mov ah, 0x00            ; BIOS function to wait for a key press
    int 0x16                ; BIOS interrupt for keyboard services
    ret

print_string:
    push ax
    mov ah, 0x0E        ; BIOS teletype function
.loop:
    lodsb               ; Load byte from SI into AL and increment SI
    or al, al           ; Check if AL is 0 (end of string)
    jz .done            ; If zero, we're done
    int 0x10            ; Call BIOS
    jmp .loop           ; Repeat for next character
.done:
    pop ax
    ret

error_msg db 'Disk read error!', 13, 10, 0

tracker db 0


EOF:
    jmp $

; ======================================================================
; Bootloader Signature Block
; ======================================================================
signature_start:
    db "bootloader v0.1"                ; OS name and version
    db " - Created by Nikita Konkov" ; Author information
    db " - Build date: 03/23/2025" ; Build date
    db 0                           ; Null terminator
    
times 506-($-$$) db 0       ; Fill the rest of the boot sector with zeros
dd 0xB2775FD9               ; Checksum
dw 0xaa55                   ; Boot signature (0xAA55)