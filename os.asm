; os.asm
org 0x9000
; Initialize segment registers
xor ax, ax              ; Zero AX register
mov ds, ax              ; Set DS to 0
mov es, ax              ; Set ES to 0
mov ss, ax              ; Set SS to 0
mov sp, 0x9000          ; Set stack pointer to 0x7C00
push 88
push 69
push 0xFFFF
; Print a message in real mode
mov si, boot_msg        ; Load message address
call print_string       ; Call print routine

; Return to bootloader
ret                     ; Return control to the bootloader

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

boot_msg db 'Booting to 16-bit mode success! 11223344TEST', 0

times 510-($-$$) db 0   ; Pad to 510 bytes