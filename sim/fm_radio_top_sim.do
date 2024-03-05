setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../sv/tb/fm_radio_top_tb.sv"
vlog -work work "../sv/demodulate.sv"
vlog -work work "../sv/div.sv"
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/fir_cmplx.sv"
vlog -work work "../sv/fir.sv"
vlog -work work "../sv/fm_radio_top.sv"
vlog -work work "../sv/gain_n.sv"
vlog -work work "../sv/iir_fast.sv" 
vlog -work work "../sv/multiply_n.sv"
vlog -work work "../sv/qarctan.sv"


vsim -classdebug -voptargs=+acc +notimingchecks -L work work.fm_radio_top_tb -wlf fm_radio_top_tb.wlf

do fm_radio_top_wave.do

run -all