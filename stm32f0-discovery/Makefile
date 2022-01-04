AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

VPATH = $(MAKEFILE_DIR)led $(MAKEFILE_DIR)timer $(MAKEFILE_DIR)uart

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

clean: 
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
