; os.asm
org 0x7c00 + 512 * 2

; Print a message in real mode
mov si, msg        ; Load message address
call print_string       ; Call print routine









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Checksum Generator & Checker


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







; Return to bootloader
jmp 0x7c00                    ; Return control to the bootloader

; 16-bit function to print a string
print_string:
    ; Initialize segment registers
    xor ax, ax              ; Zero AX register
    mov ds, ax              ; Set DS to 0
    mov es, ax              ; Set ES to 0
    mov ss, ax              ; Set SS to 0
    lodsb               ; Load byte from SI into AL and increment SI
    or al, al           ; Check if AL is 0 (end of string)
    jz .done            ; If zero, we're done
    mov ah, 0x0E        ; BIOS teletype function
    int 0x10            ; Call BIOS
    jmp print_string    ; Repeat for next character
.done:
    ret



msg db 'B0 ', 0
sum db 'CHECKSUM OK ', 0
checksum dw 0
times 512-($-$$) db 0   ; Pad to 510 bytes