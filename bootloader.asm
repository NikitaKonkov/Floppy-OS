; bootloader.asm
bits 16
org 0x7c00

start:
    mov ah, 0x02            ; BIOS function to read sectors
    mov al, 1               ; Number of sectors to read (adjust this based on the size of os.asm)
    mov ch, 0               ; Cylinder number (0)
    mov cl, 2               ; Sector number (2, assuming the second stage starts from the second sector)
    mov dh, 0               ; Head number (0)
    mov bx, 0x7c00 + 512    ; Destination buffer address (0x9000, where os.asm will be loaded)
    int 0x13                ; BIOS interrupt to read from disk
    jc disk_error           ; If carry flag is set, print error message and hang
    jmp 0x7c00 + 512        ; Jump to the loaded os.asm at address 0x9000



;;; 0x7c14
    mov ah, 0x02                    ; BIOS function to read sectors
    mov al, 1                       ; Number of sectors to read (adjust this based on the size of os.asm)
    mov ch, 0                       ; Cylinder number (0)
    mov cl, 3                       ; Sector number (3, assuming the second stage starts from the third sector)
    mov dh, 0                       ; Head number (0)
    mov bx, 0x7c00 + 512 * 2        ; Destination buffer address (0x9000, where os.asm will be loaded)
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang
    jmp 0x7c00 + 512 * 2            ; Jump to the loaded os.asm at address 0x9000



;;; 0x7c28
    mov ah, 0x02                    ; BIOS function to read sectors
    mov al, 1                       ; Number of sectors to read
    mov ch, 0                       ; Cylinder
    mov cl, 4                       ; Sector
    mov dh, 0                       ; Head
    mov bx, 0x7c00 + 512 * 3        ; Destination buffer
    int 0x13                        ; BIOS interrupt to read from disk
    jc disk_error                   ; If carry flag is set, print error message and hang
    jmp 0x7c00 + 512 * 3            ; Jump

disk_error:
    mov si, error_msg
    call print_string
    jmp $      

; clear:
;     xor ax, ax
;     mov ds, ax
;     mov es, ax
;     mov ss, ax
;     mov sp, 0x9000
;     ret
;     
; keypress:
;     mov ah, 0x00            ; BIOS function to wait for a key press
;     int 0x16                ; BIOS interrupt for keyboard services
;     ret

; Simple string printing routine
print_string:
    push ax
    mov ah, 0x0E        ; BIOS teletype function
.loop:
    lodsb               ; Load byte from SI into AL and increment SI
    or al, al           ; Check if AL is 0 (end of string)
    jz .done            ; If zero, we're done
    int 0x10            ; Call BIOS
    jmp .loop           ; Repeat for next character
.done:
    pop ax
    ret

error_msg db 'Disk read error!', 13, 10, 0

times 510-($-$$) db 0       ; Fill the rest of the boot sector with zeros
dw 0xaa55                  ; Boot signature (0xAA55)