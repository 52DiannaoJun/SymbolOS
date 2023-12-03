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
MAKE:=	make

# Arguments
CFLAGS	:=	-Wall -Wno-format -Wno-unused  -static -m32 -I./libc/include -Wno-unused-parameter -ffunction-sections -nostdlib -nostdinc -fno-builtin -ffreestanding -fno-pie
ifdef	DBG
CFLAGS	+=	-g
endif

# Files
OUT	:=	OS.img

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
compile:	image
image:		mbr.bin	kernel.bin
	dd if=/dev/zero of=$(OUT) bs=512 count=2880
	dd if=$(TMP_PATH)/mbr.bin of=$(OUT) seek=0 bs=512 count=1 conv=notrunc
	dd if=$(TMP_PATH)/fat.bin of=$(OUT) seek=1 bs=512 count=1 conv=notrunc
mbr.bin:	ipl.asm	fat.asm
	$(AS) -f bin ipl.asm -o $(TMP_PATH)/mbr.bin
	$(AS) -f bin fat.asm -o $(TMP_PATH)/fat.bin
kernel.bin:	loader.bin
	cat $(TMP_PATH)/loader.bin > $(TMP_PATH)/kernel.sys
loader.bin