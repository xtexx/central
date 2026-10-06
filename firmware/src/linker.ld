OUTPUT_ARCH("loongarch")
OUTPUT_FORMAT("elf64-loongarch")

ENTRY(start)

MEMORY {
	ram (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

PHDRS {
	text	PT_LOAD;
	data	PT_LOAD;
	bss	    PT_LOAD;
}

SECTIONS {
	.text : {
		PROVIDE( __text_start = . );
		*(.text.start)
		*(.text.init)
        *(.text .text.*)
		PROVIDE( __text_end = . );

		. = ALIGN(4096);
		PROVIDE( __data_start = . );
		*(.sdata .sdata*)
        *(.rodata .rodata.*)
        *(.data .data.*)
		. = ALIGN(4096);
		PROVIDE( __data_end = . );
	} > ram AT > ram : text

	.bss : {
		. = ALIGN(4096);
		PROVIDE( __bss_start = . );
		*(.sbss .sbss.*)
        *(.bss .bss.*)
		. = ALIGN(4096);
		PROVIDE( __bss_end = . );
	} > ram AT > ram : bss

  . = ALIGN(4096);
}
