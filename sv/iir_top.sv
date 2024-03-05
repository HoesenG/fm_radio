module iir_top #(

) (
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] din,
    input  logic        in_wr_en,
    output logic        in_full,

    output logic [31:0] dout,
    input  logic        out_rd_en,
    output logic        out_empty

);

logic in_rd_en;
logic [31:0] in_dout;
logic in_empty;

logic [31:0] fir_out;
logic out_full;
logic out_wr_en;


fifo #(
    .FIFO_DATA_WIDTH(32),
    .FIFO_BUFFER_SIZE(1024)
) fifo_in (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(din),
    .full(in_full),
    .rd_clk(clock),
    .rd_en(in_rd_en),
    .dout(in_dout),
    .empty(in_empty)
);

iir #(
    .DATA_WIDTH(32)
) iir_inst (
    .clock(clock),
    .reset(reset),
    .din(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .dout(fir_out),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
);

fifo #(
    .FIFO_DATA_WIDTH(32),
    .FIFO_BUFFER_SIZE(1024)
) fifo_out (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en),
    .din(fir_out),
    .full(out_full),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(dout),
    .empty(out_empty)
);

endmodule