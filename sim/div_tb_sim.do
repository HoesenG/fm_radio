setenv LMC_TIMUNIT -9
vlib work
vmap work work

# tb arch
vlog -work work "../sv/div.sv"
vlog -work work "../sv/tb/div_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.div_tb -wlf div_tb.wlf

do div_tb_wave.do

run -all