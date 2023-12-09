#ifndef _GRAPH_H_
#define _GRAPH_H_
#include <basic.h>

#define RGB_000000 0x00
#define RGB_000084 0x01
#define RGB_008400 0x02
#define RGB_008484 0x03
#define RGB_840000 0x04
#define RGB_840084 0x05
#define RGB_848400 0x06
#define RGB_848484 0x07
#define RGB_0000FF 0x08
#define RGB_00FF00 0x09
#define RGB_00FFFF 0x0A
#define RGB_FF0000 0x0B
#define RGB_FF00FF 0x0C
#define RGB_FFFF00 0x0D
#define RGB_C6C6C6 0x0E
#define RGB_FFFFFF 0x0F
#define RGB_ALPHA_ 0x10

typedef struct{
	u8 *ram;
	short xSize, ySize;
	u16 mode;
	u8 byte;
}VGAinfo;

void init_palette(void);
static void set_palette(int start, int end, u8 *rgb);
static void put_font_asc(VGAinfo*, short x, short y, u8 c, u8 *font);
static void draw_text(VGAinfo*, short x, short y, u8 c, char *str);
static void draw_box(VGAinfo*, short x1, short y1, short x2, short y2, u8 c);

#endif //_GRAPH_H_
#include <bin/graph.c>