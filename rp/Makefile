AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g
OPENOCD_DIR="/home/danielbevenius/work/iot/openocd"
OPENOCD="${OPENOCD_DIR}/src/openocd"

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

clean:
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map


.PHONY openocd:
openocd:
	${OPENOCD} -s ${OPENOCD_DIR}/tcl -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg
