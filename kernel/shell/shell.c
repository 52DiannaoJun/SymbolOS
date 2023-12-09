#include <basic.h>
#include <graph.h>

void init_Kernel (void);
VGAinfo VGA;
int x,y,i,j;

int main (void){
	init_Kernel();
	init_palette();
	draw_box(&VGA,0,0,VGA.xSize,VGA.ySize,0x03);
	draw_text(&VGA,1,1,RGB_000000,"Symbol OS 0.3 Kernel");
	draw_text(&VGA,0,0,RGB_FFFFFF,"Symbol OS 0.3 Kernel");
	draw_text(&VGA,17,17,RGB_000000,"2023-12-09 Sat. Update");
	draw_text(&VGA,16,16,RGB_FFFFFF,"2023-12-09 Sat. Update");
	for(;;)asm_hlt();
	return 0;
}
void init_Kernel (void){
	VGA.mode = ((u16*)0xf000)[0];
	VGA.xSize = ((short*)0xf002)[0];
	VGA.ySize = ((short*)0xf004)[0];
	VGA.ram = (u8*)((int*)0xf006)[0];
	VGA.byte = ((u8*)0xf00b)[0];
	return ;
}