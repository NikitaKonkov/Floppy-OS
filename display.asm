org 0x7c00 + 512 * 2

; Set up stack
mov ax, 0
mov ss, ax
mov sp, 0x7c00

; Save boot drive number
mov [boot_drive], dl

; Initialize 32-bit video mode
call init_video_mode

; Print a message
mov si, msg
call print_string

; Return to bootloader
jmp 0x7C28

; 16-bit function to print a string
print_string:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

; Initialize 32-bit video mode with highest resolution
init_video_mode:
    mov ax, 0x4F02
    mov bx, 0x4118  ; 1024x768 32-bit color
    int 0x10
    ret

boot_drive db 0
msg db 'B1 ', 0

times 510-($-$$) db 0