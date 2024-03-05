module demodulate_old (
    input   logic           clk,
    input   logic           reset,
    input   logic           input_fifos_empty,
    output  logic           input_rd_en,
    input   logic [31:0]    real_in,
    input   logic [31:0]    imag_in,
    output  logic [31:0]    demod_out,
    output  logic           wr_en_out,
    input   logic           out_fifo_full
);

    
import macros::*;

const logic [31:0] gain = 32'h000002f6;

logic [31:0] real_curr, imag_curr, real_prev, imag_prev, qarctan_out, qarctan_out_times_gain;
logic [63:0] real_prev_times_curr, imag_prev_times_curr, neg_imag_prev_times_imag, neg_imag_prev_times_real;
logic [31:0] short_real, short_imag;
logic qarctan_ready, qarctan_done;
logic demod_data_valid;

qarctan qarctan_inst (
    .clk(clk), 
    .reset(reset),
    .demod_data_valid(demod_data_valid),
    .divider_ready(qarctan_ready),
    .x(short_real),
    .y(short_imag),
    .data_out(qarctan_out),
    .qarctan_done(qarctan_done)
);

always_ff @( posedge clk or posedge reset ) begin

    if (reset == 1'b1) begin
        real_curr <= '0;
        imag_curr <= '0;
        real_prev <= '0;
        imag_prev <= '0;
        demod_data_valid <= '0;
    end else begin
        if (qarctan_ready && ~input_fifos_empty && ~out_fifo_full) begin
            real_curr <= real_in;
            imag_curr <= imag_in;
            real_prev <= real_curr;
            imag_prev <= imag_curr;
            demod_data_valid <= '1;
        end else begin
            real_curr <= real_curr;
            imag_curr <= imag_curr;
            real_prev <= real_prev;
            imag_prev <= imag_prev;
            demod_data_valid <= '0;
        end
    end
end

always_comb begin
    // input combinational logic
    real_prev_times_curr = $signed(real_prev) * $signed(real_curr);
    imag_prev_times_curr = $signed(real_prev) * $signed(imag_curr);
    neg_imag_prev_times_imag = -$signed(imag_prev) * $signed(imag_curr);
    neg_imag_prev_times_real = -$signed(imag_prev) * $signed(real_curr);
    short_real = DEQUANTIZE(real_prev_times_curr[31:0]) - DEQUANTIZE(neg_imag_prev_times_imag);
    short_imag = DEQUANTIZE(imag_prev_times_curr[31:0]) + DEQUANTIZE(neg_imag_prev_times_real);
    input_rd_en = qarctan_ready && ~input_fifos_empty && ~out_fifo_full;

    // output combinational logic
    qarctan_out_times_gain = qarctan_out * gain;
    demod_out = DEQUANTIZE(qarctan_out_times_gain[31:0]);
    wr_en_out = qarctan_done;

end

endmodule
