`timescale 1ns/1ns

module div_tb;

localparam CLOCK_PERIOD = 10;

logic clk = 1'b1;
logic reset = '0;
logic valid_in = '0;
logic valid_out;

logic [31:0] dividend, quotient;
logic [31:0] divisor, remainder;
logic overflow;

div #(
    .DIVIDEND_WIDTH(32),
    .DIVISOR_WIDTH(32)
) dut (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_in),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .remainder(remainder),
    .valid_out(valid_out),
    .overflow(overflow)
);

always begin
    clk = 1'b1;
    #(CLOCK_PERIOD/2);
    clk = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clk);
    reset = 1'b1;
    @(posedge clk);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;
    @(negedge reset);
    @(posedge clk);
    start_time = $time;

    // start by inputting invalid data
    dividend = {32{'0}};
    divisor = {32{'0}};
    
    // change to valid data
    @(posedge clk);
    valid_in = 1'b1;
    dividend = 32'd256;
    divisor =  32'd4;

    wait(valid_out);
    valid_in = 1'b0;
    #(CLOCK_PERIOD*4);
    $display("valid out receieved");
    $display(quotient);
    end_time = $time;
    $display("sim time: %0d", (end_time - start_time)/CLOCK_PERIOD);
    $finish;
end

endmodule
