org 0x7c00
section .16
bits 16
mov ax,0
mov es,ax
mov ah,02h
mov al,1
mov ch,0
mov cl,34
mov dh,32
mov dl,080h
mov bx,0x6000
int 13h
jmp 0:0x6000
times 510-($-$$) db 0
dw  0xaa55
