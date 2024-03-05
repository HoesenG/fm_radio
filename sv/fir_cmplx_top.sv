module fir_cmplx_top(
    input  logic        clock,
    input  logic        reset,

    input  logic [31:0] i_in,
    input  logic [31:0] q_in,

    input  logic        in_wr_en,

    output logic        in_full,

    output logic [31:0] y_out_real,
    output logic [31:0] y_out_imag,

    input  logic        out_rd_en,

    output logic        out_empty
);

localparam CHANNEL_COEFF_TAPS = 20;
localparam [0:19][31:0] CHANNEL_COEFFS_REAL =
'{
	(32'h00000001), (32'h00000008), (32'hfffffff3), (32'h00000009), (32'h0000000b), (32'hffffffd3), (32'h00000045), (32'hffffffd3), 
	(32'hffffffb1), (32'h00000257), (32'h00000257), (32'hffffffb1), (32'hffffffd3), (32'h00000045), (32'hffffffd3), (32'h0000000b), 
	(32'h00000009), (32'hfffffff3), (32'h00000008), (32'h00000001)
};

localparam [0:19][31:0] CHANNEL_COEFFS_IMAG =
'{
	(32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), 
	(32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), 
	(32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000)
};

logic i_full, q_full;
logic i_rd_en, q_rd_en;
logic [31:0] i_dout;
logic [31:0] q_dout;
logic i_empty, q_empty;
logic [31:0] y_dout_real;
logic [31:0] y_dout_imag;
logic y_real_wr_en;
logic y_imag_wr_en;
logic y_real_full;
logic y_imag_full;
logic y_real_empty;
logic y_imag_empty;

assign in_full = i_full || q_full;
assign out_empty = y_real_empty || y_imag_empty;

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(32)
) i_in_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .full(i_full),
    .din(i_in),
    .rd_clk(clock),
    .rd_en(i_rd_en),
    .dout(i_dout),
    .empty(i_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(32)
) q_in_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .full(q_full),
    .din(q_in),
    .rd_clk(clock),
    .rd_en(q_rd_en),
    .dout(q_dout),
    .empty(q_empty)
);

fir_cmplx#(
    .H_REAL(CHANNEL_COEFFS_REAL),
    .H_IMAG(CHANNEL_COEFFS_IMAG),
    .TAPS(CHANNEL_COEFF_TAPS),
    .DECIMATION(1)
) fir_cmplx_inst (
    .clock(clock),
    .reset(reset),
    .i_in(i_dout),
    .q_in(q_dout),
    .i_rd_en(i_rd_en),
    .q_rd_en(q_rd_en),
    .i_empty(i_empty),
    .q_empty(q_empty),
    .y_out_real(y_dout_real),
    .y_out_imag(y_dout_imag),
    .y_real_wr_en(y_real_wr_en),
    .y_imag_wr_en(y_imag_wr_en),
    .y_real_full(y_real_full),
    .y_imag_full(y_imag_full)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(32)
) y_out_real_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(y_real_wr_en),
    .full(y_real_full),
    .din(y_dout_real),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .empty(y_real_empty),
    .dout(y_out_real)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(32)
) y_out_imag_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(y_imag_wr_en),
    .full(y_imag_full),
    .din(y_dout_imag),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .empty(y_imag_empty),
    .dout(y_out_imag)
);

endmodule
