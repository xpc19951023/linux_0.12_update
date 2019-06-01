section .16
bits  16
org     07c00h                  ; 告诉编译器程序加载到7c00处
start:       mov     ax, cs
        mov     ds, ax
        mov     es, ax
	xor     dx,dx
	mov     cx, 10
        mov     bh,0
        mov     ah,2
        int     10h
loop:   push    cx
        call    DispChar                 ; 调用显示字符串例程
        pop     cx
        dec     cx
        mov     ax,0
	inc     dl
        xor     ax,cx
        jnz     loop
	int 19h
DispChar:
        mov   ah,0eh
	mov   al,'B'
	mov   bx,0h
        int 10h
	ret
	times   510-($-$$)      db      0       ; 填充剩下的空间，使生成的二进制代码恰好为512字节
	dw      0xaa55                          ; 结束标志
