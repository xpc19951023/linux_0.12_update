;	boot.s
;
; It then loads the system at 0x10000, using BIOS interrupts. Thereafter
; it disables all interrupts, changes to protected mode, and calls the 

org 0x7c00
BOOTSEG equ 0x07c0
SYSSEG  equ 0x1000			; system loaded at 0x10000 (65536).
SYSLEN  equ 17				; sectors occupied.

start:
call check_a20
sub   ax,1
je    ok_a20
call disp_no_a20
jmp $
ok_a20:
call disp_ok_a20
	jmp	go
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

go:	mov	ax,cs
	mov	ds,ax
	mov	ss,ax
	mov	sp,0x400		; arbitrary value >>512

; ok, we've written the message, now
load_system:
	mov	dx,0x2080
	mov	cx,0x0022
	mov	ax,SYSSEG
	mov	es,ax
	xor	bx,bx
	mov	ax,0x200+SYSLEN
	int 	0x13
	jnc	ok_load
die:	jmp	die

; now we want to move to protected mode ...
ok_load:
	cli			; no interrupts allowed ;
	mov	ax, SYSSEG
	mov	ds, ax
	xor	ax, ax
	mov	es, ax
	mov	cx, 0x2000
	sub	si,si
	sub	di,di
	rep
	movsw
	mov	ax, 0
	mov	ds, ax
	lidt	[idt_48]		; load idt with 0,0
	lgdt	[gdt_48]		; load gdt with whatever appropriate

; absolute address 0x00000, in 32-bit protected mode.
	mov	ax,0x0001	; protected mode (PE) bit
	lmsw	ax		; This is it;
	jmp dword 0x08:0		; jmp offset 0 of segment 8 (cs)

gdt:	
	dw	0,0,0,0		; dummy

	dw	0x07FF		; 8Mb - limit=2047 (2048*4096=8Mb)
	dw	0x0000		; base address=0x00000
	dw	0x9A00		; code read/exec
	dw	0x00C0		; granularity=4096, 386

	dw	0x07FF		; 8Mb - limit=2047 (2048*4096=8Mb)
	dw	0x0000		; base address=0x00000
	dw	0x9200		; data read/write
	dw	0x00C0		; granularity=4096, 386

idt_48: 
	dw	0		; idt limit=0
	dw	0,0		; idt base=0L
gdt_48: 
dw	0x7ff		; gdt limit=2048, 256 GDT entries
	dw	gdt,0	; gdt base = 07xxx
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
align 2
ok_a20_msg: db  "A20 line is enable!"
no_a20_msg: db "A20 line is not enable!"

times 510-($-$$) db 0
	dw   0xAA55
