org 0x7c00
bits 16
call check_a20
sub   ax,1
je    ok_a20
call disp_no_a20
jmp $
ok_a20:
call disp_ok_a20
jmp $
disp_no_a20:
    mov   ax,no_a20_msg
    mov cx,23
    jmp disp
disp_ok_a20:
    mov    ax, ok_a20_msg
    mov    cx,19
disp:
    mov    bp, ax            ; ES:BP = 串地址
    mov    ax, 01301h        ; AH = 13,  AL = 01h
    mov    bx, 000ch        ; 页号为0(BH = 0) 黑底红字(BL = 0Ch,高亮)
    mov    dx, 0            ; 将DL中的ASCII码显示到屏幕,将'\0'送到DL中，并显示
    int    10h                ; 10h 号中断
    ret                    ; 返回到调用处
;the following code is public domain licensed
 
; Function: check_a20
;
; Purpose: to check the status of the a20 line in a completely self-contained state-preserving way.
;          The function can be modified as necessary by removing push's at the beginning and their
;          respective pop's at the end if complete self-containment is not required.
;
; Returns: 0 in ax if the a20 line is disabled (memory wraps around)
;          1 in ax if the a20 line is enabled (memory does not wrap around)
 
check_a20:
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je check_a20__exit
 
    mov ax, 1
 
check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf 
ret
ok_a20_msg: db  "A20 line is enable!"
no_a20_msg: db "A20 line is not enable!"
times 510-($-$$) db 0
dw  0xaa55
