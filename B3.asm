; game.asm
org 0x7c00 + 512 * 5
     mov ah, 0x48  ; Function number for memory allocation
     mov bx, 3000  ; Number of paragraphs (16-byte blocks) to allocate
     int 0x21      ; Call DOS interrupt
; RUN ###############################################################################################################
start:
    call sizer_a
    call sizer_b
    call set_video_mode
    call test_screen
    call draw_background
    game_loop:
        call wasd_key
        ;call wall_collision
        jmp game_loop
gen_reg_xor: ; xor all registers
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    ret
ind_reg_xor: ; xor some index registers
    xor si, si
    xor di, di
    ret

set_video_mode:
    mov ah, 0x00  ; BIOS function: set video mode
    mov al, 0x13  ; Video mode: VGA 320x200 256-color
    int 0x10
    ret

draw_pixel:
    mov ah, 0x0c  ; BIOS function: write pixel
    mov al, 0x0a  ; Pixel color (green)
    mov cx, 160   ; X-coordinate (0-319)
    mov dx, 100   ; Y-coordinate (0-199)
    int 0x10
    ret

test_screen:
    mov ax, 0x0c00  ; BIOS function: write pixel | Pixel color (y)
    mov cx, 0xFF
    mov dx, 0x00
    rainbow0:
        rainbow1:
        int 0x25
        inc dx
        cmp dx, 50
        jne rainbow1
        mov al, cl
        mov dx, 0
        loop rainbow0
    ret
sleep:
    mov ah, 0x86
    mov cx, 0x0000  ; High word of delay (in microseconds)
    mov dx, 0x1000  ; Low word of delay (65535 microseconds)
    int 0x15        ; BIOS interrupt for delay
    ret

clock: ; **Returns**: CH = Hours, CL = Minutes, DH = Seconds, DL = Daylight savings flag
    mov ah, 0x02
    int 0x1A
    ret
; PACMAN ############################################################################################################
draw_pacman_right:
    
    ;mov ax, 0x0C04 ; <- activate brain power
    xor bx, bx
    xor dx, dx
    xor di, di
    ly:
    mov cx, [pac_x] ; X-coordinate (0-319) 
    imul bx, 2 
    add cx, [pac_aw+bx] 
    sub bx, di
    mov dl, [pac_y] ; Y-coordinate (0-199)
    add dl, bl
    mov bh, [pac_a_0+bx]
    inc bl
    inc di
    lx: 
        int 0x10
        inc cx
        dec bh
        cmp bh, 0
        jne lx
    cmp bx, 13
    jne ly
    mov bx, 0
    mov [pac_v], bx
    ret
draw_pacman_left:
    ;mov ax, 0x0C01 ; <- activate brain power
    xor bx, bx
    xor dx, dx
    xor di, di
    fy:
    mov cx, [pac_x] ; X-coordinate (0-319)
    imul bx, 2 
    add cx, [pac_y_0+bx] 
    sub bx, di
    mov dl, [pac_y] ; Y-coordinate (0-199)
    add dl, bl
    mov bh, [pac_a_0+bx]
    inc bl
    inc di
    fx: 
        int 0x10
        inc cx
        dec bh
        cmp bh, 0
        jne fx
    cmp bx, 13
    jne fy
    mov bx, 1
    mov [pac_v], bx
    ret
draw_pacman_down:
    ;mov ax, 0x0C0E ; <- activate brain power
    xor bx, bx
    xor dx, dx
    mov cx, [pac_x] ; X-coordinate (0-319) 
    mov dl, [pac_y] ; Y-coordinate (0-199)
    mov di, 0
    gx:
        mov dl, [pac_y] ; Y-coordinate (0-199)
        add dl, [pac_ab+bx]
        mov si, [pac_b_0 + di]
        gy:
            int 0x10
            inc dl
            dec si
            cmp si, 0
            jne gy
        add di, 2
        inc cx 
        inc bx
        cmp bx, 13
        jne gx
    mov bx, 2
    mov [pac_v], bx
    ret
draw_pacman_upper:
    ;mov ax, 0x0C02 ; <- activate brain power
    xor bx, bx
    xor dx, dx
    mov cx, [pac_x] ; X-coordinate (0-319) 
    mov dl, [pac_y] ; Y-coordinate (0-199)
    mov di, 0
    ex:
        mov dl, [pac_y] ; Y-coordinate (0-199)
        add dl, [pac_x_0 + bx]
        mov si, [pac_b_0 + di]
        ey: ; ey!
            int 0x10
            inc dl
            dec si
            cmp si, 0
            jne ey
        add di, 2
        inc cx 
        inc bx
        cmp bx, 13
        jne ex
    mov bx, 3
    mov [pac_v], bx
    ret
delete_pacman: ;rldu
    
    mov bx, [pac_v]
    cmp bx, 0
    je dp0
    cmp bx, 2
    jl dp1
    je dp2
    jg dp3
    dp0:
        mov ax, 0x0C00
        call draw_pacman_right
        call pac_array_x
        ret
    dp1:
        mov ax, 0x0C00
        call draw_pacman_left
        call pac_array_x
        ret
    dp2:
        mov ax, 0x0C00
        call draw_pacman_down
        call pac_array_y
        ret
    dp3:
        mov ax, 0x0C00
        call draw_pacman_upper
        call pac_array_y
        ret

pac_array_x:
    mov cx, 13 ; Number of elements to copy
    mov bx, [pac_mx]
    cmp bx, 1
    je switch_array_a1
    cmp bx, 2
    je switch_array_a2
    cmp bx, 3
    je switch_array_a3
    cmp bx, 4
    je switch_array_a4
    switch_array_a1:
        lea si, pac_a_1 ; Load effective address of pac_a_1 into SI
        mov bx, 2
        mov [pac_mx] ,bx
        jmp end_switch0
    switch_array_a2:
        lea si, pac_a_2 ; Load effective address of pac_a_1 into SI
        mov bx, 3
        mov [pac_mx] ,bx
        jmp end_switch0
    switch_array_a3:
        lea si, pac_a_3 ; Load effective address of pac_a_1 into SI
        mov bx, 4
        mov [pac_mx] ,bx
        jmp end_switch0
    switch_array_a4:
        lea si, pac_a_2 ; Load effective address of pac_a_1 into SI
        mov bx, 1
        mov [pac_mx] ,bx
        jmp end_switch0
    end_switch0:
        lea di, pac_a_0 ; Load effective address of pac_a_0 into DI
    copy_loop0:
        mov al, [si] ; Move byte at address pointed by SI into AL
        mov [di], al ; Move byte from AL into address pointed by DI
        inc si ; Increment SI to next byte in pac_a_1
        inc di ; Increment DI to next byte in pac_a_0
        dec cx ; Decrement CX
        jnz copy_loop0 ; Jump to copy_loop if CX is not zero

    mov cx, 26 ; Number of elements to copy
    mov bx, [pac_mx]
    cmp bx, 2
    je switch_array_y1
    cmp bx, 3
    je switch_array_y2
    cmp bx, 4
    je switch_array_y3
    cmp bx, 1
    je switch_array_y4
    switch_array_y1:
        lea si, pac_y_1 ; Load effective address of pac_a_1 into SI
        mov bx, 2
        mov [pac_mx] ,bx
        jmp end_switch1
    switch_array_y2:
        lea si, pac_y_2 ; Load effective address of pac_a_1 into SI
        mov bx, 3
        mov [pac_mx] ,bx
        jmp end_switch1
    switch_array_y3:
        lea si, pac_y_3 ; Load effective address of pac_a_1 into SI
        mov bx, 4
        mov [pac_mx] ,bx
        jmp end_switch1
    switch_array_y4:
        lea si, pac_y_2 ; Load effective address of pac_a_1 into SI
        mov bx, 1
        mov [pac_mx] ,bx
        jmp end_switch1
    end_switch1:
        lea di, pac_y_0 ; Load effective address of pac_a_0 into DI
    copy_loop1:
        mov al, [si] ; Move byte at address pointed by SI into AL
        mov [di], al ; Move byte from AL into address pointed by DI
        inc si ; Increment SI to next byte in pac_a_1
        inc di ; Increment DI to next byte in pac_a_0
        dec cx ; Decrement CX
        jnz copy_loop1 ; Jump to copy_loop if CX is not zero
        ret ; Return from subroutine

pac_array_y:
    mov cx, 13 ; Number of elements to copy
    mov bx, [pac_my]
    cmp bx, 1
    je switch_array_b1
    cmp bx, 2
    je switch_array_b2
    cmp bx, 3
    je switch_array_b3
    cmp bx, 4
    je switch_array_b4
    switch_array_b1:
        lea si, pac_x_1 ; Load effective address of pac_a_1 into SI
        mov bx, 2
        mov [pac_my] ,bx
        jmp end_switch2
    switch_array_b2:
        lea si, pac_x_2 ; Load effective address of pac_a_1 into SI
        mov bx, 3
        mov [pac_my] ,bx
        jmp end_switch2
    switch_array_b3:
        lea si, pac_x_3 ; Load effective address of pac_a_1 into SI
        mov bx, 4
        mov [pac_my] ,bx
        jmp end_switch2
    switch_array_b4:
        lea si, pac_x_2 ; Load effective address of pac_a_1 into SI
        mov bx, 1
        mov [pac_my] ,bx
        jmp end_switch2
    end_switch2:
        lea di, pac_x_0 ; Load effective address of pac_a_0 into DI
    copy_loop2:
        mov al, [si] ; Move byte at address pointed by SI into AL
        mov [di], al ; Move byte from AL into address pointed by DI
        inc si ; Increment SI to next byte in pac_a_1
        inc di ; Increment DI to next byte in pac_a_0
        dec cx ; Decrement CX
        jnz copy_loop2 ; Jump to copy_loop if CX is not zero

    mov cx, 26 ; Number of elements to copy
    mov bx, [pac_my]
    cmp bx, 2
    je switch_array_x1
    cmp bx, 3
    je switch_array_x2
    cmp bx, 4
    je switch_array_x3
    cmp bx, 1
    je switch_array_x4
    switch_array_x1:
        lea si, pac_b_1 ; Load effective address of pac_a_1 into SI
        mov bx, 2
        mov [pac_my] ,bx
        jmp end_switch3
    switch_array_x2:
        lea si, pac_b_2 ; Load effective address of pac_a_1 into SI
        mov bx, 3
        mov [pac_my] ,bx
        jmp end_switch3
    switch_array_x3:
        lea si, pac_b_3 ; Load effective address of pac_a_1 into SI
        mov bx, 4
        mov [pac_my] ,bx
        jmp end_switch3
    switch_array_x4:
        lea si, pac_b_2 ; Load effective address of pac_a_1 into SI
        mov bx, 1
        mov [pac_my] ,bx
        jmp end_switch3
    end_switch3:
        lea di, pac_b_0 ; Load effective address of pac_a_0 into DI
    copy_loop3:
        mov al, [si] ; Move byte at address pointed by SI into AL
        mov [di], al ; Move byte from AL into address pointed by DI
        inc si ; Increment SI to next byte in pac_a_1
        inc di ; Increment DI to next byte in pac_a_0
        dec cx ; Decrement CX
        jnz copy_loop3 ; Jump to copy_loop if CX is not zero
        ret ; Return from subroutine
.pacman_data:
    pac_mx dw 1
    pac_my dw 1
    pac_v dw 0
    pac_x dw 24 ;x Coordinates of Pacman position !!!
    pac_y dw 24 ;y Coordinates of Pacman position !!!

    pac_aw  dw 4, 2, 1, 1, 0, 0, 0, 0, 0, 1, 1, 2, 4
    pac_ab  db 4, 2, 1, 1, 0, 0, 0, 0, 0, 1, 1, 2, 4

    pac_a_0 db 5, 6, 6, 5, 5, 4, 3, 4, 5, 5, 6, 6, 5 
    pac_a_1 db 5, 6, 6, 5, 5, 4, 3, 4, 5, 5, 6, 6, 5 ; A
    pac_a_2 db 5, 9,11,11,10, 7, 4, 7,10,11,11, 9, 5 ; B
    pac_a_3 db 5, 9,11,11,13,13,13,13,13,11,11, 9, 5 ; C

    pac_y_0 dw 4, 5, 6, 7, 8, 9,10, 9, 8, 7, 6, 5, 4 
    pac_y_1 dw 4, 5, 6, 7, 8, 9,10, 9, 8, 7, 6, 5, 4 ; A
    pac_y_2 dw 4, 2, 1, 1, 3, 6, 9, 6, 3, 1, 1, 2, 4 ; B
    pac_y_3 dw 4, 2, 1, 1, 0, 0, 0, 0, 0, 1, 1, 2, 4 ; C

    pac_b_0 dw 5, 6, 6, 5, 5, 4, 3, 4, 5, 5, 6, 6, 5
    pac_b_1 dw 5, 6, 6, 5, 5, 4, 3, 4, 5, 5, 6, 6, 5 ; A
    pac_b_2 dw 5, 9,11,11,10, 7, 4, 7,10,11,11, 9, 5 ; B
    pac_b_3 dw 5, 9,11,11,13,13,13,13,13,11,11, 9, 5 ; C

    pac_x_0 db 4, 5, 6, 7, 8, 9,10, 9, 8, 7, 6, 5, 4
    pac_x_1 db 4, 5, 6, 7, 8, 9,10, 9, 8, 7, 6, 5, 4 ; A
    pac_x_2 db 4, 2, 1, 1, 3, 6, 9, 6, 3, 1, 1, 2, 4 ; B
    pac_x_3 db 4, 2, 1, 1, 0, 0, 0, 0, 0, 1, 1, 2, 4 ; C
; GHOSTS ############################################################################################################
draw_ghost:
    mov ax, 0x0C03 ; <- activate brain power
    xor bx, bx
    xor dx, dx
    mov cx, [ghost_x] ; X-coordinate (0-319) 
    mov dl, [ghost_y] ; Y-coordinate (0-199)
    mov di, 0
    inc di
    
     ret
.ghost_data:
    ghost_x dw 20
    ghost_y db 20
    ghost_v dw 0
    ghost_b_0 dw 5, 6, 6, 5, 5, 4, 3, 4, 5, 5, 6, 6, 5
    ghost_ab  db 4, 2, 1, 1, 0, 0, 0, 0, 0, 1, 1, 2, 4
; ITEMS #############################################################################################################

; CONTROL ###########################################################################################################
wasd_key:
    ;call pacman_animation
    ; Check for a key press
    mov ah, 0x01
    int 0x16
    jz no_key_pressed  ; If no key is pressed, jump to no_key_pressed

    ; A key is pressed, save the key press in AL
    mov ah, 0x00
    int 0x16           ; Read the key press
    
    cmp al, 119
    je w_pressed
    cmp al, 97
    je a_pressed
    cmp al, 115
    je s_pressed
    cmp al, 100
    je d_pressed
    jne no_key_pressed
    no_key_pressed:
    ret


    w_pressed:
    call delete_pacman
    mov ax, [move_speed]
    sub [pac_y], ax
    mov ax, 0x0C0E
    call draw_pacman_upper
    ret

    a_pressed:
    call delete_pacman
    mov ax, [move_speed]
    sub [pac_x], ax
    mov ax, 0x0C0E
    call draw_pacman_left
    ret

    s_pressed:
    call delete_pacman
    mov ax, [move_speed]
    add [pac_y], ax
    mov ax, 0x0C0E
    call draw_pacman_down
    ret

    d_pressed:
    call delete_pacman
    mov ax, [move_speed]
    add [pac_x], ax
    mov ax, 0x0C0E
    call draw_pacman_right
    ret
move_speed dw 3
; BACKGROUND ########################################################################################################   
draw_background:
    ; Set video mode (320x200, 256 colors)
    mov al, 0x13
    int 0x10
    ; Set up video memory segment
    mov ax, 0xA000
    mov es, ax
    ; Draw the background (black color)
    mov di, 0
    loop_a:
        mov byte [es:di], 0x00
        inc di 
        cmp di, 320 * 200
        jne loop_a

    mov bx, 0

    map_builder0:
        mov al, [map_c0+bx]
        mov cx, [map_y0+bx]   ; Y-coordinate of the top-left corner
        mov di, cx
        imul di, 320
        add di, [map_x0+bx]   ; X-coordinate of the top-left corner

        mov si, [map_h0+bx]   ; height
        draw_square_row0:
        push di
        mov cx, [map_w0+bx]    ; width
        draw_square_col0:
        mov [es:di], al
        inc di
        loop draw_square_col0
        pop di
        add di, 320
        dec si
        jnz draw_square_row0
        add bx, 2
        cmp bx, 46
        jne map_builder0

    mov bx, 0
    map_builder1:
        mov al, [map_c1+bx]
        mov cx, [map_y1+bx]   ; Y-coordinate of the top-left corner
        mov di, cx
        imul di, 320
        add di, [map_x1+bx]   ; X-coordinate of the top-left corner

        mov si, [map_h1+bx]   ; height
        draw_square_row:
        push di
        mov cx, [map_w1+bx]    ; width
        draw_square_col:
        mov [es:di], al
        inc di
        loop draw_square_col
        pop di
        add di, 320
        dec si
        jnz draw_square_row
        add bx, 2
        cmp bx, 46
        jne map_builder1

    ret

size_r dw 6 
sizer_a:
    mov si, map_x1       ; SI points to the start of map_h1
    mov cx, [map_item_count]   ; CX is the counter for the number of elements

    add_two_loop0:
    mov bx, [size_r] 
        add word [si], bx    ; Add 2 to the current element
        add si, 2            ; Move to the next element (each element is 2 bytes)
        loop add_two_loop0    ; Loop until CX is 0
    
    mov si, map_y1       ; SI points to the start of map_h1
    mov cx, [map_item_count]    ; CX is the counter for the number of elements

    add_two_loop00:
    mov bx, [size_r] 
        add word [si], bx     ; Add 2 to the current element
        add si, 2            ; Move to the next element (each element is 2 bytes)
        loop add_two_loop00    ; Loop until CX is 0

sizer_b:
    mov si, map_w1       ; SI points to the start of map_h1
    mov cx, [map_item_count]            ; CX is the counter for the number of elements

    sub_two_loop1:
    mov bx, [size_r] 
        sub word [si], bx      ; Subtract 2 from the current element
        add si, 2            ; Move to the next element (each element is 2 bytes)
        loop sub_two_loop1    ; Loop until CX is 0

    mov si, map_h1       ; SI points to the start of map_h1
    mov cx, [map_item_count]            ; CX is the counter for the number of elements

    sub_two_loop11:
        mov bx, [size_r] 
        sub word [si], bx      ; Subtract 2 from the current element
        add si, 2            ; Move to the next element (each element is 2 bytes)
        loop sub_two_loop11    ; Loop until CX is 0
    
    ret
.map_data:
    map_item_count dw 23
    map_c0 times 44 dw 0x01
    map_c1 times 44 dw 0x00
    map_x0 dw   0,  0,  0,300, 40,260, 80,220,140,100,200, 40,220,120,180,140, 40, 80,200,260,140,  0,300
    map_y0 dw   0,180,  0,  0, 40, 40, 40, 40, 40, 40, 40,100,100, 80, 80,120,140,140,140,140,160, 80, 80
    map_w0 dw 320,320, 20, 20, 20, 20, 20, 20, 40, 20, 20, 60, 60, 20, 20, 40, 20, 40, 40, 20, 40, 20, 20
    map_h0 dw  20, 20, 60, 60, 40, 40, 40, 40, 20, 20, 20, 20, 20, 40, 40, 20, 20, 20, 20, 20, 20,120,120
    map_x1 dw   0,  0,  0,300, 40,260, 80,220,140, 80,200, 40,220,120,180,140, 40, 80,200,260,140,  0,300
    map_y1 dw   0,180,  0,  0, 40, 40, 40, 40, 40, 40, 40,100,100, 80, 80,120,140,140,140,140,160, 80, 80
    map_w1 dw 320,320, 20, 20, 20, 20, 20, 20, 40, 40, 40, 60, 60, 20, 20, 40, 20, 40, 40, 20, 40, 20, 20
    map_h1 dw  20, 20, 60, 60, 40, 40, 40, 40, 20, 20, 20, 20, 20, 40, 40, 20, 20, 20, 20, 20, 20,120,120
; COLLISION #########################################################################################################
wall_collision:
        mov ax, [pac_x]
        cmp ax, [move_speed]
        jbe wc0
        jmp end_wc0
        wc0:
            mov ax, [move_speed]
            mov [pac_x], ax
        end_wc0:


        mov ax, [pac_x]
        cmp ax, 306
        jge wc1
        jmp end_wc1
        wc1:
            mov ax, 306
            mov [pac_x], ax
        end_wc1:


        mov ax, [pac_y]
        cmp ax, [move_speed]
        jbe wc2
        jmp end_wc2
        wc2:
            mov ax, [move_speed]
            mov [pac_y], ax
        end_wc2:


        mov ax, [pac_y]
        cmp ax, 186
        jge wc3
        jmp end_wc3
        wc3:
            mov ax, 186
            mov [pac_y], ax
        end_wc3:
        ret
; AI/BOTS ###########################################################################################################
walking_rout:
    r_rout: 
            call sleep
            call delete_pacman
            mov ax, [bot_speed]
            add [pac_x], ax

            mov ax, 0x0C0E
            call draw_pacman_right

            mov bx, [pac_x]
            cmp bx, 283
            jl r_rout
            xor bx, bx
    d_rout:
            call sleep
            call delete_pacman
            mov ax, [bot_speed]
            add [pac_y], ax

            mov ax, 0x0C0E
            call draw_pacman_down
            

            mov bx, [pac_y]
            cmp bx, 163
            jl d_rout
            xor bx, bx
    l_rout:
            call sleep
            call delete_pacman
            mov ax, [bot_speed]
            sub [pac_x], ax

            mov ax, 0x0C0E
            call draw_pacman_left

            mov bx, [pac_x]
            cmp bx, 23
            jg l_rout
            xor bx, bx
    u_rout:
            call sleep
            call delete_pacman
            mov ax, [bot_speed]
            sub [pac_y], ax

            mov ax, 0x0C0E
            call draw_pacman_upper

            mov bx, [pac_y]
            cmp bx, 23
            jg u_rout
            xor bx, bx
    ret
bot_speed dw 29
times 4092-($-$$) db 0   ; Pad to 510 bytes
dw 0x1122
dw 0x1122