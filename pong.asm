.model small
.stack 100h

.data
    window_width    dw 80
    window_height   dw 25
    ball_x          dw 40
    ball_y          dw 12
    ball_vel_x      dw 1
    ball_vel_y      dw 1
    ball_orig_x     dw 40
    ball_orig_y     dw 12
    paddle_left_y   dw 10
    paddle_right_y  dw 10
    paddle_height   dw 4        
    score_left      dw 0
    score_right     dw 0
    win_score       dw 10
    title_msg       db '=== P O N G ===$'
    start_msg       db 'Apasa SPACE pentru a incepe$'
    p1_win_msg      db 'Player 1 (Stanga) a Castigat!$'
    p2_win_msg      db 'Player 2 (Dreapta) a Castigat!$'
    restart_msg     db 'Apasa orice tasta pentru Meniu...$'
    
    char_ball       db 'O'
    char_paddle     db 219     
    char_line       db 179      

.code
main proc
    mov ax, @data
    mov ds, ax
    mov ax, 0B800h      
    mov es, ax
    mov ah, 01h
    mov ch, 20h
    mov cl, 00h
    int 10h

menu_screen:
    call clear_screen
    mov ah, 02h         
    mov bh, 00h
    mov dh, 10          
    mov dl, 33         
    int 10h
    
    mov ah, 09h        
    lea dx, title_msg
    int 21h
    
    mov ah, 02h
    mov dh, 12
    mov dl, 26
    int 10h
    
    mov ah, 09h
    lea dx, start_msg
    int 21h

wait_for_start:
    mov ah, 00h
    int 16h
    cmp al, 32         
    jne wait_for_start

    mov score_left, 0
    mov score_right, 0
    mov paddle_left_y, 10
    mov paddle_right_y, 10
    call reset_ball

game_loop:
    call delay_frame
    call clear_screen
    call draw_ui
    call check_input
    call update_ball
    call check_win_condition
    cmp ax, 1          
    je game_over_screen
    call draw_paddles
    call draw_ball
    mov ah, 01h
    int 16h
    jz continue_loop       
continue_loop:
    jmp game_loop

game_over_screen:
    call clear_screen
    push dx            
    mov ah, 02h
    mov dh, 10
    mov dl, 25
    int 10h
    
    pop dx             
    mov ah, 09h
    int 21h
    mov ah, 02h
    mov dh, 12
    mov dl, 22
    int 10h
    
    mov ah, 09h
    lea dx, restart_msg
    int 21h
    
    mov ah, 00h
    int 16h
    jmp menu_screen

main endp
check_input proc
    mov ah, 01h
    int 16h
    jz end_input       
    mov ah, 00h
    int 16h
    cmp al, 'w'
    je left_up
    cmp al, 'W'
    je left_up
    cmp al, 's'
    je left_down
    cmp al, 'S'
    je left_down
    cmp ah, 48h        
    je right_up
    cmp ah, 50h        
    je right_down
    cmp al, 27
    je force_exit
    
    jmp end_input

left_up:
    cmp paddle_left_y, 0
    jle end_input
    dec paddle_left_y
    dec paddle_left_y  
    jmp end_input

left_down:
    mov bx, window_height
    sub bx, paddle_height
    cmp paddle_left_y, bx
    jge end_input
    inc paddle_left_y
    inc paddle_left_y
    jmp end_input

right_up:
    cmp paddle_right_y, 0
    jle end_input
    dec paddle_right_y
    dec paddle_right_y
    jmp end_input

right_down:
    mov bx, window_height
    sub bx, paddle_height
    cmp paddle_right_y, bx
    jge end_input
    inc paddle_right_y
    inc paddle_right_y
    jmp end_input

force_exit:
    mov ax, 4c00h
    int 21h

end_input:
    mov ah, 01h
    int 16h
    jnz check_input     
    ret
check_input endp

update_ball proc
    mov ax, ball_x
    add ax, ball_vel_x
    mov ball_x, ax   
    mov ax, ball_y
    add ax, ball_vel_y
    mov ball_y, ax
    cmp ball_y, 0
    jle bounce_y
    mov bx, window_height
    dec bx
    cmp ball_y, bx
    jge bounce_y
    cmp ball_x, 0
    jle score_p2    
    mov bx, window_width
    cmp ball_x, bx
    jge score_p1     
    cmp ball_x, 2
    jg check_right_pad  
    mov ax, ball_y
    cmp ax, paddle_left_y
    jl check_right_pad
    mov bx, paddle_left_y
    add bx, paddle_height
    cmp ax, bx
    jg check_right_pad    
    mov ball_vel_x, 1   
    mov ball_x, 3      
    ret

check_right_pad:
    mov bx, window_width
    sub bx, 3
    cmp ball_x, bx
    jl end_update
    mov ax, ball_y
    cmp ax, paddle_right_y
    jl end_update
    mov bx, paddle_right_y
    add bx, paddle_height
    cmp ax, bx
    jg end_update
    mov ball_vel_x, -1 
    mov bx, window_width
    sub bx, 4
    mov ball_x, bx
    ret

bounce_y:
    neg ball_vel_y
    ret

score_p1:
    inc score_left
    call reset_ball
    ret

score_p2:
    inc score_right
    call reset_ball
    ret

end_update:
    ret
update_ball endp

check_win_condition proc  
    mov ax, score_left
    cmp ax, win_score
    je win_left
    
    mov ax, score_right
    cmp ax, win_score
    je win_right
    
    mov ax, 0           
    ret

win_left:
    lea dx, p1_win_msg
    mov ax, 1
    ret

win_right:
    lea dx, p2_win_msg
    mov ax, 1
    ret
check_win_condition endp

reset_ball proc
    mov ax, ball_orig_x
    mov ball_x, ax
    mov ax, ball_orig_y
    mov ball_y, ax
    
    neg ball_vel_x
    ret
reset_ball endp
draw_ui proc
    
    mov cx, 12          
    mov bx, 1          
draw_line_loop:
    mov ax, bx
    mov dx, 80
    mul dx
    add ax, 40         
    shl ax, 1
    mov di, ax
    
    mov al, char_line  
    mov ah, 08h         
    mov es:[di], ax
    
    add bx, 2
    loop draw_line_loop
    mov ax, score_left
    mov di, 320        
    add di, 60         
    call draw_number

    mov ax, score_right
    mov di, 320
    add di, 100         
    call draw_number
    ret
draw_ui endp

draw_number proc
    
    cmp ax, 10
    je draw_10
    
    add al, '0'         
    mov ah, 0Eh         
    mov es:[di], ax
    ret

draw_10:
    mov al, '1'
    mov ah, 0Eh
    mov es:[di], ax
    add di, 2
    mov al, '0'
    mov es:[di], ax
    ret
draw_number endp

draw_paddles proc
    mov cx, paddle_height
    mov bx, paddle_left_y
loop_pad_left:
    mov ax, bx
    mov dx, 80
    mul dx
    add ax, 1
    shl ax, 1
    mov di, ax
    mov al, char_paddle
    mov ah, 0Fh        
    mov es:[di], ax
    inc bx
    loop loop_pad_left

    mov cx, paddle_height
    mov bx, paddle_right_y
loop_pad_right:
    mov ax, bx
    mov dx, 80
    mul dx
    add ax, 78          
    shl ax, 1
    mov di, ax
    mov al, char_paddle
    mov ah, 0Fh
    mov es:[di], ax
    inc bx
    loop loop_pad_right
    ret
draw_paddles endp

draw_ball proc
    mov ax, ball_y
    mov bx, 80
    mul bx
    add ax, ball_x
    shl ax, 1
    mov di, ax
    mov al, char_ball
    mov ah, 0Ch        
    mov es:[di], ax
    ret
draw_ball endp

clear_screen proc
    mov cx, 2000
    xor di, di
    mov ax, 0720h       
    rep stosw
    ret
clear_screen endp

delay_frame proc    
    mov cx, 0
    mov dx, 0C350h     
    mov ah, 86h
    int 15h
    ret
delay_frame endp

end main