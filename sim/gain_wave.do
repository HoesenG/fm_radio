add wave -noupdate -group gain_n_tb
add wave -noupdate -group gain_n_tb -radix hexadecimal /gain_n_tb/*

add wave -noupdate -group gain_n_tb/dut
add wave -noupdate -group gain_n_tb/dut -radix hexadecimal /gain_n_tb/dut/*

add wave -noupdate -group gain_n_tb/dut/gain_inst
add wave -noupdate -group gain_n_tb/dut/gain_inst -radix hexadecimal /gain_n_tb/dut/gain_inst/*
 
add wave -noupdate -group gain_n_tb/dut/input_fifo
add wave -noupdate -group gain_n_tb/dut/input_fifo -radix hexadecimal /gain_n_tb/dut/input_fifo/*

add wave -noupdate -group gain_n_tb/dut/output_fifo
add wave -noupdate -group gain_n_tb/dut/output_fifo -radix hexadecimal /gain_n_tb/dut/output_fifo/*