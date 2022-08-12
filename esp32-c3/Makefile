OPENOCD_DIR=/home/danielbevenius/work/iot/openocd-esp32
OPENOCD=${OPENOCD_DIR}/src/openocd
OPENOCD_SCRIPTS=${OPENOCD_DIR}/tcl
AS=xtensa-esp32-elf-as
ASFLAGS=-g
LD=xtensa-esp32-elf-ld

FIRST_WORD=0xaedb041d

.PHONY openocd:
openocd:
	${OPENOCD} -s ${OPENOCD_DIR}/tcl -f board/esp32c3-builtin.cfg

hello.elf: hello.o linker-script.ld
	$(LD) -T linker-script.ld --cref -Map $@.map -o $@ hello.o
	objcopy -O ihex $@ $@.hex
# Add two magic words for Direct boot
	echo -n "0xaedb041d0xaedb041d" > tmp_file
	cat $@.hex >> tmp_file
	cp tmp_file $@.hex

hello.o: hello.s
	$(AS) $(ASFLAGS) hello.s -asghl=$*.lst -o hello.o

.PHONY: clean
clean:
	${RM} *.{o,elf,map,hex}

