setenv LMC_TIMUNIT -9
vlib work
vmap work work

# tb arch
# vlog -work work "../sv/macros.svh"
# vlog -work work "../sv/coeffs.svh"
vlog -work work "../sv/tb/macros_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.macros_tb -wlf macros_tb.wlf

run -all