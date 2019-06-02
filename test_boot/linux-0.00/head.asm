;  head.s contain: the 32-bit startup code.
;  Two L3 task multitasking. The code of tasks are in kernel area, 
;  just like the Linux. The kernel code is located at 0x10000. 
SCRN_SEL	equ 0x18
TSS0_SEL	equ 0x20
LDT0_SEL	equ 0x28
TSS1_SEL	equ 0X30
LDT1_SEL	equ 0x38
bits  32
setup_int:
        mov     al,0x11                ; initialization sequence
        out     0x20,al                ; send it to 8259A-1
        out     0xA0,al                ; and to 8259A-2
        mov     al,0x20                ; start of hardware int's (0x20)
        out     0x21,al
        mov     al,0x28                ; start of hardware int's 2 (0x28)
        out     0xA1,al
        mov     al,0x04                ; 8259-1 is master
        out     0x21,al
        mov     al,0x02                ; 8259-2 is slave
        out     0xA1,al
        mov     al,0x01                ; 8086 mode for both
        out     0x21,al
        out     0xA1,al
        mov     al,0xfb                ; enable interrupts for now
        out     0x21,al
        mov     al,0xfe
        out     0xA1,al
	cli
	
enable_rtc_interrupt_source:
	mov al ,0x0a					   ;select A register of RTC
	out 0x70,al
	in al,0x71                         ;get value of A register
	xor al,0x0f                       ;500ms interrupt
	out 0x71,al                         ;out config into A register
	mov al,0x0b
	out 0x70,al
	in  al,0x71
	mov al,0x40
	out 0x71,al                          ;enable term interrupt
startup_32:
	mov ax,0x10
	mov ds,ax
	lss esp,[init_stack]
; setup base fields of descriptors.
	call setup_idt
	call setup_gdt
        mov  ax,0x10
	mov  ds,ax
	mov  es,ax
	mov  fs,ax
	mov  gs,ax
	lss esp,[init_stack]
; setup up timer 8253 chip.
;       mov  al,0x36
;	mov  edx,0x43
;	out  dx,al
;	mov  eax,11930 ;timer clock is 1.193280Mhz,1193280 times/s  1193280/100=11932
;	mov  edx,0x40
;	out  dx,al
;	mov  al,ah
;	out  dx,al
; setup timer & system call interrupt descriptors.
	mov eax,0x00080000
	mov  ax,timer_interrupt
	mov  dx,0x8E00
	mov  ecx,0x28
	lea esi,[idt+ecx*8]
	mov [esi],eax
	mov [esi+4],edx
	mov  ax,system_interrupt
	mov dx,0xef00
	mov ecx,0x80
	lea esi,[idt+ecx*8]
	mov [esi],eax
	mov [esi+4],edx
; unmask the timer interrupt.
;	movl $0x21, %edx
;	inb %dx, %al
;	andb $0xfe, %al
;	outb %al, %dx

; Move to user mode (task 0)
	pushfd
	and dword [esp],0xffffbfff ;disable NT(Nested  Task),for iret
	popfd
	mov eax,TSS0_SEL
	ltr ax
	mov eax,LDT0_SEL
	lldt ax 
	mov dword [current],0
	sti
	push dword 0x17
	push dword init_stack
	pushfd
	push dword 0x0f
	push dword task0
	iret
        jmp $
;****************************************;
setup_gdt:
	lgdt [lgdt_opcode]
	ret

setup_idt:
	lea edx,[ignore_int]
	mov eax,0x00080000
	mov ax,dx
	mov dx,0x8E00
	lea edi,[idt]
	mov ecx ,256
rp_sidt:

	mov [edi],eax
	mov [edi+4],edx
	add dword edi,8
	dec ecx
	jne rp_sidt
	lidt [lidt_opcode]
	ret
; -----------------------------------
write_char:
	push gs
	push ebx
;	pushl %eax
	mov  ebx,SCRN_SEL
	mov  gs,bx
	mov  bx ,[scr_loc]
	shl  ebx,1
	mov  byte  [gs:ebx],al
	shr  ebx,1
	inc  ebx
	cmp ebx, 2000
	jb w1
	mov ebx,0
w1:	mov [scr_loc],ebx
;	popl %eax
	pop ebx
	pop gs
	ret

;***********************************************;
;* This is the default interrupt "handler" :-) *;
align 4
ignore_int:
	push ds
	push eax
	mov eax,0x10
	mov ds, ax
	mov eax, 67            ;* print 'C' *;
	call write_char
	pop eax
	pop ds
	iret

;* Timer interrupt handler *; 
align 4
timer_interrupt:
	push ds
	push eax
	mov eax, 0x10
	mov ds, ax
	mov al, 0x20
	out 0xa0,al
	out 0x20,al
        mov al,0x0c
        out 0x70,al
;        mov al,0
	in al,0x71
;	xor ax,ax
	mov  eax,1
	cmp   [current],eax
	je t1
	mov  [current],eax
	jmp  TSS1_SEL:0
	jmp t2
t1:	
	mov dword [current],0
	jmp  TSS0_SEL:0
t2:	pop eax
	pop ds
	iret

;* system call handler *;
align 4
system_interrupt:
	push ds
	push edx
	push ecx
	push ebx
	push eax
	mov edx,0x10
	mov ds,dx
	call write_char
	pop eax
	pop ebx
	pop ecx
	pop edx
	pop ds
	iret

;*********************************************;
current:
	dd 0
scr_loc:
    dd 0

align 4
lidt_opcode:
    dw 256*8-1		; idt contains 256 entries
	dd idt		; This will be rewrite by code. 
lgdt_opcode:
	dw (end_gdt-gdt)-1	; so does gdt 
	dd gdt		; This will be rewrite by code.
align 8
idt:		; idt is uninitialized
	times 256  dq 0
gdt:	
        dq 0x0000000000000000	;* NULL descriptor *;
	dq 0x00c09a00000007ff	;* 8Mb 0x08, base equ 0x00000 *;
	dq 0x00c09200000007ff	;* 8Mb 0x10 *;
	dq 0x00c0920b80000002	;* screen 0x18 - for display *;

	dw 0x0068, tss0, 0xe900, 0x0	; TSS0 descr 0x20
	dw 0x0040, ldt0, 0xe200, 0x0	; LDT0 descr 0x28
	dw 0x0068, tss1, 0xe900, 0x0	; TSS1 descr 0x30
	dw 0x0040, ldt1, 0xe200, 0x0	; LDT1 descr 0x38
end_gdt:
	times 128 dd 0
init_stack:                          ; Will be used as user stack for task0.
	dd init_stack
	dw 0x10

;*************************************;
align 8
ldt0:	
	dq 0x0000000000000000
	dq 0x00c0fa00000003ff	; 0x0f, base equ 0x00000
	dq 0x00c0f200000003ff	; 0x17

tss0:	
	dd 0 			;* back link *;
	dd krn_stk0, 0x10		;* esp0, ss0 *;
	dd 0, 0, 0, 0, 0		;* esp1, ss1, esp2, ss2, cr3 *;
	dd 0, 0, 0, 0, 0		;* eip, eflags, eax, ecx, edx *;
	dd 0, 0, 0, 0, 0		;* ebx esp, ebp, esi, edi *;
	dd 0, 0, 0, 0, 0, 0 		;* es, cs, ss, ds, fs, gs *;
	dd LDT0_SEL, 0x8000000	;* ldt, trace bitmap *;

	times 128 dd 0
krn_stk0:
;	dd 0

;************************************;
align 8
ldt1:	
	dq 0x0000000000000000
	dq 0x00c0fa00000003ff	; 0x0f, base equ 0x00000
	dq 0x00c0f200000003ff	; 0x17

tss1:	
	dd 0 			;* back link *;
	dd krn_stk1, 0x10		;* esp0, ss0 *;
	dd 0, 0, 0, 0, 0		;* esp1, ss1, esp2, ss2, cr3 *;
	dd task1, 0x200		;* eip, eflags *;
	dd 0, 0, 0, 0		;* eax, ecx, edx, ebx *;
	dd usr_stk1, 0, 0, 0		;* esp, ebp, esi, edi *;
	dd 0x17,0x0f,0x17,0x17,0x17,0x17 ;* es, cs, ss, ds, fs, gs *;
	dd LDT1_SEL, 0x8000000	;* ldt, trace bitmap *;
	times 128 dd 0
krn_stk1:

;************************************;
task0:
	mov eax,0x17
	mov ds,ax
	mov al,65
	int 0x80
	mov ecx,0xfff
ta1:	loop ta1
	jmp task0 

task1:
	mov eax,0x17
	mov ds,ax
	mov al,66
	int 0x80
	mov ecx, 0xfff
ta11:	loop ta11
	jmp task1

	times 128 dd 0
usr_stk1:
