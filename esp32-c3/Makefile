OPENOCD_DIR=/home/danielbevenius/work/iot/openocd-esp32
OPENOCD=${OPENOCD_DIR}/src/openocd

.PHONY openocd:
openocd:
	${OPENOCD} -s ${OPENOCD_DIR}/tcl -f board/esp32c3-builtin.cfg
