.model small
.stack 64
.data
	seed   dw 13666
	two    dw 2
	ten    dw 10
	fifty  dw 50
	file_name    DB "high.txt",0             
	file_handler DW ?
	input_name        LABEL BYTE
	input_name_max    DB    11
	input_name_act    DB    ?
	high_score_player DB    11 DUP(' ')
    check_distance dw ?
	front_screen_page_number db 0
	back_screen_page_number db 1
	char_for_print_as_ascii db ?
	row_for_print_as_ascii db ?
	col_for_print_as_ascii db ?
	;t_rexcopter image
	t_rex_image_1 db 00h,00h,00h,00h,00h,05h,05h,05h,05h,05h,00h,00h,00h,00h,00h,00h,00h,00h,00h ; 19x9
db 0Ch,00h,00h,00h,00h,00h,00h,00h,05h,05h,05h,05h,05h,05h,00h,00h,00h,00h,00h ; 19x9
db 00h,0Ch,00h,00h,00h,00h,00h,25h,25h,25h,25h,25h,25h,25h,00h,00h,00h,00h,00h ; 19x9   
db 00h,00h,0Ch,00h,00h,00h,00h,25h,25h,25h,25h,00h,00h,25h,25h,00h,00h,00h,00h ; 19x9   
db 00h,00h,00h,0Ch,0Ch,25h,25h,25h,25h,25h,25h,25h,25h,25h,25h,00h,00h,00h,00h ; 19x9
db 00h,00h,00h,00h,00h,25h,25h,25h,25h,25h,25h,25h,00h,00h,00h,00h,00h,00h,00h ; 19x9   
db 00h,00h,00h,00h,00h,23h,25h,00h,23h,25h,00h,00h,00h,00h,00h,00h,00h,00h,00h ; 19x9      
db 00h,00h,00h,00h,00h,23h,00h,00h,23h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h ; 19x9        
db 00h,00h,00h,00h,00h,23h,23h,00h,23h,23h,00h,00h,00h,00h,00h,00h,00h,00h,00h


 
    cactus_image    db 1Ch,1Ch,00h,1Ch,1Ch,00h,00h,00h,00h
					db 1Ch,1Ch,00h,1Ch,1Ch,00h,00h,00h,00h
					db 1Ch,1Ch,00h,1Ch,1Ch,00h,00h,00h,00h
					db 1Ch,1Ch,00h,1Ch,1Ch,00h,00h,1Ch,1Ch
					db 1Ch,1Ch,1Ch,1Ch,1Ch,00h,00h,1Ch,1Ch
					db 00h,1Ch,1Ch,1Ch,1Ch,00h,00h,1Ch,1Ch
					db 00h,00h,00h,1Ch,1Ch,00h,00h,1Ch,1Ch
					db 00h,00h,00h,1Ch,1Ch,1Ch,1Ch,1Ch,1Ch
					db 00h,00h,00h,1Ch,1Ch,1Ch,1Ch,1Ch,1Ch
					db 00h,00h,00h,1Ch,1Ch,00h,00h,00h,00h
					db 00h,00h,00h,1Ch,1Ch,00h,00h,00h,00h
					db 00h,00h,00h,1Ch,1Ch,00h,00h,00h,00h
 

 

	t_rex_x   		dw ?
	t_rex_y   		dw ?
	t_rex_fall_speed dw ?
	t_rex_jump_speed dw ?
	t_rex_width 		dw ?
	t_rex_height     dw ?
	t_rex_image_start_address dw ?
 
	; top_map_pos_y     db 320 dup(?)
	bottom_map_pos_y  db 320 dup(?)
	map_velocity      dw ?
	map_gradient      db ?
	map_color         db 1Ch
	.map_ending       dw ?
	map_direction     db ? ;0 = down, 1 = up
	high_score    dw ?
	current_score dw 0
	loop_block_count db ?
	lose_cactus_score_mark dw ?
 
	cactus_pos_y dw ?
	cactus_pos_x dw ?
	cactus_image_width dw ?
	cactus_image_height dw ?
	cactus_exist db 1
 
	;string message
	.interface_msg1 db "Score:"
	.start_screen_msg1 db "The t_rexcopter Game"
	.start_screen_msg2 db "Press any key to fly up  "
	.start_screen_msg3 db "Release to fall down     "
	.start_screen_msg4 db "Press 1/2/3 to change color"
	.start_screen_msg5 db "Highscore:"
	.start_screen_msg6 db "By Player:"
	.game_over_msg1 db "GAME OVER!!!!"
	.game_over_msg2 db "SPACE - TRY AGAIN"
	.game_over_msg3 db "  ESC - EXIT     "
 
	.game_over_msg4 db "   CONGRATULATION      "
	.game_over_msg5 db "YOU WON PLAYER "
	.game_over_msg6 db "YOUR NAME > "
 
;------------------------------------------------------------------------------------------code segment start------------------------------------------------------------------------------------ 
.code
main proc
	mov ax,@data
    mov ds,ax
	mov es,ax
	mov t_rex_image_start_address, offset t_rex_image_1
	call randomize_seed
	start:
	call initialize_variable
	call set_video_mode
	call start_screen
	loop_frame:
		call spawn_t_rex			
		call spawn_map			
		call spawn_cactus			
		call print_interface	
		call flip_screen		
	    call check_collision

		cmp al,1
			je lose    
		cmp al,0
			je no_collision

		no_collision:
		add current_score,1
		call update_difficulty
		mov dx, 1       
		call sleep
		call clear_back_screen
		jmp loop_frame
	lose:
		call game_over_screen
		jc start	
		call exit	
main endp
 
spawn_cactus proc
	mov ax,current_score
	mov dx,0
	div fifty	    
	cmp dl,0
	je put_cactus_to_right_side
	continue_spawn_cactus:
	call draw_cactus
	ret
 
	put_cactus_to_right_side:
		mov cactus_pos_x,310
		mov ah,0

        mov ax, 0
		mov cactus_pos_y,ax; clear độ cao hiện tại của cây xương rồng
		add cactus_pos_y,168; cho giá trị chân cây xương rồng bằng đường chân trời
		mov cactus_exist,1
		jmp continue_spawn_cactus
spawn_cactus endp
 
; ==================================

draw_cactus proc
	cmp cactus_exist,1
	je proceed_draw_cactus		
		ret				
	proceed_draw_cactus:
	mov cx,cactus_pos_x 
	mov dx,cactus_pos_y 
	mov si,offset cactus_image     
	draw_cactus_horizontal:
		mov al,[si]    
		cmp al,00h     
			je skip_draw_pixel_2
		mov ah,0ch 
		mov bh,back_screen_page_number 
		int 10h    
		skip_draw_pixel_2:
		inc si
		inc cx     
		mov ax,cx          
		sub ax,cactus_pos_x
		cmp ax,cactus_image_width
			jng draw_cactus_horizontal
 
		mov cx,cactus_pos_x 
		inc dx       
 
		mov ax,dx
		sub ax,cactus_pos_y
		cmp ax,cactus_image_height
			jng draw_cactus_horizontal
 
	mov ax,map_velocity	
	sub cactus_pos_x,ax
	js cactus_out_of_bound   
	ret
	cactus_out_of_bound:
		mov cactus_exist,0
	ret
draw_cactus endp
 
; ==================================

initialize_variable proc	
	mov t_rex_x,50 			
	mov t_rex_y,170			
	mov t_rex_fall_speed,4	
	mov t_rex_jump_speed,40
	mov t_rex_width,18       
	mov t_rex_height,8		
	mov map_velocity,10	
	mov map_gradient,1		
	mov map_color,0fh
	mov current_score,0
	mov si,0
	mov cx,320
 
	mov si,0
	mov cx,320
	.reset_bottom_map_pos:			
		mov bottom_map_pos_y[si],180
		inc si
		loop .reset_bottom_map_pos
 
	call read_highscore_from_file		
 
	mov cactus_pos_x,300 			
	mov cactus_pos_y,100			
	mov cactus_image_width,8      
	mov cactus_image_height,11		
 	
 
	mov lose_cactus_score_mark,100
	ret
initialize_variable endp
 
; ==================================

start_screen proc	
 .start_screen_begin:
	call draw_t_rex
	call draw_map
 
	mov ax,1300h          
	mov bh,back_screen_page_number 
	mov bl,1011b			
	lea bp,.start_screen_msg1
	mov cx,19				
	mov dh,2				
	mov dl,10				
	int 10h
 
	mov ax,1300h
	mov bh,back_screen_page_number
	mov bl,1011b			
	lea bp,.start_screen_msg2
	mov cx,25				
	mov dh,11				
	mov dl,12				
	int 10h
 
	mov ax,1300h
	mov bh,back_screen_page_number  
	mov bl,1011b			
	lea bp,.start_screen_msg3
	mov cx,25				
	mov dh,12				
	mov dl,12				
	int 10h
 
	mov ax,1300h
	mov bh,back_screen_page_number  
	mov bl,1011b			
	lea bp,.start_screen_msg4
	mov cx,27				
	mov dh,13				
	mov dl,12				
	int 10h
 
	mov ax,1300h
	mov bh,back_screen_page_number  
	mov bl,1011b			
	lea bp,.start_screen_msg5
	mov cx,10				
	mov dh,22				
	mov dl,2				
	int 10h
 
	mov ax,high_score			
	mov row_for_print_as_ascii,22
	mov col_for_print_as_ascii,12
	call print_as_ascii
 
	mov ax,1300h
	mov bh,back_screen_page_number 
	mov bl,1011b			
	lea bp,.start_screen_msg6
	mov cx,10				
	mov dh,22				
	mov dl,18				
	int 10h
 
	mov ax,1300h
	mov bh,back_screen_page_number 
	mov bl,1111b			
	lea bp,high_score_player 
	mov ch,0
	mov cl,input_name_act				
	mov dh,22				
	mov dl,28				
	int 10h
 
	call flip_screen
	mov ah,07h
	int 21h
	cmp al,31h
		je change_to_t_rex_image_1
	ret
	change_to_t_rex_image_1:
		mov t_rex_image_start_address, offset t_rex_image_1
		jmp .start_screen_begin
 
		jmp .start_screen_begin
start_screen endp
 
; ==================================

update_difficulty proc		
	cmp current_score,100
		je phase_1
	cmp current_score,200
		je phase_2
	cmp current_score,300
		je phase_3
	cmp current_score,400
		je phase_4
	cmp current_score,500
		je phase_5
	cmp current_score,600
		je phase_6
	cmp current_score,700
		je phase_7
	ret
	phase_1:	
		sub bottom_map_pos_y[319],4
		mov map_gradient, 2
		ret
	phase_2:
		sub bottom_map_pos_y[319],4
		ret
	phase_3:
		sub bottom_map_pos_y[319],4
		ret
	phase_4:
		mov map_velocity,12
		mov lose_cactus_score_mark,75
		ret
	phase_5:
		mov map_velocity,14
		ret
	phase_6:
		mov map_velocity,16
		mov lose_cactus_score_mark,50
		ret
	phase_7:
		mov map_velocity,18
		mov map_gradient, 3
		ret
update_difficulty endp
 
; ==================================

check_collision proc	
    mov si,t_rex_width
	add si,50 

    ;check vị trí hiện tại cây xương rồng
    mov ax, cactus_pos_x; vị trí hiện tại của cây xương rồng
    mov bx, 50; tọa độ x của khủng long
    cmp ax, bx
        je check_location; nếu tọa đô của cây xương rồng trùng với khủng long, kiểm tra va ch

    jmp no_collide;

    check_location:
	mov ax,t_rex_y; vị trí hiện tại của khủng long
	mov bx,168; chiều cao của bình xănh
	cmp bx,ax; nếu vị trí hiện tại của khủng long bé hơn hoặc bàng cây xương rồng nghĩa là đã chạm xương rồng
		jbe collide; nhảy đến hàm collide
 
	no_collide:
		mov al,0; không có va chạm
		ret
    collide:
		mov al,1; đã va chạm
		ret
 
check_collision endp
 
; ==================================

game_over_screen proc	
	mov ax,current_score
	cmp high_score,ax
	jb broke_record
		mov ah,02h
		mov bh,front_screen_page_number
		mov dh,11			
		mov dl,14			
		int 10h
		mov si,0
		print_game_over_animation:
			mov ah,02h
			mov dl,.game_over_msg1[si]
			int 21h
			mov dx,2		
			call sleep
			inc si
			cmp si,13
			jb print_game_over_animation
 
		mov ax,1300h
		mov bh,front_screen_page_number
		mov bl,1111b			
		lea bp,.game_over_msg2	
		mov cx,17				
		mov dh,12				
		mov dl,12				
		int 10h
 
		mov ax,1300h
		mov bh,front_screen_page_number
		mov bl,1111b			
		lea bp,.game_over_msg3	
		mov cx,17				
		mov dh,13				
		mov dl,12				
		int 10h
 
		.get_input_for_end_or_start_again:
			mov ah,07h
			int 21h
 
			cmp al,32
			je play_again
			cmp al,27
			je end_game
			jmp .get_input_for_end_or_start_again
 
		end_game:
			clc
			ret
		play_again:
			stc	
			ret
 
 
	broke_record:
		mov high_score,ax
 
		mov ax,1300h
		mov bh,front_screen_page_number
		mov bl,1011b			
		lea bp,.game_over_msg4	
		mov cx,23				
		mov dh,12				
		mov dl,10				
		int 10h
 
		mov ax,1300h
		mov bh,front_screen_page_number
		mov bl,1011b			
		lea bp,.game_over_msg5	
		mov cx,15				
		mov dh,13				
		mov dl,10				
		int 10h
 
		mov ax,1300h
		mov bh,front_screen_page_number
		mov bl,1111b			
		lea bp,high_score_player 
		mov ch,0
		mov cl,input_name_act				
		mov dh,13				
		mov dl,25				
		int 10h
 
		mov ax,1301h
		mov bh,front_screen_page_number
		mov bl,1011b			
		lea bp,.game_over_msg6	
		mov cx,12				
		mov dh,14				
		mov dl,10				
		int 10h
 
		MOV AH,0AH
		LEA DX,input_name  
		INT 21H
		XOR AH,AH
		MOV AL,input_name_act
		MOV SI,AX         
		MOV high_score_player[SI],' '
 
		call write_highscore_to_file
		stc
		ret
game_over_screen endp
 
 
; ==================================

print_interface proc	
	mov ax,1300h
	mov bh,back_screen_page_number 
	mov bl,1011b			
	lea bp,.interface_msg1		
	mov cx,6				
	mov dh,1				
	mov dl,2				
	int 10h
	mov ax,current_score
	mov row_for_print_as_ascii,1
	mov col_for_print_as_ascii,8
	call print_as_ascii
 
		mov al,[si]
		mov ah,0ch
		mov bh,back_screen_page_number
		int 10h
		inc si
		inc cx 
		mov ax,cx
 
	mov loop_block_count,al
 
	ret
	no_need_print_cactus_block:
	ret
print_interface endp
 
 
; ==================================

spawn_map proc	
	call draw_map
	ret
spawn_map endp

draw_map proc
	mov si,0   
	draw_map_1:
		mov dh,0
		; mov dl,top_map_pos_y[si] 
		draw_top_map:
			MOV CX,SI 
			mov ah,0ch 
			mov al,map_color 
			mov bh,back_screen_page_number
			int 10h    
			sub dl,13  
			; cmp dl,top_map_pos_y[si]
			jb draw_top_map
 
		mov dh,0
		mov dl,bottom_map_pos_y[si]  

		inc si
		cmp si,320
		jb draw_map_1
	ret
draw_map endp
 
; ==================================

spawn_t_rex proc
	call kbhit
		test al,al
		jz fall
		jump:
            mov check_distance, 169; 
            mov ax, t_rex_y
            sub check_distance, ax; kiểm tra độ cao của khủng long, nếu không chạm đất thì cho rơi xuống
            jge skip;
			mov ax,t_rex_jump_speed
			sub t_rex_y, ax
			jmp skip    
		fall: 
            mov check_distance, 170; 
            mov ax, t_rex_y
            sub check_distance, ax; kiểm tra độ cao của khủng long, nếu không chạm đất thì cho rơi xuống
            jle skip;
            fall2:
                mov ax,t_rex_fall_speed
                add t_rex_y, ax	
        skip:
			call draw_t_rex
	ret
spawn_t_rex endp
 
; ==================================

draw_t_rex proc
	mov cx,t_rex_x 
	mov dx,t_rex_y 
	mov si,t_rex_image_start_address     
	draw_t_rex_horizontal:
		mov al,[si]   
		cmp al,00h    
			je skip_draw_pixel
		mov ah,0ch
		mov bh,back_screen_page_number 
		int 10h    
		skip_draw_pixel:
		inc si
		inc cx    
		mov ax,cx         
		sub ax,t_rex_x
		cmp ax,t_rex_width
			jng draw_t_rex_horizontal
 
		mov cx,t_rex_x
		inc dx       
		mov ax,dx             
		sub ax,t_rex_y
		cmp ax,t_rex_height
			jng draw_t_rex_horizontal
	ret
draw_t_rex endp
 
; ==================================

read_highscore_from_file proc	
	mov ah,3dh               
	mov al,0h
	lea dx,file_name
	int 21h
	mov file_handler,ax
 
	mov ah,3fh              
	mov bx,file_handler
	mov cx,2
	lea dx,high_score
	int 21h  
 
	mov ah,3fh              
	mov bx,file_handler
	mov cx,1
	lea dx,input_name_act
	int 21h  
 
	mov ah,3fh             
	mov bx,file_handler
	mov cx,11
	lea dx,high_score_player
	int 21h  
 
	mov ah,3eh              
	mov bx,file_handler
	int 21h
	ret
read_highscore_from_file endp
 
 
; ==================================

write_highscore_to_file proc	
	mov ah,3dh              
	mov al,1h
	lea dx,file_name
	int 21h
	mov file_handler,ax
 
	mov ah,40h               
	mov bx,file_handler
	mov cx,2
	lea dx,high_score
	int 21h 
 
	mov ah,40h                 
	mov bx,file_handler
	mov cx,1
	lea dx,input_name_act
	int 21h 
 
	mov ah,40h                
	mov bx,file_handler
	mov cx,11
	lea dx,high_score_player
	int 21h 
 
 
	mov ah,3eh               
	mov bx,file_handler
	int 21h
	ret
write_highscore_to_file endp
 
; ==================================

kbhit proc
	mov al, 0			
	mov ah, 1		
	int 16h			
	jz .kbhit_end			
	mov ax, 0	
	int 16h			
	ret		
 
	.kbhit_end:
		mov ax, 0		
		ret
kbhit endp
 
randomize_seed proc
	mov ax, 0			
	int 1Ah			
	mov seed, dx 		
	ret
randomize_seed endp

sleep proc
	mov ax, 0	
	mov bx, dx	
 
	int 1ah		
	add bx, dx	
 
	.wait:
		int 1ah		
		cmp dx, bx
		jne .wait	
		ret
sleep endp
 
; ============================================================

print_as_ascii proc
	push ax			
	push cx
	push dx
 
	xor cx,cx
	xor dx,dx
	mov bx, 10             
 
	div_by_ten:                            
		div ten
		push dx 
		inc cx    
		xor dx,dx
		cmp ax, 0   
		jne div_by_ten                   
 
	display_ascii:     
		xor dx,dx		
		pop dx       
		add dl, 30h             	         
		mov char_for_print_as_ascii, dl
 
		push cx
		mov ax,1300h
		mov bh,back_screen_page_number  
		mov bl,1111b			
		lea bp,char_for_print_as_ascii
		mov cx,1				
		mov dh,row_for_print_as_ascii		
		mov dl,col_for_print_as_ascii		
		int 10h
		pop cx
 
		inc col_for_print_as_ascii
		loop display_ascii  
 
	pop dx			
	pop cx		
	pop ax	
	ret
print_as_ascii endp 
 
flip_screen proc
	mov ah,05h		
	mov al,back_screen_page_number		
	int 10h
 
	xor back_screen_page_number,1
	xor front_screen_page_number,1
	ret
flip_screen endp
clear_back_screen proc
	push es
	cmp back_screen_page_number,0
	je clear_page_0
	mov ax, 0a200h
	.clear_screen_continue:
	mov es, ax             
	mov ax, 0h   
	xor di, di         
	mov cx, 4000  
	rep stosw           
	mov ax,0600h
	mov bh,61h
	pop es
	ret
	clear_page_0:
		mov ax, 0a000h
		jmp .clear_screen_continue
clear_back_screen endp
set_video_mode proc
	mov ax, 000dh	
	int 10h			
	ret
set_video_mode endp
 
exit proc
	call set_video_mode
	mov ax,4c00h
	int 21h
exit endp
end main 
