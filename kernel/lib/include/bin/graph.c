#ifndef _GRAPH_C_
#define _GRAPH_C_

void init_palette(void){
	static u8 table_rgb[17*3]={
		0x00, 0x00, 0x00,		// 黑
		0x00, 0x00, 0x84,		// 暗藍
		0x00, 0x84, 0x00,		// 暗綠
		0x00, 0x84, 0x84,		// 暗青
		0x84, 0x00, 0x00,		// 暗紅
		0x84, 0x00, 0x84,		// 暗紫
		0x84, 0x84, 0x00,		// 暗黃
		0x84, 0x84, 0x84,		// 暗灰
		0x00, 0x00, 0xff,		// 亮藍
		0x00, 0xff, 0x00,		// 亮綠
		0x00, 0xff, 0xff,		// 亮青
		0xff, 0x00, 0x00,		// 亮紅
		0xff, 0x00, 0xff,		// 亮紫
		0xff, 0xff, 0x00,		// 亮黃
		0xc6, 0xc6, 0xc6,		// 亮灰
		0xff, 0xff, 0xff,		// 白
		0x11, 0x45, 0x14,		// 透明
	};
	set_palette(0, sizeof(table_rgb)/3, table_rgb);
	return ;
}
static void set_palette(int start, int end, u8 *rgb){
	int eflags = load_eflags();
	asm_cli();
	out8(0x03c8, start);
	for(; start<=end; start++){
		out8(0x03c9, rgb[0]/4);
		out8(0x03c9, rgb[1]/4);
		out8(0x03c9, rgb[2]/4);
		rgb+=3;
	}
	store_eflags(eflags);
	return ;
}
static void put_font_asc(VGAinfo*VGA, short x, short y, u8 c, u8 *font) {
	u8 *p, d;
	if(c==RGB_ALPHA_)
		return;
	for (short i = 0; i < 16; i++) {
		p = VGA->ram + (y + i) * VGA->xSize + x;
		d = font[i];
		if ((d & 0x80))p[0] = c;
		if ((d & 0x40))p[1] = c;
		if ((d & 0x20))p[2] = c;
		if ((d & 0x10))p[3] = c;
		if ((d & 0x08))p[4] = c;
		if ((d & 0x04))p[5] = c;
		if ((d & 0x02))p[6] = c;
		if ((d & 0x01))p[7] = c;
  }
  return;
}
static void draw_text(VGAinfo*VGA, short x, short y, u8 c, char *str) {
	extern u8 font_ascii[4096];
	unsigned short code;
	if(c==RGB_ALPHA_)
		return;
	while(*str){
		code=*(u8*)str;
		if(code<0x0080){
			put_font_asc(VGA,x,y,c,font_ascii+code*16);
			x+=8,str++;
		}else{
			str+=2;
		}
	}
}
static void draw_box(VGAinfo*VGA, short x1, short y1, short x2, short y2, u8 c) {
	short x;
	if(c==RGB_ALPHA_)
		return;
	for(;y1<=y2;y1++){
		for(x=x1;x<=x2;x++){
			VGA->ram[x+y1*VGA->xSize]=c;
		}
	}
	return ;
}
#endif //_GRAPH_C_