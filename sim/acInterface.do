transcript on

if {[file exists rtl_work]} {
   vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog     -work work {../rtl/acInterface.sv}
vlog     -work work {tb_acInterface.sv}

vsim -t 1ns -L work -voptargs="+acc" tb_acInterface

add wave *

view structure
view signals
run 10 us
wave zoomfull