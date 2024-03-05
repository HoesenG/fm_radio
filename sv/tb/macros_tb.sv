`include "../coeffs.svh"
`timescale 1ns/1ns
module macros_tb;

import macros::*;

logic clk;
logic [31:0] pi, max_dev, w_pp;

initial begin
    $display("%08x\n", QUANTIZE_F(2.512) - 32'h00000001);
    $display("%08x\n", MAX_DEV);
    $display("%08x\n", TAU);
    $display("%08x\n", W_PP);
    clk = '0;
    pi = PI;
    max_dev = MAX_DEV;
    w_pp = W_PP;
    #10;
    clk = '1;
    #10;
end

endmodule