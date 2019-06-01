bits 16
reps:
        mov ah,0x00     ;在寄存器ah中指定功能号0x00
        int 0x16        ;执行中断0x16的0x00号功能:从键盘读字符
                        ;返回字符的ASCII码到寄存器al
        mov ah,0x0e     
        mov bl,0x07     ;???
        int 0x10        ;执行中断0x10的0x0e号功能
jmp reps          
times 510-($-$$) db 0
dw 0xaa55
