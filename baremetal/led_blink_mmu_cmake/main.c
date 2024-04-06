void delay_short(volatile unsigned int n)
{
	while(n--){}
}

void delay(volatile unsigned int n)
{
	while(n--)
	{
		delay_short(0x7ff);
	}
}

void led_vir_off()
{
	volatile unsigned int *gpio_dr = (unsigned int *)0x6009C000;
	*(gpio_dr) |= 1 << 3;
}

void led_vir_on()
{
	volatile unsigned int *gpio_dr = (unsigned int *)0x6009C000;
	*(gpio_dr) &= ~(1 << 3);
}

int main(void)
{
	while(1)
	{
		led_vir_off();
		delay(5000); // 启动 icache dcache 后，5000 约为 500ms，关闭 cache，500 约为 500ms
		led_vir_on();
		delay(5000);
	}

	return 0;
}
