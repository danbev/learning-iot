OPENOCD_DIR=~/work/iot/rp/openocd

$OPENOCD_DIR/src/openocd -l openocd.log -f interface/picoprobe.cfg -f target/rp2040.cfg -s $OPENOCD_DIR/tcl
