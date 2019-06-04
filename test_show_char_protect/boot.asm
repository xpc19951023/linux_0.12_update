[BITS 16]
org 0x7c00
jmp start
start:
mov al,1       ;one sector
mov ah,2       ;read sectors
mov bx,0x1000  ;
mov es,bx      ;buffer es:bx=1000:0
mov bx,0       
mov cx,0x0022  ;cl=22h 34 sector    ch=0 cyl	
mov dx,0x2080   ;dh=20h head    dl=0 floopy 80 disk
;mov cx,0002
;mov dx,0x0000
int 0x13
jnc ok_load
die:
jmp die
ok_load:
mov ax,0x1000
mov ds,ax
mov si,0
mov di,0
mov es,di
mov cx,512
cpy:
movsb
dec cx
jcxz cpy_done
jmp cpy
cpy_done: 
;enable a20
;mov dx,0x92
;in al,dx
;or al,0x02
;out dx,al
cli
mov dx,0
mov ds,dx
lgdt [gdt_48]
mov  eax,cr0
or  eax,1
mov cr0,eax
jmp dword 0x08:0
gdt_48:
DW 24
DW gdt,0
gdt:
DW 0,0,0,0    ;null

DW 0Xffff
DW 0X0000
DW 0X9b00
DW 0X00cf

DW 0Xffff
DW 0X8000
DW 0X930b
DW 0X00cf

TIMES 510-($-$$) DB 0

DW 0XAA55
