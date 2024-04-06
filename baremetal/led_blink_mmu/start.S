/*
    1. 初始化 mmu，建立虚拟内存转换表
    2. 初始化个个模式下的栈，建立 C 运行时环境
    3. 初始化串口，用于调试
    4. 跳转到 C 环境，用虚拟地址点亮 led 灯
*/

.equ Mode_USR,        0x10
.equ Mode_FIQ,        0x11
.equ Mode_IRQ,        0x12
.equ Mode_SVC,        0x13
.equ Mode_ABT,        0x17
.equ Mode_UND,        0x1B
.equ Mode_SYS,        0x1F

.equ UND_Stack_Size,     0x00000400
.equ SVC_Stack_Size,     0x00000400
.equ ABT_Stack_Size,     0x00000400
.equ RT_FIQ_STACK_PGSZ,  0x00000000
.equ RT_IRQ_STACK_PGSZ,  0x00000800
.equ USR_Stack_Size,     0x00000400

.equ I_Bit,           0x80            @ when I bit is set, IRQ is disabled
.equ F_Bit,           0x40            @ when F bit is set, FIQ is disabled

#define ISR_Stack_Size  (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                 RT_FIQ_STACK_PGSZ + RT_IRQ_STACK_PGSZ)

.section .data.share.isr
/* stack */
.globl stack_start
.globl stack_top

stack_start:
.rept ISR_Stack_Size
.byte 0
.endr
stack_top:

.text
/* reset entry */
.globl __reset

#设置 cpsr 寄存器， cps     #Mode_SVC
__reset:
    cps     #Mode_SVC
    mrc p15, 0, r1, c1, c0, 0
    bic r1, #(1<<1)
    mcr p15, 0, r1, c1, c0, 0
    bl step_stack
    bl led_phy_init

    /* clear .bss */
    mov r0, #0
    ldr r1,=__bss_start
    ldr r2,=__bss_end

bss_loop:
    cmp r1,r2
    strlo r0,[r1],#4
    blo bss_loop
    bl mmu_table_init
    b main

led_phy_init:
    	/* 例程代码 */
	/* 1、使能所有时钟 */
	ldr r0, =0X020C4068 	/* CCGR0 */
	ldr r1, =0XFFFFFFFF  
	str r1, [r0]		
	
	ldr r0, =0X020C406C  	/* CCGR1 */
	str r1, [r0]

	ldr r0, =0X020C4070  	/* CCGR2 */
	str r1, [r0]
	
	ldr r0, =0X020C4074  	/* CCGR3 */
	str r1, [r0]
	
	ldr r0, =0X020C4078  	/* CCGR4 */
	str r1, [r0]
	
	ldr r0, =0X020C407C  	/* CCGR5 */
	str r1, [r0]
	
	ldr r0, =0X020C4080  	/* CCGR6 */
	str r1, [r0]
	

	/* 2、设置GPIO1_IO03复用为GPIO1_IO03 */
	ldr r0, =0X020E0068	/* 将寄存器SW_MUX_GPIO1_IO03_BASE加载到r0中 */
	ldr r1, =0X5		/* 设置寄存器SW_MUX_GPIO1_IO03_BASE的MUX_MODE为5 */
	str r1,[r0]

	/* 3、配置GPIO1_IO03的IO属性	
	 *bit 16:0 HYS关闭
	 *bit [15:14]: 00 默认下拉
     *bit [13]: 0 kepper功能
     *bit [12]: 1 pull/keeper使能
     *bit [11]: 0 关闭开路输出
     *bit [7:6]: 10 速度100Mhz
     *bit [5:3]: 110 R0/6驱动能力
     *bit [0]: 0 低转换率
     */
    ldr r0, =0X020E02F4	/*寄存器SW_PAD_GPIO1_IO03_BASE */
    ldr r1, =0X10B0
    str r1,[r0]

	/* 4、设置GPIO1_IO03为输出 */
    ldr r0, =0X0209C004	/*寄存器GPIO1_GDIR */
    ldr r1, =0X0000008		
    str r1,[r0]
    bx lr

.globl led_phy_on
led_phy_on:
   ldr r0, =0X0209C000	/*寄存器GPIO1_DR */
   ldr r1, = 0
   str r1,[r0]
   bx lr

.globl led_phy_off
led_phy_off:
   ldr r0, =0X0209C000	/*寄存器GPIO1_DR */
   ldr r1, = 1<<3
   str r1,[r0]
   bx lr

step_stack:
    ldr r0, =stack_top
    mov sp, r0

    msr cpsr_c, #Mode_UND|I_Bit|F_Bit
    mov sp, r0
    sub r0, r0, #UND_Stack_Size

    msr cpsr_c, #Mode_FIQ|I_Bit|F_Bit
    mov sp, r0
    sub r0, r0, #RT_FIQ_STACK_PGSZ
    
    msr cpsr_c, #Mode_IRQ|I_Bit|F_Bit
    mov sp, r0
    sub r0, r0, #RT_IRQ_STACK_PGSZ

    /* come back to SVC mode */
    msr cpsr_c, #Mode_SVC|I_Bit|F_Bit
    bx lr