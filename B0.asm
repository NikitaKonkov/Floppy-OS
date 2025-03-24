; os.asm
org 0x7c00 + 512 * 2

; Print a message in real mode
mov si, msg        ; Load message address
call print_string       ; Call print routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CHECK GENERATOR

pusha

mov si, 0x7c00
mov ax, 0
mov bx, 0
mov cx, 254
generate:
    lodsw  
    xor bx, ax
    loop generate
mov [hash], bx
popa

; Example value in AX
mov ax, [hash]
call print_hex
mov ax, [hash]
cmp ax, [checksums]
jne exit
mov si, sum        ; Load message address
call print_string       ; Call print routine
; Infinite loop to halt the program


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

exit:
; Return to bootloader
jmp 0x7c00                    ; Return control to the bootloader

; 16-bit function to print a string
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

print_hex:
    pusha                   ; Save all registers
    mov cx, 4               ; We have 4 nibbles to process
    mov dx, ax              ; Save original value in DX
print_hex_loop:
    rol dx, 4               ; Rotate left to bring the next nibble into the lowest 4 bits
    mov ax, dx              ; Copy to AX for processing
    and ax, 0x000F          ; Mask to get only the lowest 4 bits (one nibble)
    cmp al, 9               ; Convert nibble to ASCII
    jbe print_hex_digit
    add al, 'A' - 10        ; Convert to 'A'-'F'
    jmp print_hex_char
print_hex_digit:
    add al, '0'             ; Convert to '0'-'9'
print_hex_char:
    mov ah, 0x0E            ; BIOS teletype function
    int 0x10                ; Print character in AL
    loop print_hex_loop     ; Repeat for all nibbles
    mov al, ' '             ; Print a space after the hex value
    mov ah, 0x0E
    int 0x10
    popa                    ; Restore all registers
    ret


msg db 'B0 ', 0
sum db 'CHECKSUM OK ', 0
checksums dw 0x3C1C
hash dw 0x0000
times 512-($-$$) db 0   ; Pad to 510 bytes