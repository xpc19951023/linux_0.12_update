[BITS 32]
ORG 0
;lgdt [GDT]
mov ax,0x10
start:
mov gs,ax
mov bl,'s'
mov [gs:((80*0+0)*2)],bl
jmp $
;GDT:
;DW 24
;DW gdt,0
;gdt:
;DW 0,0,0,0

;DW 0x7fff
;DW 0X0000
;DW 0X9a00
;DW 0X00d0

;DW 0X7fff
;DW 0X8000;基地址0x0b8000
;DW 0XF20b
;DW 0X00d0
;jmp start
