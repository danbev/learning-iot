OPENOCD_DIR=/home/danielbevenius/work/iot/openocd-esp32
OPENOCD=${OPENOCD_DIR}/src/openocd
OPENOCD_SCRIPTS=${OPENOCD_DIR}/tcl

.PHONY openocd:
openocd:
	${OPENOCD} -d3 -s ${OPENOCD_DIR}/tcl -f board/esp32c3-builtin.cfg
