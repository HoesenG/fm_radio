add wave -noupdate -group demod_tb
add wave -noupdate -group demod_tb -radix hexadecimal /demod_tb/*

add wave -noupdate -group demod_tb/dut
add wave -noupdate -group demod_tb/dut -radix hexadecimal /demod_tb/dut/*

add wave -noupdate -group demod_tb/dut/real_input_fifo
add wave -noupdate -group demod_tb/dut/real_input_fifo -radix hexadecimal /demod_tb/dut/real_input_fifo/*
 
add wave -noupdate -group demod_tb/dut/imag_input_fifo
add wave -noupdate -group demod_tb/dut/imag_input_fifo -radix hexadecimal /demod_tb/dut/imag_input_fifo/*

add wave -noupdate -group demod_tb/dut/demod_inst
add wave -noupdate -group demod_tb/dut/demod_inst -radix hexadecimal /demod_tb/dut/demod_inst/*

add wave -noupdate -group demod_tb/dut/demod_inst/qarctan_inst
add wave -noupdate -group demod_tb/dut/demod_inst/qarctan_inst -radix hexadecimal /demod_tb/dut/demod_inst/qarctan_inst/*

add wave -noupdate -group demod_tb/dut/demod_inst/qarctan_inst/divider_inst
add wave -noupdate -group demod_tb/dut/demod_inst/qarctan_inst/divider_inst -radix hexadecimal /demod_tb/dut/demod_inst/qarctan_inst/divider_inst/*

add wave -noupdate -group demod_tb/dut/output_fifo
add wave -noupdate -group demod_tb/dut/output_fifo -radix hexadecimal /demod_tb/dut/output_fifo/*


