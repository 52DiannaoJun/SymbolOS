; /Symbol-OS/ipl.asm
; Encoding = UTF-8
; Athor = DiannaoJun
; Create on 23/12/03

; Define
org	0x7c00
bits	16
BytPerSec	equ 512
SecPerTra	equ 18
SecPerCls	equ 1
DiskHeadc	equ 2
DiskSizeS	equ 2880
DiskSizeB	equ DiskSizeS*BytPerSec
FATsCount	equ 1
MbrSecCnt	equ 1
FATSizeSc	equ	(2*DiskSizeS/SecPerCls+BytPerSec-1)/BytPerSec
RootSizeC	equ (32-MbrSecCnt-FATsCount*FATSizeSc)*16
DeviceFID	equ	0xf0
DeviceBID	equ	0x00

; 磁盤聲明
jmp entry
nop
db "SYMBOLOS"
dw BytPerSec
db SecPerCls
dw MbrSecCnt
db FATsCount
dw RootSizeC
dw DiskSizeS
db DeviceFID
dw FATSizeSc
dw SecPerTra
dw DiskHeadc
dd 0x00
dd DiskSizeS

db DeviceBID
db 0x00
db 0x29
dd 0xffffffff
db "SYMBOLOS03",0
db "SFS16   "
times 2 db 0

; 主程序
entry:
	mov ax, 0
	mov ss, ax
	mov sp, 0x7c00
	mov ds, ax

	mov si, entry-21
	call puts
	mov si, entry-10
	call puts

	call load
	; call success
	mov ax, 14
	mov ds, ax
	call puts
	mov ax, 15
	mov ds, ax
	call puts
	call final

final:
	hlt
	jmp final
strcmp:
	xor al, al
	push bx
	call .for
	pop bx
	ret
	.for:
		cmp ah, 0
		jg .cont
		mov al, 1
		ret
	.cont:
		mov bh, [di]
		mov bl, [si]
		dec ah 
		inc si 
		inc di
		cmp bh, bl
		je .for
		ret

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
load:
	mov ax, 0x0800
	mov es, ax
	mov ch, 0x00
	mov dh, 0x00
	mov cl, 0x01

	mov ah, 0x01
	mov dl, DeviceBID 
	int 0x13
	jnc .readloop
	mov si, FMD_MSG
	jmp .err
	.readloop:
		xor si, si 
		.retry:
			mov ah, 0x02
			mov al, 0x02
			mov bx, 0x0000
			mov dl, DeviceBID 
			int 0x13
			jnc .next
			inc si 
			cmp si, 8
			jge .error
			mov ah, 0x00 
			mov dl, DeviceBID  
			int 0x13
			jmp .retry
		.error:
			mov si, RFE_MSG
			.err	call puts
			call final
		.next:
			mov ax, es 
			add ax, 0x0040
			mov es, ax
			inc cl 
			cmp cl, SecPerTra
			jle .readloop

			mov cl, 1
			inc dh
			cmp dh, DiskHeadc  
			jl .readloop

			xor dh, dh
			inc ch
			cmp ch, 16
			jl .readloop
		ret
success:
	mov si, RFS_MSG
	call puts
	mov ax, 0x0800
	mov ds, ax
	xor si, si 
	.for:
		mov al, [si]
		cmp al, 0
		je .noc
		mov ah, 0x0e
		mov al, "F"
		int 0x10
		call putstr
		.noc:
		mov ax, ds 
		add ax, 2
		mov ds, ax
		cmp ax, 0x0a000
		jl .for
	ret

Text:
	ret
	StrNewline	db 0x0a, 0x0d
	StrNothing	db 0
	FMD_MSG	db	"Illegal access to media devices!", 0
	RFE_MSG	db	"Floppy read error!", 0
	RFS_MSG	db	"Floppy read in success!", 0



times 510+$$-$ db 0
db 0x55, 0xaa