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
;enter protected
     cli
     cld
        lgdt    [gdt_ptr]
a32     mov  dword eax,cr0
a32     or  dword eax,1
a32     mov dword cr0,eax 
jmp  dword  0x10:code32
jmp  $
DispChar:
        mov   ah,0eh
	mov   al,'B'
	mov   bx,0h
        int 10h
	ret
section .32  align=16
bits 32
code32:
     jmp word 0x10:code32_1
code32_1:
     jmp word 0x10:code32
gdt_ptr:
        dw  0x30                          ;  /* limit (48 bytes = 6 GDT entries) */
        dd   gdt                 ; /* base */
gdt:
        dw   0, 0, 0, 0            ;          /* NULL  */
        dw   0, 0, 0, 0             ;         /* unused */

        dw   0xFFFF                  ;        /* 4Gb - (0x100000*0x1000 = 4Gb) */
        dw   0                        ;       /* base address = 0 */
        dw   0x9B00                    ;      /* code read/exec */
        dw   0x00CF                     ;     /* granularity = 4096, 386 (+5th nibble of limit) */

        dw   0xFFFF                      ;    /* 4Gb - (0x100000*0x1000 = 4Gb) */
        dw   0x0                          ;   /* base address = 0 */
        dw   0x9300                        ;  /* data read/write */
        dw   0x00CF                         ; /* granularity = 4096, 386 (+5th nibble of limit) */

	times   510-($-gdt+64+32+2)      db      0       ; 填充剩下的空间，使生成的二进制代码恰好为512字节
	dw      0xaa55                          ; 结束标志
