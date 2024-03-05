// `include "coeffs.svh"
module fm_radio_top (
    input   logic           clk,
    input   logic           reset,
    input   logic           in_wr_en,
    input   logic           out_rd_en,
    output  logic           q_in_full,
    output  logic           i_in_full,
    output  logic           left_out_empty,
    output  logic           right_out_empty,
    input   logic [31:0]    q_din,
    input   logic [31:0]    i_din,
    output  logic [31:0]    left_dout,
    output  logic [31:0]    right_dout
);

//import macros::*;
// import coeffs::*;

localparam int ADC_RATE = 64000000;
localparam int USRP_DECIM = 250;
localparam int QUAD_RATE = int'(ADC_RATE / USRP_DECIM);
localparam int AUDIO_DECIM = 8;
localparam int AUDIO_RATE = int'(QUAD_RATE / AUDIO_DECIM);
// int VOLUME_LEVEL = QUANTIZE_F(1.0);
localparam int SAMPLES = 65536*4;
localparam int AUDIO_SAMPLES = int'(SAMPLES / AUDIO_DECIM);
localparam int MAX_TAPS = 32;

localparam int IIR_COEFF_TAPS = 2;
// logic [0:1][31:0] IIR_Y_COEFFS = '{QUANTIZE_F(0.0), QUANTIZE_F((W_PP - ONE_FLOAT) / (W_PP + ONE_FLOAT))};
// logic [0:1][31:0] IIR_X_COEFFS = '{QUANTIZE_F(W_PP / (ONE_FLOAT + W_PP)), QUANTIZE_F(W_PP / (ONE_FLOAT + W_PP))};




localparam int CHANNEL_COEFF_TAPS = 20;
localparam logic [0:19][31:0] CHANNEL_COEFFS_REAL =
'{
	(32'h00000001), (32'h00000008), (32'hfffffff3), (32'h00000009), (32'h0000000b), (32'hffffffd3), (32'h00000045), (32'hffffffd3), 
	(32'hffffffb1), (32'h00000257), (32'h00000257), (32'hffffffb1), (32'hffffffd3), (32'h00000045), (32'hffffffd3), (32'h0000000b), 
	(32'h00000009), (32'hfffffff3), (32'h00000008), (32'h00000001)
};

localparam logic [0:19][31:0] CHANNEL_COEFFS_IMAG =
'{
	(32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), 
	(32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000), 
	(32'h00000000), (32'h00000000), (32'h00000000), (32'h00000000)
};

// L+R low-pass filter coefficients @ 15kHz
localparam int AUDIO_LPR_COEFF_TAPS = 32;
localparam logic [0:31][31:0] AUDIO_LPR_COEFFS =
'{
	(32'hfffffffd), (32'hfffffffa), (32'hfffffff4), (32'hffffffed), (32'hffffffe5), (32'hffffffdf), (32'hffffffe2), (32'hfffffff3), 
	(32'h00000015), (32'h0000004e), (32'h0000009b), (32'h000000f9), (32'h0000015d), (32'h000001be), (32'h0000020e), (32'h00000243), 
	(32'h00000243), (32'h0000020e), (32'h000001be), (32'h0000015d), (32'h000000f9), (32'h0000009b), (32'h0000004e), (32'h00000015), 
	(32'hfffffff3), (32'hffffffe2), (32'hffffffdf), (32'hffffffe5), (32'hffffffed), (32'hfffffff4), (32'hfffffffa), (32'hfffffffd)
};

// L-R low-pass filter coefficients @ 15kHz), gain = 60
localparam int AUDIO_LMR_COEFF_TAPS = 32;
localparam logic [0:31][31:0] AUDIO_LMR_COEFFS =
'{
	(32'hfffffffd), (32'hfffffffa), (32'hfffffff4), (32'hffffffed), (32'hffffffe5), (32'hffffffdf), (32'hffffffe2), (32'hfffffff3), 
	(32'h00000015), (32'h0000004e), (32'h0000009b), (32'h000000f9), (32'h0000015d), (32'h000001be), (32'h0000020e), (32'h00000243), 
	(32'h00000243), (32'h0000020e), (32'h000001be), (32'h0000015d), (32'h000000f9), (32'h0000009b), (32'h0000004e), (32'h00000015), 
    (32'hfffffff3), (32'hffffffe2), (32'hffffffdf), (32'hffffffe5), (32'hffffffed), (32'hfffffff4), (32'hfffffffa), (32'hfffffffd)
};

// Pilot tone band-pass filter @ 19kHz
localparam int BP_PILOT_COEFF_TAPS = 32;
localparam logic [0:31][31:0] BP_PILOT_COEFFS =
'{
	(32'h0000000e), (32'h0000001f), (32'h00000034), (32'h00000048), (32'h0000004e), (32'h00000036), (32'hfffffff8), (32'hffffff98), 
	(32'hffffff2d), (32'hfffffeda), (32'hfffffec3), (32'hfffffefe), (32'hffffff8a), (32'h0000004a), (32'h0000010f), (32'h000001a1), 
	(32'h000001a1), (32'h0000010f), (32'h0000004a), (32'hffffff8a), (32'hfffffefe), (32'hfffffec3), (32'hfffffeda), (32'hffffff2d), 
	(32'hffffff98), (32'hfffffff8), (32'h00000036), (32'h0000004e), (32'h00000048), (32'h00000034), (32'h0000001f), (32'h0000000e)
};

// L-R band-pass filter @ 23kHz to 53kHz
localparam int BP_LMR_COEFF_TAPS = 32;
localparam logic [0:31][31:0] BP_LMR_COEFFS =
'{
	(32'h00000000), (32'h00000000), (32'hfffffffc), (32'hfffffff9), (32'hfffffffe), (32'h00000008), (32'h0000000c), (32'h00000002), 
	(32'h00000003), (32'h0000001e), (32'h00000030), (32'hfffffffc), (32'hffffff8c), (32'hffffff58), (32'hffffffc3), (32'h0000008a), 
	(32'h0000008a), (32'hffffffc3), (32'hffffff58), (32'hffffff8c), (32'hfffffffc), (32'h00000030), (32'h0000001e), (32'h00000003), 
	(32'h00000002), (32'h0000000c), (32'h00000008), (32'hfffffffe), (32'hfffffff9), (32'hfffffffc), (32'h00000000), (32'h00000000)
};

// High pass filter @ 0Hz removes noise after pilot tone is squared
localparam int HP_COEFF_TAPS = 32;
localparam logic [0:31][31:0] HP_COEFFS =
'{
	(32'hffffffff), (32'h00000000), (32'h00000000), (32'h00000002), (32'h00000004), (32'h00000008), (32'h0000000b), (32'h0000000c), 
	(32'h00000008), (32'hffffffff), (32'hffffffee), (32'hffffffd7), (32'hffffffbb), (32'hffffff9f), (32'hffffff87), (32'hffffff76), 
	(32'hffffff76), (32'hffffff87), (32'hffffff9f), (32'hffffffbb), (32'hffffffd7), (32'hffffffee), (32'hffffffff), (32'h00000008), 
	(32'h0000000c), (32'h0000000b), (32'h00000008), (32'h00000004), (32'h00000002), (32'h00000000), (32'h00000000), (32'hffffffff)
};

localparam FIFO_DATA_WIDTH = 32;
localparam DEEMPH_DATA_WIDTH = 32;

//// BEGIN FIFO SIGNALS ////

//// WRITE ENABLES ////
logic wr_en_q_in_fifo;
logic wr_en_i_in_fifo;
logic wr_en_q_fir_complex_out_fifo;
logic wr_en_i_fir_complex_out_fifo;
logic wr_en_demod_out_fifo;
logic wr_en_fir_demod_1_in_fifo;
logic wr_en_fir_demod_2_in_fifo;
logic wr_en_fir_demod_3_in_fifo;
logic wr_en_fir_demod_1_out_fifo;
logic wr_en_fir_demod_2_out_fifo;
logic wr_en_mult_A_out_fifo;
logic wr_en_fir_mutiA_out_fifo;
logic wr_en_mult_B_out_fifo;
logic wr_en_fir_mutiB_out_fifo;
logic wr_en_fir_demod_3_out_fifo;
logic wr_en_add_out_fifo;
logic wr_en_sub_out_fifo;
logic wr_en_deemph_add_out_fifo;
logic wr_en_deemph_sub_out_fifo;
logic wr_en_gain_left_out_fifo;
logic wr_en_gain_right_out_fifo;

//// DATA IN ////
logic [FIFO_DATA_WIDTH-1:0] din_q_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_i_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_q_fir_complex_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_i_fir_complex_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_demod_out_fifo;
// logic [FIFO_DATA_WIDTH-1:0] din_fir_demod_1_in_fifo;
// logic [FIFO_DATA_WIDTH-1:0] din_fir_demod_2_in_fifo;
// logic [FIFO_DATA_WIDTH-1:0] din_fir_demod_3_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_fir_demod_1_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_fir_demod_2_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_mult_A_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_fir_mutiA_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_mult_B_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_fir_mutiB_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_fir_demod_3_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_add_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_sub_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_deemph_add_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_deemph_sub_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_gain_left_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] din_gain_right_out_fifo;

//// FULL ////
logic full_q_in_fifo;
logic full_i_in_fifo;
logic full_q_fir_complex_out_fifo;
logic full_i_fir_complex_out_fifo;
logic full_demod_out_fifo;
logic full_fir_demod_1_in_fifo;
logic full_fir_demod_2_in_fifo;
logic full_fir_demod_3_in_fifo;
logic full_fir_demod_1_out_fifo;
logic full_fir_demod_2_out_fifo;
logic full_mult_A_out_fifo;
logic full_fir_mutiA_out_fifo;
logic full_mult_B_out_fifo;
logic full_fir_mutiB_out_fifo;
logic full_fir_demod_3_out_fifo;
logic full_add_out_fifo;
logic full_sub_out_fifo;
logic full_deemph_add_out_fifo;
logic full_deemph_sub_out_fifo;
logic full_gain_left_out_fifo;
logic full_gain_right_out_fifo;

//// READ ENABLES ////
logic rd_en_q_in_fifo;
logic rd_en_i_in_fifo;
logic rd_en_q_fir_complex_out_fifo;
logic rd_en_i_fir_complex_out_fifo;
logic rd_en_demod_out_fifo;
logic rd_en_fir_demod_1_in_fifo;
logic rd_en_fir_demod_2_in_fifo;
logic rd_en_fir_demod_3_in_fifo;
logic rd_en_fir_demod_1_out_fifo;
logic rd_en_fir_demod_2_out_fifo;
logic rd_en_mult_A_out_fifo;
logic rd_en_fir_mutiA_out_fifo;
logic rd_en_mult_B_out_fifo;
logic rd_en_fir_mutiB_out_fifo;
logic rd_en_fir_demod_3_out_fifo;
logic rd_en_add_out_fifo;
logic rd_en_sub_out_fifo;
logic rd_en_deemph_add_out_fifo;
logic rd_en_deemph_sub_out_fifo;
logic rd_en_gain_left_out_fifo;
logic rd_en_gain_right_out_fifo;

//// DATA OUT ////
logic [FIFO_DATA_WIDTH-1:0] dout_q_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_i_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_q_fir_complex_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_i_fir_complex_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_demod_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_demod_1_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_demod_2_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_demod_3_in_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_demod_1_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_demod_2_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_mult_A_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_mutiA_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_mult_B_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_mutiB_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_fir_demod_3_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_add_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_sub_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_deemph_add_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_deemph_sub_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_gain_left_out_fifo;
logic [FIFO_DATA_WIDTH-1:0] dout_gain_right_out_fifo;

//// EMPTY ////
logic empty_q_in_fifo;
logic empty_i_in_fifo;
logic empty_q_fir_complex_out_fifo;
logic empty_i_fir_complex_out_fifo;
logic empty_demod_out_fifo;
logic empty_fir_demod_1_in_fifo;
logic empty_fir_demod_2_in_fifo;
logic empty_fir_demod_3_in_fifo;
logic empty_fir_demod_1_out_fifo;
logic empty_fir_demod_2_out_fifo;
logic empty_mult_A_out_fifo;
logic empty_fir_mutiA_out_fifo;
logic empty_mult_B_out_fifo;
logic empty_fir_mutiB_out_fifo;
logic empty_fir_demod_3_out_fifo;
logic empty_add_out_fifo;
logic empty_sub_out_fifo;
logic empty_deemph_add_out_fifo;
logic empty_deemph_sub_out_fifo;
logic empty_gain_left_out_fifo;
logic empty_gain_right_out_fifo;

//// END FIFO SIGNALS ////

//// BEGIN COMBINATIONAL ASSIGNMENTS ////
assign din_q_in_fifo = q_din;
assign din_i_in_fifo = i_din;
assign q_in_full = full_q_in_fifo;
assign i_in_full = full_i_in_fifo;
assign left_dout = dout_gain_left_out_fifo;
assign right_dout = dout_gain_right_out_fifo;
assign left_out_empty = empty_gain_left_out_fifo;
assign right_out_empty = empty_gain_right_out_fifo;

/* connecting fifos bc there are two input fifos that should be written to simultaneously*/
assign wr_en_q_in_fifo = in_wr_en;
assign wr_en_i_in_fifo = in_wr_en;

/* connecting fifos bc multiply A is combinational */
assign rd_en_fir_demod_2_out_fifo = ~empty_fir_demod_2_out_fifo & ~full_mult_A_out_fifo;;
assign wr_en_mult_A_out_fifo = ~empty_fir_demod_2_out_fifo & ~full_mult_A_out_fifo;

/* connecting fifos bc multiply B is combinational
   two inputs so we want to read at same time */
assign rd_en_fir_demod_1_out_fifo = ~empty_fir_demod_1_out_fifo & ~empty_fir_mutiA_out_fifo & ~full_mult_B_out_fifo;
assign rd_en_fir_mutiA_out_fifo = ~empty_fir_demod_1_out_fifo & ~empty_fir_mutiA_out_fifo & ~full_mult_B_out_fifo;
assign wr_en_mult_B_out_fifo = ~empty_fir_demod_1_out_fifo & ~empty_fir_mutiA_out_fifo & ~full_mult_B_out_fifo;

/* connecting fifos bc gain LEFT is combinational */
assign rd_en_deemph_add_out_fifo = ~empty_deemph_add_out_fifo & ~full_gain_left_out_fifo;
assign wr_en_gain_left_out_fifo = ~empty_deemph_add_out_fifo & ~full_gain_left_out_fifo;

/* connecting fifos bc gain RIGHT is combinational */
assign rd_en_deemph_sub_out_fifo = ~empty_deemph_sub_out_fifo & ~full_gain_right_out_fifo;
assign wr_en_gain_right_out_fifo = ~empty_deemph_sub_out_fifo & ~full_gain_right_out_fifo;

/* connecting fifos bc 2 output fifos that should be read simultaneously */
assign rd_en_gain_right_out_fifo = out_rd_en;
assign rd_en_gain_left_out_fifo = out_rd_en;


//// BEGIN INSTANCES ////

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) q_in_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_q_in_fifo),
    .din(din_q_in_fifo),
    .full(full_q_in_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_q_in_fifo),
    .dout(dout_q_in_fifo),
    .empty(empty_q_in_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) i_in_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_i_in_fifo),
    .din(din_i_in_fifo),
    .full(full_i_in_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_i_in_fifo),
    .dout(dout_i_in_fifo),
    .empty(empty_i_in_fifo)
);

fir_cmplx fir_cmplx_inst (
    .clock(clk),
    .reset(reset),
    .i_in(dout_i_in_fifo),
    .q_in(dout_q_in_fifo),
    .i_rd_en(rd_en_i_in_fifo),
    .q_rd_en(rd_en_q_in_fifo),
    .i_empty(empty_i_in_fifo),
    .q_empty(empty_q_in_fifo),
    .y_out_real(din_i_fir_complex_out_fifo),
    .y_out_imag(din_q_fir_complex_out_fifo),
    .y_real_wr_en(wr_en_i_fir_complex_out_fifo),
    .y_imag_wr_en(wr_en_q_fir_complex_out_fifo),
    .y_real_full(full_i_fir_complex_out_fifo),
    .y_imag_full(full_q_fir_complex_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) q_fir_complex_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_q_fir_complex_out_fifo),
    .din(din_q_fir_complex_out_fifo),
    .full(full_q_fir_complex_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_q_fir_complex_out_fifo),
    .dout(dout_q_fir_complex_out_fifo),
    .empty(empty_q_fir_complex_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) i_fir_complex_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_i_fir_complex_out_fifo),
    .din(din_i_fir_complex_out_fifo),
    .full(full_i_fir_complex_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_i_fir_complex_out_fifo),
    .dout(dout_i_fir_complex_out_fifo),
    .empty(empty_i_fir_complex_out_fifo)
);

logic fir_input_fifos_empty;
assign fir_input_fifos_empty = empty_i_fir_complex_out_fifo | empty_q_fir_complex_out_fifo;

logic fir_input_fifos_rd_en;
assign rd_en_i_fir_complex_out_fifo = fir_input_fifos_rd_en;
assign rd_en_q_fir_complex_out_fifo = fir_input_fifos_rd_en;

demodulate demod_inst(
    .clk(clk),
    .reset(reset),
    .input_fifos_empty(fir_input_fifos_empty),
    .input_rd_en(fir_input_fifos_rd_en),
    .real_in(dout_i_fir_complex_out_fifo),
    .imag_in(dout_q_fir_complex_out_fifo),
    .demod_out(din_demod_out_fifo),
    .wr_en_out(wr_en_demod_out_fifo),
    .out_fifo_full(full_demod_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) demod_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_demod_out_fifo),
    .din(din_demod_out_fifo),
    .full(full_demod_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_demod_out_fifo),
    .dout(dout_demod_out_fifo),
    .empty(empty_demod_out_fifo)
);

// write to all three of these from demod_out_fifo at once!
logic ABE_full;
assign ABE_full = (full_fir_demod_1_in_fifo | full_fir_demod_2_in_fifo) | full_fir_demod_3_in_fifo;
assign wr_en_fir_demod_1_in_fifo = ~empty_demod_out_fifo & ~ABE_full;
assign wr_en_fir_demod_2_in_fifo = ~empty_demod_out_fifo & ~ABE_full;
assign wr_en_fir_demod_3_in_fifo = ~empty_demod_out_fifo & ~ABE_full;
assign rd_en_demod_out_fifo = ~empty_demod_out_fifo & ~ABE_full;


fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_demod_1_in_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_demod_1_in_fifo),
    .din(dout_demod_out_fifo),
    .full(full_fir_demod_1_in_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_demod_1_in_fifo),
    .dout(dout_fir_demod_1_in_fifo),
    .empty(empty_fir_demod_1_in_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_demod_2_in_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_demod_2_in_fifo),
    .din(dout_demod_out_fifo),
    .full(full_fir_demod_2_in_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_demod_2_in_fifo),
    .dout(dout_fir_demod_2_in_fifo),
    .empty(empty_fir_demod_2_in_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_demod_3_in_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_demod_3_in_fifo),
    .din(dout_demod_out_fifo),
    .full(full_fir_demod_3_in_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_demod_3_in_fifo),
    .dout(dout_fir_demod_3_in_fifo),
    .empty(empty_fir_demod_3_in_fifo)
);

fir #(
    .DATA_WIDTH(32),
    .COEFF(BP_LMR_COEFFS),
    .TAPS(BP_LMR_COEFF_TAPS),
    .DECIMATION(1)
) fir_demod_1(
    .clock(clk),
    .reset(reset),
    .x_in(dout_fir_demod_1_in_fifo),
    .x_rd_en(rd_en_fir_demod_1_in_fifo),
    .x_empty(empty_fir_demod_1_in_fifo),
    .y_out(din_fir_demod_1_out_fifo),
    .y_out_full(full_fir_demod_1_out_fifo),
    .y_wr_en(wr_en_fir_demod_1_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_demod_1_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_demod_1_out_fifo),
    .din(din_fir_demod_1_out_fifo),
    .full(full_fir_demod_1_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_demod_1_out_fifo),
    .dout(dout_fir_demod_1_out_fifo),
    .empty(empty_fir_demod_1_out_fifo)
);

fir #(
    .DATA_WIDTH(32),
    .COEFF(BP_PILOT_COEFFS),
    .TAPS(BP_PILOT_COEFF_TAPS),
    .DECIMATION(1)
) fir_demod_2(
    .clock(clk),
    .reset(reset),
    .x_in(dout_fir_demod_2_in_fifo),
    .x_rd_en(rd_en_fir_demod_2_in_fifo),
    .x_empty(empty_fir_demod_2_in_fifo),
    .y_out(din_fir_demod_2_out_fifo),
    .y_out_full(full_fir_demod_2_out_fifo),
    .y_wr_en(wr_en_fir_demod_2_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_demod_2_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_demod_2_out_fifo),
    .din(din_fir_demod_2_out_fifo),
    .full(full_fir_demod_2_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_demod_2_out_fifo),
    .dout(dout_fir_demod_2_out_fifo),
    .empty(empty_fir_demod_2_out_fifo)
);

multiply_n mult_A(
    .x_in(dout_fir_demod_2_out_fifo),
    .y_in(dout_fir_demod_2_out_fifo),
    .dout(din_mult_A_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) mult_A_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_mult_A_out_fifo),
    .din(din_mult_A_out_fifo),
    .full(full_mult_A_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_mult_A_out_fifo),
    .dout(dout_mult_A_out_fifo),
    .empty(empty_mult_A_out_fifo)
);

fir #(
    .DATA_WIDTH(32),
    .COEFF(HP_COEFFS),
    .TAPS(HP_COEFF_TAPS),
    .DECIMATION(1)
) fir_mutiA(
    .clock(clk),
    .reset(reset),
    .x_in(dout_mult_A_out_fifo),
    .x_rd_en(rd_en_mult_A_out_fifo),
    .x_empty(empty_mult_A_out_fifo),
    .y_out(din_fir_mutiA_out_fifo),
    .y_out_full(full_fir_mutiA_out_fifo),
    .y_wr_en(wr_en_fir_mutiA_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_mutiA_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_mutiA_out_fifo),
    .din(din_fir_mutiA_out_fifo),
    .full(full_fir_mutiA_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_mutiA_out_fifo),
    .dout(dout_fir_mutiA_out_fifo),
    .empty(empty_fir_mutiA_out_fifo)
);

multiply_n mult_B(
    .x_in(dout_fir_demod_1_out_fifo),
    .y_in(dout_fir_mutiA_out_fifo),
    .dout(din_mult_B_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) mult_B_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_mult_B_out_fifo),
    .din(din_mult_B_out_fifo),
    .full(full_mult_B_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_mult_B_out_fifo),
    .dout(dout_mult_B_out_fifo),
    .empty(empty_mult_B_out_fifo)
);

fir #(
    .DATA_WIDTH(32),
    .COEFF(AUDIO_LMR_COEFFS),
    .TAPS(AUDIO_LMR_COEFF_TAPS),
    .DECIMATION(AUDIO_DECIM)
) fir_mutiB(
    .clock(clk),
    .reset(reset),
    .x_in(dout_mult_B_out_fifo),
    .x_rd_en(rd_en_mult_B_out_fifo),
    .x_empty(empty_mult_B_out_fifo),
    .y_out(din_fir_mutiB_out_fifo),
    .y_out_full(full_fir_mutiB_out_fifo),
    .y_wr_en(wr_en_fir_mutiB_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_mutiB_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_mutiB_out_fifo),
    .din(din_fir_mutiB_out_fifo),
    .full(full_fir_mutiB_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_mutiB_out_fifo),
    .dout(dout_fir_mutiB_out_fifo),
    .empty(empty_fir_mutiB_out_fifo)
);

fir #(
    .DATA_WIDTH(32),
    .COEFF(AUDIO_LPR_COEFFS),
    .TAPS(AUDIO_LPR_COEFF_TAPS),
    .DECIMATION(AUDIO_DECIM)
) fir_demod_3(
    .clock(clk),
    .reset(reset),
    .x_in(dout_fir_demod_3_in_fifo),
    .x_rd_en(rd_en_fir_demod_3_in_fifo),
    .x_empty(empty_fir_demod_3_in_fifo),
    .y_out(din_fir_demod_3_out_fifo),
    .y_out_full(full_fir_demod_3_out_fifo),
    .y_wr_en(wr_en_fir_demod_3_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) fir_demod_3_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_fir_demod_3_out_fifo),
    .din(din_fir_demod_3_out_fifo),
    .full(full_fir_demod_3_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_fir_demod_3_out_fifo),
    .dout(dout_fir_demod_3_out_fifo),
    .empty(empty_fir_demod_3_out_fifo)
);

assign din_add_out_fifo = $signed(dout_fir_mutiB_out_fifo) + $signed(dout_fir_demod_3_out_fifo);
logic DE_empty_ADDSUB_full;
assign DE_empty_ADDSUB_full = (empty_fir_mutiB_out_fifo | empty_fir_demod_3_out_fifo) | (full_add_out_fifo | full_sub_out_fifo);
assign wr_en_add_out_fifo = ~DE_empty_ADDSUB_full;
assign wr_en_sub_out_fifo = ~DE_empty_ADDSUB_full;
assign rd_en_fir_mutiB_out_fifo = ~DE_empty_ADDSUB_full;
assign rd_en_fir_demod_3_out_fifo = ~DE_empty_ADDSUB_full;

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) add_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_add_out_fifo),
    .din(din_add_out_fifo),
    .full(full_add_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_add_out_fifo),
    .dout(dout_add_out_fifo),
    .empty(empty_add_out_fifo)
);

assign din_sub_out_fifo = $signed(dout_fir_demod_3_out_fifo) - $signed(dout_fir_mutiB_out_fifo);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) sub_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_sub_out_fifo),
    .din(din_sub_out_fifo),
    .full(full_sub_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_sub_out_fifo),
    .dout(dout_sub_out_fifo),
    .empty(empty_sub_out_fifo)
);

iir_fast #(
    .DEEMPH_DATA_WIDTH(32)
) deemph_add(
    .clock(clk),
    .reset(reset),
    .din(dout_add_out_fifo),
    .dout(din_deemph_add_out_fifo),
    .out_wr_en(wr_en_deemph_add_out_fifo),
    .in_empty(empty_add_out_fifo),
    .out_full(full_deemph_add_out_fifo),
    .in_rd_en(rd_en_add_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) deemph_add_out_fifo(
    .reset(reset),    
    .wr_clk(clk),
    .wr_en(wr_en_deemph_add_out_fifo),
    .din(din_deemph_add_out_fifo),
    .full(full_deemph_add_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_deemph_add_out_fifo),
    .dout(dout_deemph_add_out_fifo),
    .empty(empty_deemph_add_out_fifo)
);

iir_fast #(
    .DEEMPH_DATA_WIDTH(32)
) deemph_sub(
    .clock(clk),
    .reset(reset),
    .din(dout_sub_out_fifo),
    .dout(din_deemph_sub_out_fifo),
    .out_wr_en(wr_en_deemph_sub_out_fifo),
    .in_empty(empty_sub_out_fifo),
    .out_full(full_deemph_sub_out_fifo),
    .in_rd_en(rd_en_sub_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) deemph_sub_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_deemph_sub_out_fifo),
    .din(din_deemph_sub_out_fifo),
    .full(full_deemph_sub_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_deemph_sub_out_fifo),
    .dout(dout_deemph_sub_out_fifo),
    .empty(empty_deemph_sub_out_fifo)
);

gain_n #(
    .GAIN(1)
)gain_left(
    .din(dout_deemph_add_out_fifo),
    .dout(din_gain_left_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) gain_left_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_gain_left_out_fifo),
    .din(din_gain_left_out_fifo),
    .full(full_gain_left_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_gain_left_out_fifo),
    .dout(dout_gain_left_out_fifo),
    .empty(empty_gain_left_out_fifo)
);

gain_n #(
    .GAIN(1)
)gain_right(
    .din(dout_deemph_sub_out_fifo),
    .dout(din_gain_right_out_fifo)
);

fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH)
) gain_right_out_fifo(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_gain_right_out_fifo),
    .din(din_gain_right_out_fifo),
    .full(full_gain_right_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_en_gain_right_out_fifo),
    .dout(dout_gain_right_out_fifo),
    .empty(empty_gain_right_out_fifo)
);

//// END INSTANCES ////

endmodule