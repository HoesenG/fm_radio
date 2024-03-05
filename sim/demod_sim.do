setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/div.sv"
vlog -work work "../sv/qarctan.sv"
vlog -work work "../sv/demodulate.sv"
vlog -work work "../sv/demod_top.sv"
vlog -work work "../sv/tb/demod_tb.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.demod_tb -wlf demod_tb.wlf

do demod_wave.do

run -all