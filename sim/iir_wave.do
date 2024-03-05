add wave -noupdate -group iir_tb
add wave -noupdate -group iir_tb -radix hexadecimal /iir_tb/*

add wave -noupdate -group iir_tb/dut
add wave -noupdate -group iir_tb/dut -radix hexadecimal /iir_tb/dut/*

add wave -noupdate -group iir_tb/dut/iir_inst
add wave -noupdate -group iir_tb/dut/iir_inst -radix hexadecimal /iir_tb/dut/iir_inst/*
 
add wave -noupdate -group iir_tb/dut/fifo_in
add wave -noupdate -group iir_tb/dut/fifo_in -radix hexadecimal /iir_tb/dut/fifo_in/*

add wave -noupdate -group iir_tb/dut/fifo_out
add wave -noupdate -group iir_tb/dut/fifo_out -radix hexadecimal /iir_tb/dut/fifo_out/*