
#define DESC_SEC       (0x2)
#define MEMWBWA        ((1<<12)|(3<<2))     /* write back, write allocate */
#define MEMWB          (3<<2)  /* write back, no write allocate */
#define MEMWT          (2<<2)  /* write through, no write allocate */
#define SHAREDEVICE    (1<<2)  /* shared device */
#define STRONGORDER    (0<<2)  /* strong ordered */
#define XN             (1<<4)  /* eXecute Never */
#define AP_RW          (3<<10) /* supervisor=RW, user=RW */
#define AP_RO          (2<<10) /* supervisor=RW, user=RO */
#define SHARED         (1<<16) /* shareable */

#define DOMAIN_FAULT   (0x0)
#define DOMAIN_CHK     (0x1)
#define DOMAIN_NOTCHK  (0x3)
#define DOMAIN0        (0x0<<5)
#define DOMAIN1        (0x1<<5)

#define DOMAIN0_ATTR   (DOMAIN_CHK<<0)
#define DOMAIN1_ATTR   (DOMAIN_FAULT<<2)

/* device mapping type */
#define DEVICE_MEM     (SHARED|AP_RW|DOMAIN0|SHAREDEVICE|DESC_SEC|XN)
/* normal memory mapping type */
#define NORMAL_MEM     (SHARED|AP_RW|DOMAIN0|MEMWBWA|DESC_SEC)

struct mem_desc
{
    unsigned int vaddr_start;
    unsigned int vaddr_end;
    unsigned int paddr_start;
    unsigned int attr;
};

// 需要创建一个 ttb
// 使用一级页表，每个 entry 1MB
// 必须 16KB 对齐，armv7-a 编程手册有说明
volatile unsigned long MMU_TTB[4096] __attribute__((aligned(16*1024)));

// 0x209C000
// 0x2000000
// 0x6009C000
// 将 0x60000000 映射到 0x2000000，那么 0x6009C000 是物理内存 0x209C000，也就是 gpio 的 dr 寄存器地址
struct mem_desc memory_map_table[] = {
    {0x60000000, 0x61000000, 0x2000000, DEVICE_MEM},
    {0x80000000, 0xfff00000, 0x80000000, NORMAL_MEM},
};

void mmu_setmtt(unsigned int vaddrStart,
                      unsigned int vaddrEnd,
                      unsigned int paddrStart,
                      unsigned int attr)
{
    volatile unsigned int *pTT;
    volatile int i, nSec;
    pTT  = (unsigned int *)MMU_TTB + (vaddrStart >> 20);
    nSec = (vaddrEnd >> 20) - (vaddrStart >> 20);
    for(i = 0; i <= nSec; i++)
    {
        /* 初始化虚拟地址转换表的每个 entry, 按照 mmu 的手册来初始化的，每个 bit 都有说法 */
        *pTT = attr | (((paddrStart >> 20) + i) << 20);
        pTT++;
    }
}

static unsigned long rt_hw_set_domain_register(unsigned long domain_val)
{
    unsigned long old_domain;

    asm volatile ("mrc p15, 0, %0, c3, c0\n" : "=r" (old_domain));
    asm volatile ("mcr p15, 0, %0, c3, c0\n" : :"r" (domain_val) : "memory");

    return old_domain;
}

void rt_cpu_mmu_disable(void);
void rt_cpu_mmu_enable(void);
void rt_cpu_tlb_set(volatile unsigned long*);
void rt_hw_cpu_icache_enable(void);
void rt_hw_cpu_icache_disable(void);
void rt_cpu_dcache_clean_flush(void);
void rt_cpu_icache_flush(void);
void rt_hw_cpu_dcache_enable(void);
void rt_hw_cpu_dcache_disable(void);

unsigned int rt_cpu_dcache_line_size(void)
{
    unsigned int ctr;
    asm volatile ("mrc p15, 0, %0, c0, c0, 1" : "=r"(ctr));
    return 4 << ((ctr >> 16) & 0xF);
}

void rt_hw_cpu_dcache_clean(void *addr, int size)
{
    unsigned int line_size = rt_cpu_dcache_line_size();
    unsigned int start_addr = (unsigned int)addr;
    unsigned int end_addr = (unsigned int) addr + size + line_size - 1;

    asm volatile ("dmb":::"memory");
    start_addr &= ~(line_size-1);
    end_addr &= ~(line_size-1);
    while (start_addr < end_addr)
    {
        asm volatile ("mcr p15, 0, %0, c7, c10, 1" :: "r"(start_addr)); /* dccmvac */
        start_addr += line_size;
    }
    asm volatile ("dsb":::"memory");
}

void mmu_table_init()
{
    for(int i = 0; i < sizeof(memory_map_table) / sizeof(*memory_map_table); i++)
    {
        mmu_setmtt(memory_map_table[i].vaddr_start,
                   memory_map_table[i].vaddr_end,
                   memory_map_table[i].paddr_start,
                   memory_map_table[i].attr);
    }
    rt_hw_cpu_dcache_clean((void*)MMU_TTB, sizeof MMU_TTB);
    /* dcache clean flush */
    rt_cpu_dcache_clean_flush();
    rt_cpu_icache_flush();
    rt_hw_cpu_dcache_disable();
    rt_hw_cpu_icache_disable();
    rt_cpu_mmu_disable();

    rt_hw_set_domain_register(0x55555555);

    rt_cpu_tlb_set(MMU_TTB);
    rt_cpu_mmu_enable();
    rt_hw_cpu_icache_enable();
    rt_hw_cpu_dcache_enable();
}