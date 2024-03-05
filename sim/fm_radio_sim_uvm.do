
setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# fm radio architecture
# vlog -work work "../sv/tb/fm_radio_top_tb.sv"
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


# uvm library
vlog -work work +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm.sv
vlog -work work +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm_macros.svh
vlog -work work +incdir+$env(UVM_HOME)/src $env(MTI_HOME)/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv

# uvm package
vlog -work work +incdir+$env(UVM_HOME)/src "../uvm/my_uvm_pkg.sv"
vlog -work work +incdir+$env(UVM_HOME)/src "../uvm/my_uvm_tb.sv"

# start uvm simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.my_uvm_tb -wlf my_uvm_tb.wlf -sv_lib lib/uvm_dpi -dpicpppath /usr/bin/gcc +incdir+$env(MTI_HOME)/verilog_src/questa_uvm_pkg-1.2/src/

do fm_radio_wave_uvm.do

run -all
#quit;