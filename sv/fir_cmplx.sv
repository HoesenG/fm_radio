

module fir_cmplx# (
    parameter [0:19][31:0] H_REAL =
{
	32'h00000001, 32'h00000008, 32'hfffffff3, 32'h00000009, 32'h0000000b, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 
	32'hffffffb1, 32'h00000257, 32'h00000257, 32'hffffffb1, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 32'h0000000b, 
	32'h00000009, 32'hfffffff3, 32'h00000008, 32'h00000001
},
    parameter [0:19][31:0] H_IMAG =
{
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000
},
    parameter TAPS = 20,
    parameter DECIMATION = 1
)
(
    input  logic        clock,
    input  logic        reset,

    input  logic [31:0] i_in,
    input  logic [31:0] q_in,
    output logic        i_rd_en,
    output logic        q_rd_en,
    input  logic        i_empty,
    input  logic        q_empty,

    output logic [31:0] y_out_real,
    output logic [31:0] y_out_imag,
    output logic        y_real_wr_en,
    output logic        y_imag_wr_en,
    input  logic        y_real_full,
    input  logic        y_imag_full
);

	
typedef enum logic[2:0] {s0, s1, s2, s3} state_t;
state_t state, state_c;
logic [0:19][31:0] x_real, x_real_c;
logic [0:19][31:0] x_imag, x_imag_c;
logic [31:0] count = 0; 
logic [31:0] count_c;
logic [31:0] sum_real, sum_real_c;
logic [31:0] sum_imag, sum_imag_c;
logic [31:0] y_out_real_c, y_out_imag_c;
logic y_real_wr_en_c, y_imag_wr_en_c;
logic in_empty;
logic in_rd_en;
logic out_full;
int BITS = 10;
logic [31:0] QUANT_VAL = (1 << BITS);
function logic[31:0] DEQUANTIZE; 
input logic[31:0] i;
    begin
        return int'($signed(i) >>>10);
    end
endfunction

assign in_empty = i_empty || q_empty;
assign i_rd_en = in_rd_en;
assign q_rd_en = in_rd_en;
assign out_full = y_real_full || y_imag_full;

always_ff @( posedge clock or posedge reset ) begin 
    if (reset == 1'b1) begin
        x_real <= '0;
        x_imag <= '0;
        // y_out_real <= '0;
        // y_out_imag <= '0;
        count <= '0;
        state <= s0;
        sum_real <= '0;
        sum_imag <= '0;
        // y_real_wr_en <= 1'b0;
        // y_imag_wr_en <= 1'b0;
    end else begin
        x_real <= x_real_c;
        x_imag <= x_imag_c;
        // y_out_real <= y_out_real_c;
        // y_out_imag <= y_out_imag_c;
        count <= count_c;
        state <= state_c;
        sum_real <= sum_real_c;
        sum_imag <= sum_imag_c;
        // y_real_wr_en <= y_real_wr_en_c;
        // y_imag_wr_en <= y_imag_wr_en_c;
    end
end

always_comb begin
    x_real_c = x_real;
    x_imag_c = x_imag;
    sum_real_c = sum_real;
    sum_imag_c = sum_imag;
    in_rd_en = 1'b0;
    y_real_wr_en = 1'b0;
    y_imag_wr_en = 1'b0;
    y_out_real = '0;
    y_out_imag = '0;
    count_c = count;
    case (state)
        s0: begin
            sum_real_c = '0;
            sum_imag_c = '0;
            if (in_empty == 1'b0) begin
                in_rd_en = 1'b1;
                x_real_c[1:19] = x_real[0:18];
                x_real_c[0] = i_in;

                x_imag_c[1:19] = x_imag[0:18];
                x_imag_c[0] = q_in;
                
                count_c = (count + 1) % DECIMATION;
                if (count == DECIMATION - 1) begin
                    state_c = s1;
                end else begin
                    state_c = s0;
                end
            end else begin
                state_c = s0;
            end
        end

        s1: begin
            sum_real_c = sum_real + DEQUANTIZE((H_REAL[count] * x_real[count]) - (H_IMAG[count] * x_imag));
            sum_imag_c = sum_imag + DEQUANTIZE((H_REAL[count] * x_imag[count]) - (H_IMAG[count] * x_real));

            count_c = (count + 1) % TAPS;
            if (count == TAPS - 1) begin
                state_c = s2;
            end else begin
                state_c = s1;
            end
        end

        s2: begin
            if (out_full == 1'b0) begin
                y_real_wr_en = 1'b1;
                y_imag_wr_en = 1'b1;
                y_out_real = sum_real;
                y_out_imag = sum_imag;
                state_c = s0;
            end else begin
                state_c = s2;
            end
        end

        default: begin
            state_c = s0;
            x_real_c = 'x;
            x_imag_c = 'x;
            count_c = '0;
        end
    endcase
end

endmodule
