ENTRY(main)

MEMORY {
	rom : ORIGIN = 0x00000000, LENGTH = 0x00200000
	ram : ORIGIN = 0x00014400, LENGTH = 0x00400000
}

SECTIONS {
	. = 0x00000000;
	.text : {
		*(.text.main);
		*(.text);
	} > rom AT > ram
	.rodata : {
		*(.rodata)
	} > ram
	.data : {
		*(.data)
	} > ram
	.bss : {
		*(.bss)
	} > ram
}