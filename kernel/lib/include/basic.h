#ifndef _BASIC_H_
#define _BASIC_H_

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef unsigned char bool;
typedef unsigned char code;

void asm_hlt (void);
void asm_cli (void);
void asm_sti (void);
void asm_stihlt (void);
void asm_nop (void);

int in8 (int port);
int in16 (int port);
int in32 (int port);
void out8 (int port, int data);
void out16 (int port, int data);
void out32 (int port, int data);

void load_gdtr (int limit, int addr);
void load_idtr (int limit, int addr);
void load_tr (int tr);
int load_eflags (void);
void store_eflags (int eflags);
int load_cr0 (void);
void store_cr0 (int eflags);

void far_jmp(int eip, int cs);
void debug(void);


#endif //_BASIC_H_