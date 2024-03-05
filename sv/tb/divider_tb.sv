module divider_tb;

localparam DIVIDEND_WIDTH = 32;
localparam DIVISOR_WIDTH = 16;
localparam CLOCK_PERIOD = 10;

logic clk, reset, start;
logic [DIVIDEND_WIDTH-1:0] dividend;
logic [DIVISOR_WIDTH-1:0] divisor;
logic [DIVIDEND_WIDTH-1:0] quotient;
logic [DIVISOR_WIDTH-1:0] remainder;
logic overflow;

divider divider_inst (
    .clk(clk),
    .reset(reset),
    .start(start),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .remainder(remainder),
    .overflow(overflow)
);

always begin
    clk = 1'b1;
    #(CLOCK_PERIOD/2);
    clk = 1'b0;
    #(CLOCK_PERIOD/2);
end

endmodule