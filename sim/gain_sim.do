setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../sv/tb/gain_n_tb.sv"
vlog -work work "../sv/gain_n_top.sv"
vlog -work work "../sv/gain_n.sv"
vlog -work work "../sv/fifo.sv"


vsim -classdebug -voptargs=+acc +notimingchecks -L work work.gain_n_tb -wlf gain_n.wlf

do gain_wave.do

run -all