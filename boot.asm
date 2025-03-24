; bootloader.asm
bits 16
org 0x7c00

start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INIT & Control
    ; Control flow
    call keypress


    mov al, [flag0]
    cmp al, 1
    je launch
    inc al
    mov [flag0], al
    ; Initialize the stack pointer (SP) 
    mov ax, 0
    mov ss, ax
    mov sp, 0x9000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUILD

    mov si, 0
build:
    mov ax, [biread + si]           ; BIOS function to read sectors - Number of sectors to read
    mov cx, [cylins + si]           ; Cylinder - Sector
    mov dh, 0                       ; Head
    mov bx, [address + si]          ; Destination buffer
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang
    add si, 2
    cmp si, 8
    jne build 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EXEC

launch:
    mov si, [tracker]
    mov al, 2
    add [tracker], al
    jmp [address + si]


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

EOF:
    jmp $

error_msg db 'Disk read error!', 13, 10, 0
tracker dw 0
biread dw 0x0201 , 0x0201 , 0x0201 , 0x0208
address dw 0x7c00 + 512 * 2 , 0x7c00 + 512 * 3 , 0x7c00 + 512 * 4 , 0x7c00 + 512 * 5
cylins dw 0x0002 , 0x0003 , 0x0004 , 0x0005
flag0 db 0
; ======================================================================
; Bootloader Signature Block
; ======================================================================
signature_start:
    db "bootloader v0.1"                ; OS name and version
    db " - Created by Nikita Konkov" ; Author information
    db " - Build date: 03/23/2025" ; Build date
    db 0                           ; Null terminator
    
times 506-($-$$) db 0       ; Fill the rest of the boot sector with zeros
dw 0xd400,0xd400               ; Checksum
dw 0xaa55                   ; Boot signature (0xAA55)