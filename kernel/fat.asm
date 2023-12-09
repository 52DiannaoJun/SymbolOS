; /Symbol-OS/fat.asm
; Encoding = UTF-8
; Athor = DiannaoJun
; Create on 23/12/04

dw 0xfff0
times 13 dw 0xfff1
dw 15
dw 16
dw 17
dw 18
dw 19
dw 20
dw 21
dw 22
dw 23
dw 24
dw 25
dw 26
dw 27
dw 29
dw 30
dw 0xffff
dw 32
dw 33
dw 0xffff

times 512-$+$$ db 0

times 512*12 db 0

File1:
db "LOADER      "	; 文件名		0+12
db "SYS "			; 後綴名		12+4
db "LOAD ",0		; 系統保留	16+6
dw 0x0020 			; 起始簇號	22+2
dd 0x00000400		; 長度Byte	24+4
db 00100101b		; 屬性		28+1
times 32+File1-$ db 0


; 内存分配表
; 0x0000-0x000c	顯示配置保存処
; 0x7c00-0x7dff 引導扇區保存処