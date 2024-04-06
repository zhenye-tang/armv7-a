objs := start.o cp15.o main.o mmu.o

mmu_led:$(objs)
	arm-none-eabi-ld -Tlink.lds -Map=$@.map  -o $@.elf $^
	arm-none-eabi-objcopy -O binary -S $@.elf $@
	arm-none-eabi-objdump -D -m arm $@.elf > $@.dis
	
%.o:%.s
	arm-none-eabi-gcc -Wall -march=armv7-a -nostdlib -c -O0 -o $@ $<

%.o:%.S
	arm-none-eabi-gcc -Wall -march=armv7-a -nostdlib -c -O0 -o $@ $<
	
%.o:%.c
	arm-none-eabi-gcc -Wall -march=armv7-a -nostdlib -c -O0 -o $@ $<
	
clean:
	rm -rf *.o *.dis *.elf mmu_led mmu_led.map load.imx
	
	
