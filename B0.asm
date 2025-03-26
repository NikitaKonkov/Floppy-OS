;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ADDRESS
org 0x7c00 + 512 * 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TEST PRINT
    mov si, msg                ; Load message address
    call print_string          ; Call print routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CHECKSUM
pusha
cld
mov si, 0x7C00
mov cx, 254                    ; bootloader
mov bx, 0
boot:
    lodsw
    xor bx, ax
    loop boot
mov [hash + 10], bx
mov cx, 254                    ; empty
empty:
    lodsw
    xor bx, ax
    loop empty
mov [hash + 8], bx
mov cx, 254                    ; checksum
check:
    lodsw
    xor bx, ax
    loop check
mov [hash + 6], bx
mov cx, 254                    ; B1
B1:
    lodsw
    xor bx, ax
    loop B1
mov [hash + 4], bx
mov cx, 254                    ; B2
B2:
    lodsw
    xor bx, ax
    loop B2
mov [hash + 2], bx
mov cx, 2046                   ; pacman
pacman:
    lodsw
    xor bx, ax
    loop pacman
mov [hash], bx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CHECKER
mov si, 10                      ; Print all hashes
mov bx, 6
hash_print:
    mov ax, [hash + si]
    sub si, 2
    call print_hex
    dec bx
    cmp bx, 0
    jne hash_print





mov si, nl
call print_string



mov bx, 0x7c00 + 508 - 512
mov cx, 7

check_hash:
    mov si, cx
    imul si, 2 
    mov dx, [hash + si - 4]

    
    cmp cx, 1
    je ou

    add bx, 512

    cmp [bx], dx
    je ok_ckeck

    cmp [bx], dx
    jne not_ckeck


ou:    
mov si, nl
call print_string

popa
    jmp 0x7c00     

ok_ckeck:
    dec cx
    mov si, ok
    call print_string
    jmp check_hash

not_ckeck:
    dec cx
    mov si, no
    call print_string
    jmp check_hash



            ; Return control to the bootloader
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

print_hex:                     ; Mov ax, PRINT HEX
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
nl db 0x0D, 0x0A, 0
ok db 'OK   ',0
no db 'NOT  ',0
count dw 0
address dw 0x7C00
hash times (10) dw 0x0000
blocks db 20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EOF
times 508-($-$$) db 0          ; Pad to 510 bytes
dw 0x4AF7
dw 0x4AF7
;;;;;;;;;;;;;;; The solution below was a pure brain tumor and 
;;;;;;;;;;;;;;; I let it slide to the abyse here, make it better if you can!!!!!
;     pusha
; 
; checkall:
;     mov ax, 1
;     add [count], ax
; 
;     mov si, [address]
;     mov ax, 0
;     mov bx, 0
;     mov cx, 254
; 
; generate:
;     lodsw  
;     xor bx, ax
;     loop generate
; 
;     mov [hash], bx
; 
;     mov ax, [hash]
;     call print_hex
;     mov ax, [hash]
;     cmp ax, [address + 508]
;     jne exit
; 
;     mov si, ok                 ; Load message address
;     call print_string          ; Print OK if checksum is correct
; 
; 
; exit:
;     mov ax, 512
;     add [address], ax
;     mov ax, 1                  ; Blocks to checksum
;     cmp [count], ax
;     jne checkall
;     
;     popa