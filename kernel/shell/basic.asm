[bits 32]
GLOBAL asm_hlt, asm_cli, asm_sti, asm_nop
GLOBAL in8, in16, in32, out8, out16, out32
GLOBAL load_gdtr, load_idtr, load_tr
GLOBAL load_eflags, load_cr0, store_cr0, store_eflags
GLOBAL far_jmp, debug

[section .text]
asm_hlt:		; void asm_hlt (void);
	hlt
	ret
asm_cli:		; void asm_cli (void);
	cli
	ret
asm_sti:		; void asm_sti (void);
	sti
	ret
asm_stihlt:		; void asm_stihlt (void);
	sti 
	hlt 
	ret 
asm_nop:		; void asm_nop (void);
	nop 
	ret
in8:			; int in8 (int port);
	mov edx, [esp+4]
	xor eax, eax
	in al, dx 
	ret
in16:			; int in16 (int port);
	mov edx, [esp+4]
	xor eax, eax
	in ax, dx 
	ret
in32:			; int in32 (int port);
	mov edx, [esp+4]
	in eax, dx 
	ret
out8:			; void out8 (int port, int data);
	mov edx, [esp+4]
	mov eax, [esp+8]
	out dx, al
	ret
out16:			; void out16 (int port, int data);
	mov edx, [esp+4]
	mov eax, [esp+4]
	out dx, ax 
	ret
out32:			; void out32 (int port, int data);
	mov edx, [esp+4]
	mov eax, [esp+4]
	out dx, eax
	ret
load_gdtr:		; void load_gdtr (int limit, int addr);
	mov ax, [esp+4]
	mov [esp+6], ax 
	lgdt [esp+6]
	ret 
load_idtr:		; void load_idtr (int limit, int addr);
	mov ax, [esp+4]
	mov [esp+6], ax 
	lidt [esp+6]
	ret 
load_tr:		; void load_tr (int tr);
	ltr [esp+4]
	ret
load_eflags:	; int load_eflags (void);
	pushfd 
	pop eax
	ret
store_eflags:	; void store_eflags (int eflags);
	mov eax, [esp+4] 
	push eax
	popfd
	ret
load_cr0:		; int load_cr0 (void);
	mov eax, cr0
	ret
store_cr0:		; void store_cr0 (int eflags);
	mov eax, [esp+4] 
	mov cr0, eax
	ret
far_jmp:		; void far_jmp(int eip, int cs);
	jmp far [esp+4]
	ret
debug:			; void debug(void);
	xchg bx, bx
	ret