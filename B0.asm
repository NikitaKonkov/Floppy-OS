;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ADDRESS
org 0x7c00 + 512 * 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TEST PRINT
    mov si, msg                ; Load message address
    call print_string          ; Call print routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CHECKSUM
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
    mov ax, [hash]
    call print_hex
    mov ax, [hash]
    cmp ax, [0x7c00+508]
    jne exit

    mov si, ok                ; Load message address
    call print_string          ; Call print routine

    exit:
    jmp 0x7c00                 ; Return control to the bootloader
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCTIONS
print_string:                  ; mov si, STRING TO PRINT
    push ax
    mov ah, 0x0E               ; BIOS teletype function
pchar:
    lodsb                      ; Load byte from SI into AL and increment SI
    or al, al                  ; Check if AL is 0 (end of string)
    jz done                    ; If zero, we're done
    int 0x10                   ; Call BIOS
    jmp pchar                  ; Repeat for next character
done:
    pop ax
    ret

print_hex:
    pusha                      ; Save all registers
    mov cx, 4                  ; We have 4 nibbles to process
    mov dx, ax                 ; Save original value in DX
print_hex_loop:
    rol dx, 4                  ; Rotate left to bring the next nibble into the lowest 4 bits
    mov ax, dx                 ; Copy to AX for processing
    and ax, 0x000F             ; Mask to get only the lowest 4 bits (one nibble)
    cmp al, 9                  ; Convert nibble to ASCII
    jbe print_hex_digit
    add al, 'A' - 10           ; Convert to 'A'-'F'
    jmp print_hex_char
print_hex_digit:
    add al, '0'                ; Convert to '0'-'9'
print_hex_char:
    mov ah, 0x0E               ; BIOS teletype function
    int 0x10                   ; Print character in AL
    loop print_hex_loop        ; Repeat for all nibbles
    mov al, ' '                ; Print a space after the hex value
    mov ah, 0x0E
    int 0x10
    popa                       ; Restore all registers
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA
msg db 'B0 ', 0x0D, 0x0A, 0
ok db ' OK', 0x0D, 0x0A, 0
hash dw 0x0000
;;;;;;;;;;;; BOOT  ; STACK       ; CHECKSUM        ; B1              ; B2
addresses dw 0x7c00, 0x7c00 + 512, 0x7c00 + 512 * 2, 0x7c00 + 512 * 3, 0x7c00 + 512 * 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EOF
times 508-($-$$) db 0          ; Pad to 510 bytes
dw 0xE4D5
dw 0xE4D5