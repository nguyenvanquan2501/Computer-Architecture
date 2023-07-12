section .data
    A db 'hello world',0
    B db 'lo',0
    n equ $-A
    m equ $-B
    count db 0

section .text
    global _start

_start:
    mov ecx, n    ; ecx = độ dài chuỗi A
    mov edx, m    ; edx = độ dài chuỗi B
    mov ebx, A    ; ebx = địa chỉ bắt đầu của chuỗi A
    mov esi, B    ; esi = địa chỉ bắt đầu của chuỗi B

    mov byte [count], 0  ; khởi tạo biến đếm số lần xuất hiện của chuỗi B

    ; Lặp lại cho mỗi vị trí i của chuỗi A
    mov esi, B    ; đặt lại con trỏ chuỗi B để bắt đầu so sánh từ đầu
    mov edi, ebx  ; đặt con trỏ chuỗi A tại vị trí i
    loop_start:
        cmp byte [edi], 0  ; kiểm tra xem đã kết thúc chuỗi A chưa
        je done

        cmpsb    ; so sánh ký tự của chuỗi A và chuỗi B
        jne loop_start  ; nếu không trùng khớp, quay lại vị trí i+1

        ; Nếu đã tìm thấy chuỗi B, tăng biến đếm lên 1
        cmp esi, B    ; kiểm tra xem đã đến cuối chuỗi B chưa
        je found
        jmp loop_start

    found:
        inc byte [count]  ; tăng biến đếm lên 1
        jmp loop_start

    done:
        ; In ra kết quả
        mov eax, 4
        mov ebx, 1
        mov ecx, count
        mov edx, 1
        int 0x80

        ; Thoát chương trình
        mov eax, 1
        xor ebx, ebx
        int 0x80