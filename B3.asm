; game.asm
org 0x7c00 + 512 * 5

start:
    cli                         ; Disable interrupts
    xor ax, ax                  ; Zero AX
    mov ds, ax                  ; Set DS to 0
    mov es, ax                  ; Set ES to 0
    mov ss, ax                  ; Set SS to 0
    mov sp, 0x7C00              ; Set stack pointer just below our code

    ; Check if we're in real mode and display status
    call check_cpu_mode
    
    ; Print a message in real mode
    mov si, real_mode_msg
    call print_string
    
    ; Enable A20 line
    call enable_a20
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Switch to protected mode
    mov eax, cr0                ; Get current CR0
    or eax, 1                   ; Set PE bit
    mov cr0, eax                ; Update CR0 - now in protected mode
    
    ; Far jump to flush the pipeline and load CS with 32-bit selector
    jmp 0x08:protected_mode     ; 0x08 is the offset in the GDT to our code segment

[BITS 32]                       ; Following code is 32-bit protected mode code

protected_mode:
    ; Now in 32-bit protected mode
    mov ax, 0x10                ; 0x10 is the offset to our data segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up a new stack
    mov esp, 0x90000
    
    ; Display protected mode status
    call display_protected_mode_status
    
    ; Print a character to video memory to show we're in protected mode
    mov byte [0xB8500 + 160 * 9], 'P'     ; Character
    mov byte [0xB8501 + 160 * 9], 0x0F    ; Attribute (white on black)
    
    ; Print "32-bit Protected Mode" message
    mov esi, protected_mode_msg
    mov edi, 0xB8500 + 160 * 9      ; Second line (80*2 bytes per line)
    call print_string_pm
    
    std
    ; fix this part so it jumps back to the bootloader in real mode
    jmp 0x7C00

; Function to display protected mode status
display_protected_mode_status:
    ; Check CR0 PE bit to confirm we're in protected mode
    mov eax, cr0
    and eax, 1                  ; Isolate PE bit
    
    ; Display result (1 = Protected Mode)
    add eax, '0'                ; Convert to ASCII
    mov byte [0xB8500 + 0  + 160 * 8], 'M' ; "M"
    mov byte [0xB8500 + 1  + 160 * 8], 0x0A ; Green on black
    mov byte [0xB8500 + 2  + 160 * 8], 'o' ; "o"
    mov byte [0xB8500 + 3  + 160 * 8], 0x0A ; Green on black
    mov byte [0xB8500 + 4  + 160 * 8], 'd' ; "d"
    mov byte [0xB8500 + 5  + 160 * 8], 0x0A ; Green on black
    mov byte [0xB8500 + 6  + 160 * 8], 'e' ; "e"
    mov byte [0xB8500 + 7  + 160 * 8], 0x0A ; Green on black
    mov byte [0xB8500 + 8  + 160 * 8], ':' ; ":"
    mov byte [0xB8500 + 9  + 160 * 8], 0x0A ; Green on black
    mov byte [0xB8500 + 10 + 160 * 8], al ; "1" (PE bit value)
    mov byte [0xB8500 + 11 + 160 * 8], 0x0A ; Green on black
    
    ret

; Function to print a string in protected mode
; esi = string address, edi = video memory address
print_string_pm:
    push eax
    push edi
    
.loop:
    mov al, [esi]               ; Get character
    test al, al                 ; Check if end of string
    jz .done
    
    mov [edi], al               ; Store character
    mov byte [edi+1], 0x0F      ; White on black attribute
    
    add esi, 1                  ; Next character
    add edi, 2                  ; Next video position
    jmp .loop
    
.done:
    pop edi
    pop eax
    ret

[BITS 16]                       ; Back to 16-bit for procedures

; Function to check CPU mode and display
check_cpu_mode:
    ; In real mode, CR0.PE bit is 0
    smsw ax                     ; Store Machine Status Word in AX (lower 16 bits of CR0)
    test ax, 1                  ; Test PE bit
    jnz .protected_mode
    
    ; We're in real mode
    mov si, mode_real_msg
    call print_string
    jmp .done
    
.protected_mode:
    ; We're in protected mode (shouldn't happen at this point)
    mov si, mode_protected_msg
    call print_string
    
.done:
    ret

; Function to enable A20 line
enable_a20:
    ; First try the fast A20 method
    in al, 0x92                 ; Read System Control Port A
    test al, 2                  ; Test if A20 is already enabled
    jnz .a20_enabled            ; If it's already enabled, we're done
    or al, 2                    ; Set A20 enable bit
    and al, 0xFE                ; Make sure bit 0 is clear (avoid reset)
    out 0x92, al                ; Write back to System Control Port A
    
    ; Check if A20 is now enabled
    call check_a20
    test ax, ax
    jnz .a20_enabled
    
    ; If fast A20 failed, try the keyboard controller method
    call enable_a20_keyboard
    
    ; Final check
    call check_a20
    test ax, ax
    jnz .a20_enabled
    
    ; If we get here, A20 couldn't be enabled
    mov si, a20_error_msg
    call print_string
    jmp $                       ; Hang

.a20_enabled:
    mov si, a20_enabled_msg
    call print_string
    ret

; Enable A20 using keyboard controller
enable_a20_keyboard:
    cli                         ; Disable interrupts
    
    call wait_input             ; Wait for keyboard controller
    mov al, 0xAD                ; Command: disable keyboard
    out 0x64, al
    
    call wait_input
    mov al, 0xD0                ; Command: read controller output port
    out 0x64, al
    
    call wait_output
    in al, 0x60                 ; Read controller output port data
    push ax                     ; Save it
    
    call wait_input
    mov al, 0xD1                ; Command: write controller output port
    out 0x64, al
    
    call wait_input
    pop ax                      ; Get saved controller output
    or al, 2                    ; Set A20 bit
    out 0x60, al                ; Write it back
    
    call wait_input
    mov al, 0xAE                ; Command: enable keyboard
    out 0x64, al
    
    call wait_input
    sti                         ; Enable interrupts
    ret

; Wait for keyboard controller input buffer to be empty
wait_input:
    in al, 0x64                 ; Read keyboard controller status
    test al, 2                  ; Test if input buffer is full
    jnz wait_input              ; If full, wait more
    ret

; Wait for keyboard controller output buffer to be full
wait_output:
    in al, 0x64                 ; Read keyboard controller status
    test al, 1                  ; Test if output buffer is full
    jz wait_output              ; If empty, wait more
    ret

; Check if A20 line is enabled
check_a20:
    pushf                       ; Save flags
    push ds
    push es
    push di
    push si
    
    cli                         ; Disable interrupts
    
    xor ax, ax                  ; Set ES:DI to 0000:0500
    mov es, ax
    mov di, 0x0500
    
    mov ax, 0xFFFF              ; Set DS:SI to FFFF:0510
    mov ds, ax
    mov si, 0x0510
    
    mov al, byte [es:di]        ; Save bytes at both addresses
    push ax
    mov al, byte [ds:si]
    push ax
    
    mov byte [es:di], 0x00      ; Write different values to each address
    mov byte [ds:si], 0xFF
    
    mov ax, 0                   ; Default to disabled
    cmp byte [es:di], 0xFF      ; If A20 is disabled, the two addresses will alias
    je .done                    ; If they're the same, A20 is disabled
    mov ax, 1                   ; If different, A20 is enabled
    
.done:
    pop bx                      ; Restore original values
    mov byte [ds:si], bl
    pop bx
    mov byte [es:di], bl
    
    pop si                      ; Restore registers
    pop di
    pop es
    pop ds
    popf                        ; Restore flags
    ret

; Function to print a null-terminated string
print_string:
    lodsb                       ; Load byte at DS:SI into AL and increment SI
    or al, al                   ; Check if character is 0 (end of string)
    jz .done                    ; If zero, we're done
    mov ah, 0x0E                ; BIOS teletype function
    int 0x10                    ; Call BIOS
    jmp print_string            ; Repeat for next character
.done:
    ret

; Data section
real_mode_msg db 'Starting in real mode...', 13, 10, 0
a20_enabled_msg db 'A20 line enabled!', 13, 10, 0
a20_error_msg db 'Failed to enable A20 line!', 13, 10, 0
mode_real_msg db 'CPU is in 16-bit Real Mode', 13, 10, 0
mode_protected_msg db 'CPU is in Protected Mode', 13, 10, 0
protected_mode_msg db '32-bit Protected Mode Active', 0

; GDT (Global Descriptor Table)
gdt_start:
    ; Null descriptor (required)
    dd 0                        ; 4 bytes of zeros
    dd 0                        ; 4 bytes of zeros

    ; Code segment descriptor
    dw 0xFFFF                   ; Limit (bits 0-15)
    dw 0                        ; Base (bits 0-15)
    db 0                        ; Base (bits 16-23)
    db 10011010b                ; Access byte: Present, Ring 0, Code, Executable, Direction 0, Readable
    db 11001111b                ; Flags and Limit (bits 16-19): 4KB granularity, 32-bit mode, Limit bits 16-19
    db 0                        ; Base (bits 24-31)

    ; Data segment descriptor
    dw 0xFFFF                   ; Limit (bits 0-15)
    dw 0                        ; Base (bits 0-15)
    db 0                        ; Base (bits 16-23)
    db 10010010b                ; Access byte: Present, Ring 0, Data, Writable
    db 11001111b                ; Flags and Limit (bits 16-19): 4KB granularity, 32-bit mode, Limit bits 16-19
    db 0                        ; Base (bits 24-31)
gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT minus 1
    dd gdt_start                ; Start address of GDT

times 4092-($-$$) db 0   ; Pad to 510 bytes
dw 0x1122
dw 0x1122