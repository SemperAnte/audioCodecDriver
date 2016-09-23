transcript on

if {[file exists rtl_work]} {
   vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

file copy -force {../rtl/cordicCosSin/cordicLUT.vh} {cordicLUT.vh}
file copy -force {../rtl/cordicCosSin/cordicPkg.vh} {cordicPkg.vh}
vlog     -work work {../rtl/cordicCosSin/cordicCosSinParallel.sv}
vlog     -work work {../rtl/cordicCosSin/cordicCosSinSerial.sv}
vlog     -work work {../rtl/cordicCosSin/cordicCosSin.sv}
vlog     -work work {../rtl/i2cMaster/i2cTick.sv}
vlog     -work work {../rtl/i2cMaster/i2cLine.sv}
vlog     -work work {../rtl/i2cMaster/i2cAvalon.sv}
vlog     -work work {../rtl/i2cMaster/i2cControl.sv}
vlog     -work work {../rtl/i2cMaster/i2cMaster.sv}
vlog     -work work {../rtl/acGenerator.sv}
vlog     -work work {../rtl/acAvalon.sv}
vlog     -work work {../rtl/acInterface.sv}
vlog     -work work {../rtl/acCore.sv}
vlog     -work work {../rtl/acDriver.sv}
vlog     -work work {exInterface.sv}
vlog     -work work {tb_acDriver.sv}

vsim -t 1ns -L work -voptargs="+acc" tb_acDriver

add wave *

view structure
view signals
run 10 us
wave zoomfull