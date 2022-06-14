AS=arm-none-eabi-as
LD=arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy
ASFLAGS=-mcpu=cortex-m0 -mthumb -g
OPENOCD_DIR="/home/danielbevenius/work/iot/rp/openocd"
OPENOCD="${OPENOCD_DIR}/src/openocd"
PICO_SDK_DIR=/home/danielbevenius/work/iot/rp/pico-sdk
PAD_CHECKSUM=${PICO_SDK_DIR}/src/rp2_common/boot_stage2/pad_checksum

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

clean:
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map *.uf2 *.bin *_padded.s


.PHONY openocd:
openocd:
	${OPENOCD} -s ${OPENOCD_DIR}/tcl -f interface/picoprobe.cfg -f target/rp2040.cfg

