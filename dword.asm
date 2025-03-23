bits 16
org 0x7c00 + 512 * 3

second_stage:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ; Enable A20 line (simplified method)
    in al, 0x92
    or al, 2
    out 0x92, al
    
    ; Load GDT
    cli                     ; Disable interrupts
    lgdt [gdt_descriptor]
    
    ; Switch to protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Far jump to flush the pipeline and load CS with 32-bit segment
    jmp protected_mode

; GDT
gdt_start:
    ; Null descriptor
    dd 0
    dd 0
    
    ; Code segment descriptor
    dw 0xFFFF               ; Limit (bits 0-15)
    dw 0                    ; Base (bits 0-15)
    db 0                    ; Base (bits 16-23)
    db 10011010b            ; Access byte
    db 11001111b            ; Flags + Limit (bits 16-19)
    db 0                    ; Base (bits 24-31)
    
    ; Data segment descriptor
    dw 0xFFFF               ; Limit (bits 0-15)
    dw 0                    ; Base (bits 0-15)
    db 0                    ; Base (bits 16-23)
    db 10010010b            ; Access byte
    db 11001111b            ; Flags + Limit (bits 16-19)
    db 0                    ; Base (bits 24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start                ; GDT address

[bits 32]
protected_mode:
    ; Set up segment registers with appropriate selectors
    mov ax, 0x10            ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Now we're in 32-bit protected mode
    ; Print a message (using VGA text mode)
    mov esi, message
    mov edi, 0xB8000        ; VGA text buffer
    
print_loop:
    lodsb                   ; Load byte from ESI into AL
    test al, al             ; Check if we reached the end of the string
    jz halt
    mov ah, 0x0F            ; White on black attribute
    stosw                   ; Store AX at EDI and increment EDI by 2
    jmp print_loop
    
halt:
    hlt
    jmp halt                ; Infinite loop

message db 'Successfully entered 32-bit protected mode!', 0

times 512-($-$$) db 0       ; Pad to 512 bytes