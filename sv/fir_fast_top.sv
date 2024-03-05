`timescale 1ns/1ns
// `include "coeffs.svh";

// import macros::*;
// import coeffs::*;

module fir_fast_top(
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] din,
    input  logic        in_wr_en,
    output logic        in_full,

    output logic [31:0] dout,
    input  logic        out_rd_en,
    output logic        out_empty
);

localparam AUDIO_LPR_COEFFS_LOCAL = {
	(32'hfffffffd), (32'hfffffffa), (32'hfffffff4), (32'hffffffed), (32'hffffffe5), (32'hffffffdf), (32'hffffffe2), (32'hfffffff3), 
	(32'h00000015), (32'h0000004e), (32'h0000009b), (32'h000000f9), (32'h0000015d), (32'h000001be), (32'h0000020e), (32'h00000243), 
	(32'h00000243), (32'h0000020e), (32'h000001be), (32'h0000015d), (32'h000000f9), (32'h0000009b), (32'h0000004e), (32'h00000015), 
	(32'hfffffff3), (32'hffffffe2), (32'hffffffdf), (32'hffffffe5), (32'hffffffed), (32'hfffffff4), (32'hfffffffa), (32'hfffffffd)
};
localparam AUDIO_LPR_COEFF_TAPS_LOCAL = 32;
localparam AUDIO_DECIM_LOCAL = 8;

logic in_rd_en;
logic [31:0] in_dout;
logic in_empty;

logic [31:0] fir_out;
logic out_full;
logic out_wr_en;


fifo #(
    .FIFO_DATA_WIDTH(32),
    .FIFO_BUFFER_SIZE(1024)
) input_fifo (
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

fir_fast #(
    .DATA_WIDTH(32),
    .COEFF(AUDIO_LPR_COEFFS_LOCAL),
    .TAPS(AUDIO_LPR_COEFF_TAPS_LOCAL),
    .DECIMATION(AUDIO_DECIM_LOCAL)
) fir_inst (
    .clock(clock),
    .reset(reset),
    .x_in(in_dout),
    .x_rd_en(in_rd_en),
    .x_empty(in_empty),
    .y_out(fir_out),
    .y_out_full(out_full),
    .y_wr_en(out_wr_en)
);

fifo #(
    .FIFO_DATA_WIDTH(32),
    .FIFO_BUFFER_SIZE(1024)
) output_fifo (
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
