;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BITS & ADDR
bits 16
org 0x7c00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CTRL & INIT
    call keypress                  ; Control flow
    mov al, [flag0]
    cmp al, 1
    je launch
    inc al
    mov [flag0], al
    mov ax, 0
    mov ss, ax
    mov sp, 0xF000                 ; Initialize the stack pointer (SP) 512 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUILDER
    mov si, 0
build:
    mov ax, [biread + si]          ; BIOS function to read sectors - Number of sectors to read
    mov cx, [cylins + si]          ; Cylinder - Sector
    mov dh, 0                      ; Head
    mov bx, [address + si]         ; Destination buffer
    int 0x13                       ; BIOS interrupt to read from disk
    jc disk_error                  ; If carry flag is set, print error message and hang
    add si, 2
    cmp si, [blocks]
    jne build 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EXECUTER
launch:
    mov si, [tracker]
    mov al, 2
    add [tracker], al
    jmp [address + si]
jmp EOF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCTIONS
disk_error:
    mov si, error_msg
    call print_string
    jmp EOF      

keypress:
    mov ah, 0x00                   ; BIOS function to wait for a key press
    int 0x16                       ; BIOS interrupt for keyboard services
    ret

print_string:                      ; mov si, STRING TO PRINT
    push ax
    mov ah, 0x0E                   ; BIOS teletype function
pchar:
    lodsb                          ; Load byte from SI into AL and increment SI
    or al, al                      ; Check if AL is 0 (end of string)
    jz done                        ; If zero, we're done
    int 0x10                       ; Call BIOS
    jmp pchar                      ; Repeat for next character
done:
    pop ax
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA
blocks      dw 12
tracker     dw 0
flag0       db 0
biread      dw 0x0201           , 0x0201           , 0x0201           , 0x0202           , 0x0202           , 0x0202
cylins      dw 0x0002           , 0x0003           , 0x0004           , 0x0005           , 0x0007           , 0x0009
address     dw 0x7c00 + 512 * 2 , 0x7c00 + 512 * 3 , 0x7c00 + 512 * 4 , 0x7c00 + 512 * 5 , 0x7c00 + 512 * 7 , 0x7c00 + 512 * 9
error_msg   db 'Disk read error!', 0x0D, 0x0A, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SIGNATUR
db "bootloader v0.3"               ; Name and version
db "- Created by Nikita Konkov"    ; Author information
db "- Build date: 03/23/2025"      ; Build date
db 0                               ; Null terminator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EOF
EOF:
    jmp $
times 508-($-$$) db 0              ; Fill the rest of the boot sector with zeros
dw 0x3C7C                          ; Checksum
dw 0xaa55                          ; Boot signature (0xAA55)