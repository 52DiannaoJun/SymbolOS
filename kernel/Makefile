# /Symbol-OS/Makefile
# Encoding = UTF-8
# Athor = DiannaoJun
# Create on 23/12/02

# Paths
TMP_PATH	:=	./tmp
ifndef	GCCPATH
GCC_PATH	:=	
endif

# Compilers
AS	:=	nasm
CC	:=	$(GCCPATH)gcc
LD	:=	$(GCCPATH)ld
CP	:=	cp
MAKE:=	make

# Arguments
CFLAGS	:=	-Wall -Wno-format -Wno-unused  -static -m32 -I./lib/include -Wno-unused-parameter -ffunction-sections -nostdlib -nostdinc -fno-builtin -ffreestanding -fno-pie
ifdef	DBG
CFLAGS	+=	-g
endif

# Files
OUT	:=	OS.img
K_OBJS	:=	shell/shell.bin shell/basic.bin shell/font_ascii.bin shell/font_gb2312.bin

# Main Script
default:	com
vhd:		com
	qemu-img convert -f raw -O vmdk $(OUT) OS.vmdk
com:		clean	compile
clean:
	-mkdir $(TMP_PATH)
	rm -rf *.bin
	rm -rf *.sys
	rm -rf *.obj
	rm -rf *.lst
	rm -rf $(OUT)
	rm -rf $(TMP_PATH)/*
	rm -rf shell/*.bin
compile:	image
image:		mbr.bin	kernel.bin loader.bin
	dd if=/dev/zero of=$(OUT) bs=512 count=2880
	dd if=$(TMP_PATH)/mbr.bin of=$(OUT) seek=0 bs=512 count=1 conv=notrunc
	dd if=$(TMP_PATH)/fat.bin of=$(OUT) seek=1 bs=512 count=14 conv=notrunc
	dd if=$(TMP_PATH)/loader.bin of=$(OUT) seek=32 bs=512 count=2 conv=notrunc
	dd if=$(TMP_PATH)/kernel.bin of=$(OUT) seek=34 bs=512 count=12 conv=notrunc
mbr.bin:	ipl.asm	fat.asm
	$(AS) -f bin ipl.asm -o $(TMP_PATH)/mbr.bin
	$(AS) -f bin fat.asm -o $(TMP_PATH)/fat.bin
loader.bin: loader.asm
	$(AS) -f bin loader.asm -o $(TMP_PATH)/loader.bin -l $(TMP_PATH)/loader.lst
kernel.bin:	${K_OBJS}
	$(LD) -m elf_i386 --oformat binary -o $(TMP_PATH)/kernel.bin -T shell/shell.lds $^
casm:
	$(CC) $(CFLAGS) -c shell/shell.c -o $(TMP_PATH)/shell.s -S
%.bin: %.c
	$(CC) $(CFLAGS) -c $< -o $@
%.bin: %.asm
	$(AS) -f elf $< -o $@