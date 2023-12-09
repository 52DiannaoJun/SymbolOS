; /Symbol-OS/loader.asm
; Encoding = UTF-8
; Athor = DiannaoJun
; Create on 23/12/03

;Define 
VBEMode	equ 0x0000f000
VBEMaxX	equ 0x0000f002
VBEMaxY	equ 0x0000f004
VBERamP	equ 0x0000f006
Cyls	equ 0x0000f00a
VBEByte	equ 0x0000f00b
SHELLBS	equ 0x00100000
KERNELP equ 0x00008000
KERNELN equ 0x00010000

%macro SEG_NULL 0
	dw 0, 0
	db 0, 0, 0, 0
%endmacro

%macro SEG 3
	; SEG(type,base,lim)
	dw (((%3) >> 12) & 0xffff), ((%2) & 0xffff)
	db (((%2) >> 16) & 0xff),(0x90 | (%1)),(0xC0 | (((%3) >> 28) & 0xf)),(((%2) >> 24) & 0xff)
%endmacro

; Application segment type bits
%define STA_X		0x8	    ; Executable segment
%define STA_E		0x4	    ; Expand down (non-executable segments)
%define STA_C		0x4	    ; Conforming code segment (executable only)
%define STA_W		0x2	    ; Writeable (non-executable segments)
%define STA_R		0x2	    ; Readable (executable segments)
%define STA_A		0x1	    ; Accessed

; System segment type bits
%define STS_T16A	0x1	    ; Available 16-bit TSS
%define STS_LDT		0x2	    ; Local Descriptor Table
%define STS_T16B	0x3	    ; Busy 16-bit TSS
%define STS_CG16	0x4	    ; 16-bit Call Gate
%define STS_TG		0x5	    ; Task Gate / Coum Transmitions
%define STS_IG16	0x6	    ; 16-bit Interrupt Gate
%define STS_TG16	0x7	    ; 16-bit Trap Gate
%define STS_T32A	0x9	    ; Available 32-bit TSS
%define STS_T32B	0xB	    ; Busy 32-bit TSS
%define STS_CG32	0xC	    ; 32-bit Call Gate
%define STS_IG32	0xE	    ; 32-bit Interrupt Gate
%define STS_TG32	0xF	    ; 32-bit Trap Gate

; %define DBG
[org 0xc000]
[bits 16]

jmp entry

Text:
	ret
	StrNewline	db 0x0a, 0x0d
	StrNothing	db 0
	LoadSucMsg	db "Loader...", 0
	FMD_MSG	db	"Illegal access to media devices!", 0
	RFE_MSG	db	"Floppy read error!", 0
	RFS_MSG	db	"Floppy read in success!", 0
	EnterMsg db	0x0a, 0x0d, "Entering the protected mode", 0
	MenuString:
		db "[0] Symbol OS", 0x0a, 0x0d
		db "[1] Boot from the disk", 0x0a, 0x0d
		db "[2] Boot from the floppy", 0x0a, 0x0d
		db "[3] Reset", 0x0a, 0x0d
		db "[4] Restart", 0x0a, 0x0d
		db "[5] Shutdown", 0x0a, 0x0d
		db "Your option:", 0
	CharBuf	db 0
gdt_start:
	SEG_NULL							; null seg
	SEG STA_X|STA_R, 0x0, 0xffffffff	; code seg
	SEG STA_W, 0x0, 0xffffffff	        ; data seg
	gdt_end:
idt_start:
	idt_null:
		dq 0x0000000000000000
	idt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1			; Size of our GDT, always less one of the true size
	dd gdt_start
idt_descriptor:
	dw idt_end - idt_start - 1			; Size of our IDT, always less one of the true size
	dd idt_start


load:
	mov ax, 0x0800
	mov es, ax
	mov ch, 0x00
	mov dh, 0x00
	mov cl, 0x01

	mov ah, 0x01
	mov dl, [0x7c24] 
	int 0x13
	jnc .readloop
	mov si, FMD_MSG
	jmp .err
	.readloop:
		xor si, si 
		.retry:
			mov ah, 0x02
			mov al, 0x01
			mov bx, 0x0000
			mov dl, [0x7c24] 
			int 0x13
			jnc .next
			inc si 
			cmp si, 8
			jge .error
			mov ah, 0x00 
			mov dl, [0x7c24]  
			int 0x13
			jmp .retry
		.error:
			mov si, RFE_MSG
			.err	call puts
			call final
		.next:
			mov ax, es 
			add ax, 0x0020
			mov es, ax
			inc cl 
			cmp cl, [0x7c18]
			jle .readloop

			mov cl, 1
			inc dh
			cmp dh, [0x7c1a]
			jl .readloop

			xor dh, dh
			inc ch
			cmp ch, 16
			jl .readloop
		ret


entry:
	mov si, LoadSucMsg  
	call puts
	call cls
	mov si, MenuString
	call putstr
	.for:
		mov ah, 0x00
		int 0x16
		mov [CharBuf], al
		mov ah, 0x0e
		mov bx, 0x01
		mov al, [CharBuf]
		int 0x10

		cmp al, '0'
		je System
		cmp al, '1'
		je readDisk
		cmp al, '2'
		je readFloppy
		cmp al, '3'
		je Reset
		cmp al, '4'
		je Restart
		cmp al, '5'
		je Shutdown
		jmp .for

readDisk:
	mov byte [0x7c24], 0x80
	call load
	jmp Reset
readFloppy:
	mov byte [0x7c24], 0x00
	call load
	jmp Reset
Shutdown:
	MOV AX, 5301H			;5301h方法:APM实模式控制
	XOR BX, BX				;设备ID: 0000h (=BIOS)
	INT 15H					;15h中断
	MOV AX, 530EH			;530Eh方法:APM设备版本
	MOV CX, 0102H			;版本: APM v1.2
	INT 15H					;15h号中断
	MOV AX, 5307H			;5307h: APM电源管理
	MOV BL, 01H				;设备ID: 0001h (=所有设备)
	MOV CX, 0003H			;电源管理: 0003h (=关闭)
	INT 15H					;15h中断
Reset:
	jmp 0x0000:0x7c00
Restart:
	jmp 0xFFFF:0x0000

final:
	hlt
	jmp final

io:
	puts:
		call putstr
		call endl
		ret
	putstr:
		mov al, [si]
		inc si
		cmp al, 0x00
		jne .putloop
		ret
		.putloop:
			mov ah, 0x0e
			mov bx, 0x0f
			int 0x10
		jmp putstr
	endl:
		push si 
		mov si,StrNewline
		call putstr
		pop si 
		ret
	cls:
		mov ah, 0x6 
		mov al, 0x0 
		int 0x10
		ret

System:
	%ifdef DBG
	xchg bx, bx
	JMP setScrn320
	%endif
	mov ax, 0x9000
	mov es, ax 
	mov di, 0
	mov ax, 0x4f00
	int 0x10 
	cmp ax, 0x004f
	jne setScrn320
	mov ax, [es:di+4]
	cmp ax, 0x0200
	jl setScrn320
	mov cx, 0x0107
	mov ax, 0x4f01
	int 0x10
	cmp ax, 0x004f
	jne setScrn320
	cmp byte [es:di+0x19], 8
	jne setScrn320
	cmp byte [es:di+0x1b], 4
	jne setScrn320
	mov ax, [es:di+0x00]
	and ax, 0x0080
	jz setScrn320
	mov bx, 0x4107
	mov ax, 0x4f02
	int 0x10 
	mov byte [VBEByte], 8
	mov word [VBEMode], 0x0107
	mov ax, [es:di+0x12]
	mov [VBEMaxX], ax 
	mov ax, [es:di+0x14]
	mov [VBEMaxY], ax 
	mov eax, [es:di+0x28]
	mov [VBERamP], eax
	jmp setScrn320End
	setScrn320:
		mov al, 0x13
		mov ah, 0x00 
		int 0x10
		mov byte [VBEByte], 8
		mov word [VBEMode], 13
		mov word [VBEMaxY], 200
		mov word [VBEMaxX], 320
		mov dword [VBERamP], 0x000a0000
	setScrn320End:
	mov si, EnterMsg
	call puts

	mov al, 0xff 
	out 0x21, al 
	nop 
	out 0xa1, al 
	cli
	call waitkbdout
	mov al, 0xd1
	out 0x64, al 
	call waitkbdout
	mov al, 0xdf
	out 0x60, al 
	call waitkbdout

	lgdt [gdt_descriptor]
	; lidt [idt_descriptor]
	mov eax, cr0
	and eax, 0x7fffffff
	or eax, 0x00000001
	mov cr0, eax

	jmp PModeMain

waitkbdout:
	in al, 0x64
	and al, 0x2 
	jnz waitkbdout
	ret

PModeMain:
	mov ax, 0x10
	mov ds, ax 
	mov es, ax 
	mov fs, ax 
	mov gs, ax 
	mov ss, ax 
	mov ebp, 0x7c00
	mov esp, ebp

	mov edi, KERNELN
	mov esi, KERNELP
	mov ecx, (18*2*32)*512/4
	call memcpy
	mov dword [0x00],0x00114514
	nop
	jmp dword 0x08:0x00014400
	jmp $

memcpy:
	mov eax, [esi]
	mov [edi], eax
	add esi, 4
	add edi, 4
	dec ecx
	jnz memcpy
	ret