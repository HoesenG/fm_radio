// `include "coeffs.svh";

// import macros::*;
// import coeffs::*;

module fir_fast #(
    parameter DATA_WIDTH = 32,
    parameter [0:31][31:0] COEFF =
'{
	(32'hffffffff), (32'h00000000), (32'h00000000), (32'h00000002), (32'h00000004), (32'h00000008), (32'h0000000b), (32'h0000000c), 
	(32'h00000008), (32'hffffffff), (32'hffffffee), (32'hffffffd7), (32'hffffffbb), (32'hffffff9f), (32'hffffff87), (32'hffffff76), 
	(32'hffffff76), (32'hffffff87), (32'hffffff9f), (32'hffffffbb), (32'hffffffd7), (32'hffffffee), (32'hffffffff), (32'h00000008), 
	(32'h0000000c), (32'h0000000b), (32'h00000008), (32'h00000004), (32'h00000002), (32'h00000000), (32'h00000000), (32'hffffffff)
},
    parameter TAPS = 32,
    parameter DECIMATION = 8
)
(
    input  logic                    clock,
    input  logic                    reset,
    
    input  logic [DATA_WIDTH-1:0]   x_in,
    output logic                    x_rd_en,
    input  logic                    x_empty,

    output logic [DATA_WIDTH-1:0]   y_out,
    input  logic                    y_out_full,
    output logic                    y_wr_en
);

function logic[31:0] DEQUANTIZE; 
input logic[31:0] i;
    begin
        return int'($signed(i) / $signed(1 << 10));
    end
endfunction

typedef enum logic[2:0] {s0, s1, s2, s3, s4} state_t;
state_t state, state_c;
logic [0:31][31:0] x, x_c;
logic [31:0] count = 0; 
logic [31:0] count_c;
logic [31:0] sum, sum_c, temp_sum, temp_sum_c;
logic [31:0] y_out_c;
logic y_wr_en_c;

always_ff @( posedge clock or posedge reset ) begin
    if (reset == 1'b1) begin
        x <= '0;
        y_out <= '0;
        count <= '0;
        state <= s0;
        y_wr_en <= 1'b0;
        temp_sum <= '0;
    end else begin
        x <= x_c;
        y_out <= y_out_c;
        count <= count_c;
        state <= state_c;
        sum <= sum_c;
        y_wr_en <= y_wr_en_c;
        temp_sum <= temp_sum_c;
    end
end

always_comb begin
    x_c = x;
    sum_c = '0;
    temp_sum_c = '0;
    x_rd_en = 1'b0;
    y_wr_en_c = 1'b0;
    y_out_c = '0;

    case (state)
        s0: begin
            if (x_empty == 1'b0) begin
                x_rd_en = 1'b1;
                x_c[0] = x_in;
                x_c[1:31] = x[0:30];
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
            temp_sum_c = COEFF[TAPS - count - 1] * x[count];
            sum_c = sum;
            count_c = count;
            state_c = s2;
        end

        s2: begin
            temp_sum_c = DEQUANTIZE(temp_sum);
            sum_c = sum;
            count_c = count;
            state_c = s3;
        end

        s3: begin
            sum_c = sum + temp_sum;
            count_c = (count + 1) % 32;
            if (count == 31) begin 
                state_c = s4;
            end else begin
                state_c = s1;
            end
        end

        s4: begin
            if (y_out_full == 1'b0) begin
                y_wr_en_c = 1'b1;
                y_out_c = sum;
                state_c = s0;
            end else begin
                state_c = s4;
            end
        end

        default: begin
            state_c = s0;
            x_c = 'x;
            count_c = '0;
        end
    endcase
end 

endmodule