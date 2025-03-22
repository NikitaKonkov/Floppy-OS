
; display.asm
org 0x9000 + 0x0200

; Print a message in real mode
mov si, display_msg     ; Load message address
call print_string       ; Call print routine

; Halt the system
hlt                     ; Halt the CPU

; 16-bit function to print a string
print_string:
    lodsb               ; Load byte from SI into AL and increment SI
    or al, al           ; Check if AL is 0 (end of string)
    jz .done            ; If zero, we're done
    mov ah, 0x0E        ; BIOS teletype function
    int 0x10            ; Call BIOS
    jmp print_string    ; Repeat for next character
.done:
    ret

display_msg db 'Welcome to the Display Program!', 0
times 510-($-$$) db 0   ; Pad to 510 bytes