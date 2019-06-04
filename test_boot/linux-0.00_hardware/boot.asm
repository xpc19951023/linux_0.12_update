;	boot.s
;
; It then loads the system at 0x10000, using BIOS interrupts. Thereafter
; it disables all interrupts, changes to protected mode, and calls the 

org 0x7c00
BOOTSEG equ 0x07c0
SYSSEG  equ 0x1000			; system loaded at 0x10000 (65536).
SYSLEN  equ 17				; sectors occupied.

load_system:
	mov	dx,0x2080
;	mov	dx,0x2000
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
times 510-($-$$) db 0
	dw   0xAA55
