MEMORY
{
    RAM (rwx) : ORIGIN = 0x87800000, LENGTH = 0x18800000
}
/* imx6ull ddr 范围是 0x80000000 开始的，这里使用 sd 卡启动，bootrom 会读取固件头部的信息，固件头部的信息写的是 87800000，然后bootrom 会将固件拷贝到 ddr 的 87800000 */

SECTIONS
{
    .text :
    {
        *(__reset)
        *(.text)
    } > RAM

    .rodata   : { *(.rodata) *(.rodata.*) } > RAM

    . = ALIGN(4);
    .data :
    {
        *(.data)
        *(.data.*)
    } > RAM
    . = ALIGN(4);

    __bss_start = .;
    .bss (NOLOAD):
    {
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
    } > RAM
    __bss_end = .;
}