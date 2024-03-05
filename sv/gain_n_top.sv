module gain_n_top(
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] din,
    input  logic        in_wr_en,
    output logic        in_full,
    output logic [31:0] dout,
    input logic         out_rd_en,
    output logic        out_empty
);

logic in_rd_en;
logic [31:0] in_dout;
logic in_empty;

logic [31:0] out_din;

logic out_wr_en;
logic out_full;

assign out_wr_en = ~in_empty;
assign in_rd_en = ~in_empty;

fifo #(
    .FIFO_BUFFER_SIZE(150),
    .FIFO_DATA_WIDTH(32)
) input_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .full(in_full),
    .din(din),
    .rd_clk(clock),
    .rd_en(in_rd_en),
    .dout(in_dout),
    .empty(in_empty)
);

gain_n #(
    .DATA_WIDTH(32),
    .GAIN(1)
) gain_inst(
    .din(in_dout),
    .dout(out_din)
);

fifo #(
    .FIFO_BUFFER_SIZE(150),
    .FIFO_DATA_WIDTH(32)
) output_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en),
    .full(out_full),
    .din(out_din),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(dout),
    .empty(out_empty)
);

endmodule