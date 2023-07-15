.model small
.stack 100
.data
	seed   dw 13666
	two    dw 2
	ten    dw 10
	fifty  dw 50
	input_name        LABEL BYTE   ;nhap ten nguoi choi khi ket thuc
	input_name_max    DB    11     ; gioi han do dai ten
	input_name_act    DB    ?		;mau cua ten
	high_score_player DB    11 DUP(' ') 	; khởi tạo mảng tên người chơi
	front_screen_page_number db 0 ; hiển thị các nội dung đồ họa chính
	back_screen_page_number db 1  ; hiển thị các nội dung đồ họa tạm thời và các hiệu ứng động
	char_for_print_as_ascii db ?	; số điểm
	row_for_print_as_ascii db ?		
	col_for_print_as_ascii db ?
	;t_rexcopter image - Hình ảnh trực thăng, mồi và lửa, sử dụng https://c...content-available-to-author-only...n.io/abdhass/full/jdRNdj
	t_rex_image_1   db 00h,00h,00h,00h,00h,00h,06h,06h,06h,06h,06h,06h,06h,06h,06h,06h,06h,06h,06h ;19x9
				   db 08h,08h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,08h,00h,00h,00h,00h,00h,00h
				   db 04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,08h,08h,08h,03h,03h,00h,00h,00h
				   db 00h,08h,08h,08h,08h,08h,08h,08h,08h,08h,08h,08h,08h,03h,03h,03h,03h,00h,00h
				   db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,08h,08h,08h,03h,03h,03h,03h,03h,00h
				   db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,04h,04h,04h,03h,03h,03h,03h,00h 
				   db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,04h,04h,04h,04h,04h,00h,00h
				   db 00h,00h,00h,00h,00h,00h,00h,00h,06h,00h,00h,00h,00h,06h,00h,06h,00h,00h,06h
				   db 00h,00h,00h,00h,00h,00h,00h,00h,00h,06h,06h,06h,06h,06h,06h,06h,06h,06h,00h
				    
	;Khởi tạo khủng long
	;Tọa độ khủng long
	t_rex_x   		dw ? 
	t_rex_y   		dw ?
    check_distance dw ?
	t_rex_fall_speed dw ? ;Tốc độ rơi của khủng long
	t_rex_jump_speed dw ? ;Tốc độ nhảy của khủng long
	;Chiều rộng, cao của khủng long
	t_rex_width 		dw ?
	t_rex_height     dw ?
	;Vị trí bắt đầu
	t_rex_image_start_address dw ?

	;Khởi tạo map
	;Tọa độ trên dưới của map
	; top_map_pos_y     db 320 dup(?) 	;trên
	bottom_map_pos_y  db 320 dup(?)	;dưới
	map_velocity      dw ? ;Vận tốc chuyển động của cây xương rồng
	map_gradient      db ?
	map_color         db 0FH ;Màu
	.map_ending       dw ? 
	map_direction     db ? ;0 = down, 1 = up
	high_score    dw ?
	current_score dw 0	;điểm hiện tại
	loop_block_count db ?
	.interface_msg1 db "Score:"
	.start_screen_msg1 db "----DINO T-REX ---------"
	.start_screen_msg2 db "Press any key to fly up  "
	.start_screen_msg3 db "Release to fall down     "
	.start_screen_msg4 db "Press space to start"
	.start_screen_msg5 db "Highscore:"
	.start_screen_msg6 db "By Player:"
	.game_over_msg1 db "GAME OVER!!!!"
	.game_over_msg2 db "SPACE - TRY AGAIN"
	.game_over_msg3 db "  ESC - EXIT     "
	.game_over_msg4 db "YOU WON PLAYER "
	.game_over_msg5 db "YOUR NAME > "
	
;------------------------------------------------------------------------------------------code segment start------------------------------------------------------------------------------------ 
.code
main proc
	mov ax,@data
  	mov ds,ax
	mov es,ax
	mov t_rex_image_start_address, offset t_rex_image_1 ;lấy địa chỉ của khủng long 1
	start:
	call initialize_variable	;khởi tạo các biến
	call set_video_mode			;gọi chế độ đồ họa
	call start_screen			;khởi tạo màn hình bắt đầu

	;bắt đầu chạy
	loop_frame:
		call spawn_t_rex			;khủng long
		call spawn_map			;map
		call print_interface	;hiện điểm hiện tại
		call flip_screen		;lật màn hình sau ra màn hình trước
	 	call check_collision 	;kiểm tra va chạm
		
		;nếu va chạm thì nhảy đến lose, không thì nhảy đến no_collision
		cmp al,1
			je lose    ;cờ ZF, 0 = no collision, 1 = collision with map
			; cờ ZF=1 nếu al = 0, cờ ZF=0 nếu al=1
		cmp al,0
			je no_collision 
		no_collision:
		add current_score,1		;điểm hiện tại được cộng thêm 1 sau mỗi vòng lặp
		; call update_difficulty 	;gọi hàm tăng độ khó
		mov dx, 1       ;sleep for 1 tick
		call sleep
		call clear_back_screen
		jmp loop_frame
	lose:
		call game_over_screen
		jc start	;cờ ZF, nếu cờ ZF = 1, bắt đầu lại game
		call exit	; else exit
main endp

; khởi tạo các biến
; ==================================
; METHOD	: initialize_variable
; INPUT		: n/a
; RETURN	: n/a
; ==================================
initialize_variable proc	
	mov t_rex_x,50	;toạ độ x bắt đầu của khủng long
	mov t_rex_y,170	;tọa độ y bắt đầu của khủng long
	mov t_rex_fall_speed,3	;tốc độ rơi
	mov t_rex_jump_speed,30   ;tốc độ bay lên
	mov t_rex_width,18       ;kich thuoc cua khủng long
	mov t_rex_height,8		;
	mov map_velocity,10	;tốc độ di chuyển map
	mov map_gradient,1		; độ dịch của các kí tự trong map
	mov map_color,0fh  	;khởi tạo màu map
	mov current_score,0		;khởi tạo số điểm hiện tại = 0

	;reset top_map
	mov si,0
	mov cx,320				;kích thước của map
	.reset_top_map_pos:			
		; mov top_map_pos_y[si],40
		inc si
		loop .reset_top_map_pos
	
	;reset bottom_map
	mov si,0
	mov cx,320
	.reset_bottom_map_pos:			
		mov bottom_map_pos_y[si],180
		inc si
		loop .reset_bottom_map_pos
		
	ret
initialize_variable endp

; ==================================
; METHOD	: start_screen
; INPUT		: n/a
; RETURN	: n/a
; ==================================
;hiển thị màn hình bắt đầu của trò chơi
;hiển thị khủng long,map, thông báo ...
start_screen proc	
 .start_screen_begin:
	call draw_t_rex  				;khởi tạo khủng long
	call draw_map					;khởi tạo map
	
   ;in ra và khởi tạo màu cho msg1
	mov ax,1300h         			;hiển thị chuỗi
	mov bh,back_screen_page_number 	;ghi vào trang sau trước, sau đó chỉ lật màn hình
	mov bl,10 						;khởi tạo màu(xanh lá)
	lea bp,.start_screen_msg1		;lấy địa chỉ bắt đầu của msg_1
	mov cx,19						;độ dài string
	mov dh,2						;row(truc y)
	mov dl,10						;column(truc x)
	int 10h							;in chuỗi
	
  ;in ra và khởi tạo màu cho msg2
	mov ax,1300h         
	mov bh,back_screen_page_number
	mov bl,11						;màu xanh dương
	lea bp,.start_screen_msg2
	mov cx,25				
	mov dh,11				
	mov dl,12				
	int 10h 

	;in ra và khởi tạo màu cho msg3
	mov ax,1300h          
	mov bh,back_screen_page_number  
	mov bl,11		
	lea bp,.start_screen_msg3
	mov cx,25				
	mov dh,12			
	mov dl,12
	int 10h
	
  ;in ra và khởi tạo màu cho msg4
	mov ax,1300h          
	mov bh,back_screen_page_number  
	mov bl,11			
	lea bp,.start_screen_msg4
	mov cx,27				
	mov dh,13				
	mov dl,12				
	int 10h
	
  ;in ra và khởi tạo màu cho msg5
	mov ax,1300h          
	mov bh,back_screen_page_number  
	mov bl,10			
	lea bp,.start_screen_msg5
	mov cx,10				
	mov dh,22				
	mov dl,2				
	int 10h
	
  ;in tính điểm
	mov ax,high_score				;lưu điểm vào ax
	mov row_for_print_as_ascii,22	;tọa độ x để lưu điểm
	mov col_for_print_as_ascii,12	;tọa độ y để lưu điểm
	call print_as_ascii 			;gọi hàm in điểm
	
	; ;in msg6 "By Player:"
	mov ax,1300h          ;request display string,al 01 = advance cursor
	mov bh,back_screen_page_number ;  write to back page first, later only flip screen
	mov bl,10			;attribute
	lea bp,.start_screen_msg6;address of string in es:bp
	mov cx,10				;length of string
	mov dh,22				;row
	mov dl,18				;column
	int 10h
	
	;in tên người chơi vừa thắng
	mov ax,1300h          ;request display string,al 01 = advance cursor
	mov bh,back_screen_page_number ;  write to back page first, later only flip screen
	mov bl,1111b			;attribute
	lea bp,high_score_player ;address of string in es:bp
	mov ch,0
	mov cl,input_name_act				;length of string
	mov dh,22				;row
	mov dl,28				;column
	int 10h
	
	call flip_screen ;thay đổi page_screen
	;Đổi icon khủng long
	mov ah, 7 ;đọc một ký tự từ bàn phìm dưới dạng mã ascii
	int 21h
	cmp al,31h ;ascii của 1 dưới dạng hex
		je change_to_t_rex_image_1
	ret
	change_to_t_rex_image_1:
		mov t_rex_image_start_address, offset t_rex_image_1
		jmp .start_screen_begin

start_screen endp

;update độ khó
; ==================================
; METHOD	: update_difficulty
; INPUT		: n/a
; RETURN	: n/a
;description: add score and change difficulty/phase when reach certain amount of score
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
	phase_1:	; 
		; add top_map_pos_y[319],4			;make map narrower
		sub bottom_map_pos_y[319],4
		ret
	phase_2:
		; add top_map_pos_y[319],4			;make map narrower
		sub bottom_map_pos_y[319],4
		ret
	phase_3:
		; add top_map_pos_y[319],4			;make map narrower
		sub bottom_map_pos_y[319],4
		ret
	phase_4:
		mov map_velocity,12				;số ký tự dịch sang bên trái tăng lên 12
		ret
	phase_5:
		mov map_velocity,14				;số ký tự dịch sang bên trái tăng lên 14
		ret
	phase_6:
		mov map_velocity,16				;số ký tự dịch sang bên trái tăng lên 16
		ret
	phase_7:
		mov map_velocity,18				;số ký tự dịch sang bên trái tăng lên 18
		ret
update_difficulty endp

; ==================================
; METHOD	: check_collision
; INPUT		: t_rex_y,top_map_pos_y,bottom_map_pos_y
; RETURN	: al(0 = no collide map, 1 = collide with map, 2 = collide with fuel)
; ==================================
;kiểm tra va chạm
check_collision proc	
    mov si,t_rex_width
	add si,50
	mov ax,t_rex_y
	;kiểm tra sự va chạm của phần trên trực thăng với cây xương rồng
	; cmp al,top_map_pos_y[si]
	; 	jbe collide_with_map
	cmp al,bottom_map_pos_y[si]
		jae collide_with_map
	;kiểm tra sự va chạm của phần dưới trực thăng với cây xương rồng
	add ax,t_rex_height
	; cmp al,top_map_pos_y[si]
	; 	jbe collide_with_map
	cmp al,bottom_map_pos_y[si]
		jae collide_with_map	
	mov al,2
	ret
	
	;trả về al=0 nếu không va chạm
	no_collide:
		mov al,0
		ret
	;trả về al=1 nếu va chạm
	collide_with_map:
		mov al,1
		ret	
check_collision endp

; ==================================
; METHOD	: game_over_screen
; INPUT		: n/a
; RETURN	: carry flag(1 = again, 0= end)
; ==================================
game_over_screen proc	
	; cập nhập điểm mới nếu cao hơn điểm cũ
	mov ax,current_score
	cmp high_score,ax  ; cmp current_score,high_score
	jb broke_record   ; if high_score < current_score 
		mov ah,02h		;set cursor position
		mov bh,front_screen_page_number		; page 0
		mov dh,11			;row
		mov dl,14			;column
		int 10h			;execute
		mov si,0 ;for indexing of game_over_msg1
		
		;hiệu ứng in gameover
		print_game_over_animation:
			mov ah,02h
			mov dl,.game_over_msg1[si]
			int 21h
			mov dx,2		
			call sleep		;sleep for 2tick
			inc si
			cmp si,13
			jb print_game_over_animation

		;in game_over_msg2
		mov ax,1300h          
		mov bh,front_screen_page_number ;  just write to front screen, screen flickering because no fast moving image in this game over screen
		mov bl,11			
		lea bp,.game_over_msg2	;address of string in es:bp
		mov cx,17				;length of string
		mov dh,12				;row
		mov dl,12				;column
		int 10h
		
		;in game_over_msg3
		mov ax,1300h          ;request display string,al 01 = advance cursor
		mov bh,front_screen_page_number ;  just write to front screen, screen flickering because no fast moving image in this game over screen
		mov bl,11				;attribute
		lea bp,.game_over_msg3	;address of string in es:bp
		mov cx,17				;length of string
		mov dh,13				;row
		mov dl,12				;column
		int 10h
		
		;check ký tự nhập vào xem end game hay play again
		.get_input_for_end_or_start_again:
			mov ah,07h	;nhập input
			int 21h

			cmp al,32  			;nếu là nút space thì chơi lại
			je play_again
			cmp al,27			;nếu là ký tự esc thì thoat
			je end_game
			jmp .get_input_for_end_or_start_again
		
		end_game:
			clc			;end game (set carry flag to 0)
			ret
		play_again:
			stc			;play again(set carry flag to 1)
			ret
			
		
	broke_record:
		mov high_score,ax	 ;ax là current score
		;in game_over_msg4
		mov ax,1300h     
		; chỉ viết lên màn hình phía trước, màn hình nhấp nháy vì không có hình ảnh chuyển động nhanh trong trò chơi này trên màn hình     
		mov bh,front_screen_page_number 
		mov bl,1011b			;attribute
		lea bp,.game_over_msg4	;address of string in es:bp
		mov cx,15				;length of string
		mov dh,11				;row
		mov dl,13				;column
		int 10h
		
		mov ax,1300h         
		mov bh,front_screen_page_number 
		mov bl,1111b			;màu trắng
		lea bp,high_score_player 
		mov ch,0
		mov cl,input_name_act	;độ dài tên
		mov dh,13				;row
		mov dl,25				;column
		int 10h
		
		mov ax,1301h            ;request display string,al 01 = advance cursor
		mov bh,front_screen_page_number ;  just write to front screen, screen flickering because no fast moving image in this game over screen
		mov bl,1011b			;attribute
		lea bp,.game_over_msg5	;address of string in es:bp
		mov cx,12				;length of string
		mov dh,13				;row
		mov dl,13				;column
		int 10h
		
		MOV AH,0AH				;request input string
		LEA DX,input_name  
		INT 21H
		XOR AH,AH
		MOV AL,input_name_act
		MOV SI,AX         
		MOV high_score_player[SI],' '
			
		stc
		ret
game_over_screen endp


; ==================================
; METHOD	: print_interface
; INPUT		: current_score
; RETURN	: N/A
; ==================================
;in ra số điểm khi chạy
print_interface proc	
	mov ax,1300h          ;request display string,al 01 = advance cursor
	mov bh,back_screen_page_number ;  write to back page first, later only flip screen
	mov bl,10			;attribute
	lea bp,.interface_msg1		;address of string in es:bp
	mov cx,6				;length of string
	mov dh,1				;row
	mov dl,2				;column
	int 10h
	mov ax,current_score
	;vị trí in
	mov row_for_print_as_ascii,1  
	mov col_for_print_as_ascii,8
	call print_as_ascii
	
	ret
print_interface endp


; ==================================
; METHOD	: spawn_map
; INPUT		: TOP_map_POS_Y, BOTTOM_map_POS_Y, map_VELOCITY, map_GRADIENT
; RETURN	: N/A
; ==================================
spawn_map proc	
	call update_map_pos
	call draw_map
	ret
spawn_map endp


; ==================================
; METHOD	: update_map_pos
; INPUT		: TOP_map_POS_Y, BOTTOM_map_POS_Y, map_VELOCITY, map_GRADIENT
; RETURN	: N/A
; ==================================

update_map_pos proc
	MOV SI,0
	MOV AX, 320						;mov .map_ending, 320-map_velocity
	SUB AX,map_velocity
	MOV .map_ending,AX
	shift_map_to_left:    ;dịch map sang bên trái
		mov di,si					 ;mov di, si+map_velocity
		add di,map_velocity
		; mov al,top_map_pos_y[di]    ;mov top_map_pos_y[si],top_map_pos_y[di]
		; mov top_map_pos_y[si],al
		mov al,bottom_map_pos_y[di] ;mov bottom_map_pos_y[si],bottom_map_pos_y[di]
		mov bottom_map_pos_y[si],al
		inc si
		cmp si,.map_ending
			jb shift_map_to_left
		
	mov di,si	;mov di, si-1
	sub di,1

	;thay thế vị trí bên phải cây xương rồng
	replace_map_right_side_position:
		;random dịch các kí tự mới
				; call random             ; random number trong ax (0-65535)
		; mov dx,0
		; div two			        ;phần dư lưu trong DL (0 hoặc 1)
		; mov map_direction, dl  ;0 = down, 1 = up
		mov bl,map_gradient    ;lưu độ dịch của map vào bl
		cmp map_direction,0
			je downward_map_pos
		upward_map_pos:
			neg bl					;bl = -map_gradient
		
		downward_map_pos:
		mov ah,bottom_map_pos_y[di] 
		add ah,bl					 ;ah = bottom_map_pos_y[di] + map_gradient
		; mov al,top_map_pos_y[di]    
		add al,bl					 ;al = top_map_pos_y[di] + map_gradient
		cmp al,0
			jb map_out_of_bound
		cmp al,180
			ja map_out_of_bound
		cmp ah,0
			jb map_out_of_bound
		cmp ah,180
			ja map_out_of_bound
			
		mov bottom_map_pos_y[si],ah
		; mov top_map_pos_y[si],al

		end_update_map_pos:
			inc di
			inc si
			cmp si,320
			jb replace_map_right_side_position
		ret
		map_out_of_bound:
			mov ah,bottom_map_pos_y[di]
			mov bottom_map_pos_y[si],ah
			; mov al,top_map_pos_y[di]
			; mov top_map_pos_y[si],al
			jmp end_update_map_pos
update_map_pos endp

; random proc
; 	mov ax, seed
; 	mov dx, 33333
; 	mul dx				; nhân SEED với AX

; 	inc ax				
; 	mov seed, ax		; lưu giá trị seed mới
; 	mov ax, dx			; trả về giá trị ngẫu nhiên trong AX
; 	mov ah, 2;
; 	mov ah, 02h    ; chức năng đặt vị trí con trỏ màn hình
; random endp

; ==================================
; METHOD	: draw_map
; INPUT		: TOP_map_POS_Y, BOTTOM_map_POS_Y,map_color
; RETURN	: N/A
; ==================================
draw_map proc
	mov si,0   ; địa chỉ top_map_pos_y và bottom_map_pos_y
	draw_map_1:
		mov dh,0
		; mov dl,top_map_pos_y[si]     		;khởi tạo vị trí y thành top_map_pos_y
		draw_top_map:
			mov cx,si  						;đặt vị trí x   
			mov ah,0ch 						;đặt cấu hình để viết một pixel
			mov al,map_color 				;thay đổi màu
			mov bh,back_screen_page_number 	;ghi vào trang sau trước, sau đó chỉ lật màn hình
			int 10h    						;thực hiện cấu hình
			sub dl,13  						;dl = độ dày của map
			;giới hạn độ dày để map trên ko bị quá lề
			; cmp dl,top_map_pos_y[si]
			jb draw_top_map
			
		mov dh,0
		mov dl,bottom_map_pos_y[si]  		;đặt vị trí y 
		draw_bottom_map:
			mov cx,si  					 	;khởi tạo màu cho x    
			mov ah,0ch 						;đặt cấu hình để viết một pixel
			mov al,map_color 				;thay đổi màu
			mov bh,back_screen_page_number 	;ghi vào trang sau trước, sau đó chỉ lật màn hình
			int 10h    						;thực hiện cấu hình
			add dl,13						;dl = độ dày của map
			;giới hạn độ dày để map dưới ko bị quá lề
			cmp dl,199
			jb draw_bottom_map
		inc si
		cmp si,320
		jb draw_map_1
	ret
draw_map endp

; ==================================
; METHOD	: spawn_t_rex
; INPUT		: t_rex_X, t_rex_Y, t_rex_SIZE
; RETURN	: N/A
; ==================================
spawn_t_rex proc ;
	call kbhit ;kiểm tra có kí tự nào được nhập từ bàn phím hay không
		cmp al, 0
		je fall			;nếu ko thì nhảy fall
		
		;thay đổi vị trí trục y của khủng long
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
; METHOD	: DRAW_t_rex
; INPUT		: t_rex_X, t_rex_Y, t_rex_SIZE
; RETURN	: N/A
; ==================================
draw_t_rex proc
	mov cx,t_rex_x ; tọa độ x của khủng long
	mov dx,t_rex_y ; tọa độ y của khủng long
	mov si,t_rex_image_start_address      ;địa chỉ của khủng long
	draw_t_rex_horizontal:
		mov al,[si]    		; lưu giá trị màu hiện tại vào al
		cmp al,00h     		; nếu là màu trắng thì không cần vẽ
			je skip_draw_pixel
		mov ah,0ch 			;đặt cấu hình để viết một pixel
		mov bh,back_screen_page_number ;ghi vào trang sau trước, sau đó chỉ lật màn hình
		int 10h    			;thực hiện cấu hình
		skip_draw_pixel:
		inc si
		inc cx     ;cx = cx + 1
		mov ax,cx          ;cx - t_rex_x > t_rex size (y -> ta xuống dòng tiếp theo, n -> ta sang cột tiếp theo)
		sub ax,t_rex_x
		cmp ax,t_rex_width
			jng draw_t_rex_horizontal
		
		mov cx,t_rex_x ;thanh ghi cx quay trở lại cột ban đầu
		inc dx        ;tiến lên một dòng
		
		mov ax,dx            ;dx - t_rex_y > t_rex size (y -> thoát khỏi thủ tục này, n -> chuyển sang dòng tiếp theo)
		sub ax,t_rex_y
		cmp ax,t_rex_height
			jng draw_t_rex_horizontal
	ret
draw_t_rex endp


; ==================================
; METHOD	: KBHIT
; INPUT		: N/A
; RETURN	: RETURNS KEY HIT IN AX (0 = no key hit)
; ==================================
kbhit proc
	mov al, 0			; kiểm tra xem có phím nào bị nhấn không
	mov ah, 1			; nhưng không chặn (không đồng bộ)
	int 16h				; call bios interrupt
	jz .kbhit_end		; nếu không co phím nào được nhập thì nhảy end
	mov ax, 0			; nhận chức năng nhấn phím
	int 16h				; call bios interrupt
	ret		
	
	.kbhit_end:
		mov ax, 0			; trả về ax=0 nếu ko phím nào được nhập
		ret
kbhit endp

; =================================
; PROTOTYPE	: randomize_seed
; INPUT		: seed
; RETURN	: n/a
;description: randomize a number(0-65535) and put into 'seed'
; =================================
;Sử dụng hàm ngắt 1Ah để sinh số ngẫu nhiên, số đó sẽ được lưu ở dx rồi lưu vào seed
randomize_seed proc
	mov ax, 0			; get tick count function 
	int 1Ah				; call BIOS interrupt
	mov seed, dx 		; tickcount as seed
	ret
randomize_seed endp
	


; ============================================================
; METHOD	: SLEEP
; INPUT		: AMOUNT OF MS TO SLEEP IN DX 
; RETURN	: N/A
; ============================================================
;tạm hoãn chương trình
sleep proc
	;int 1ah" là một cuộc gọi ngắt BIOS truy xuất thời gian hệ thống hiện tại trong ticks (1/18.2 giây) và lưu trữ nó trong DX
	mov ax, 0	
	mov bx, dx	; save ms

	int 1ah		
	add bx, dx	; ms + ticks

	.wait:
		int 1ah		
		cmp dx, bx
		jne .wait	; lặp cho đến khi nào dx>=bx
		ret
sleep endp

; ============================================================
; METHOD	: PRINT_AS_ASCII
; INPUT		: AX (the value to be printed), row_for_print_as_ascii (ROW), col_for_print_as_ascii(COL)
; RETURN	: N/A
; description: print number in ascii
; ============================================================

;in số điểm hiện tại
print_as_ascii proc
	push ax			
	push cx
	push dx
	
	xor cx,cx
	xor dx,dx
	mov bx, 10             
	;push các chữ số của điểm vào stack từ hàng đơn vị->
	div_by_ten:                            
		div ten               ;chia thâp phân
		push dx                       
		inc cx               
		xor dx,dx
		cmp ax, 0             ;so sánh thương với số 0
		jne div_by_ten                   
	;in các chữ số
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
		mov cx,1							;length of string
		mov dh,row_for_print_as_ascii		;row
		mov dl,col_for_print_as_ascii		;column
		int 10h
		pop cx
		
		inc col_for_print_as_ascii
		loop display_ascii  
		
	pop dx			
	pop cx		
	pop ax	
	ret
print_as_ascii endp 

;chuyển đổi trang màn hình
flip_screen proc
	mov ah,5							;chuyển đổi trang màn hình
	mov al,back_screen_page_number		;change active screen to back screen
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
	mov es, ax             	; Bắt đầu bộ nhớ video trong phân đoạn 0xA200/a000
	mov ax, 0h    			; Đặt màu thành rõ ràng với 0x00=black
	xor di, di           	; Địa chỉ đích được đặt thành 0
	mov cx, 4000   			; thực hiện 2 byte cùng một lúc
	rep stosw              	; Xóa bộ nhớ video
	mov ax,0600h
	mov bh,61h
	pop es
	ret
	clear_page_0:
		mov ax, 0a000h
		jmp .clear_screen_continue
clear_back_screen endp

;gọi chế độ đồ họa
set_video_mode proc
	mov ax, 000dh	; chế độ 16 màu
	int 10h			;
	ret
set_video_mode endp

exit proc
	call set_video_mode
	mov ax,4c00h
	int 21h
exit endp
end main            
 