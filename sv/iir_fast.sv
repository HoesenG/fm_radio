module iir_fast #(
    parameter int DEEMPH_DATA_WIDTH = 32
) (
    input logic clock,
    input logic reset,
    input logic [DEEMPH_DATA_WIDTH-1:0] din,
    output logic [DEEMPH_DATA_WIDTH-1:0] dout,
    output logic out_wr_en,
    input logic in_empty,
    input logic out_full,
    output logic in_rd_en
);

function logic[31:0] DEQUANTIZE; 
input logic[31:0] i;
    begin
        return int'($signed(i) >>>10);
    end
endfunction

// Coeffs
localparam int b0 = 178;//QUANTIZE_F(W_PP / (1.0 + W_PP));
localparam int b1 = 178;//QUANTIZE_F(W_PP / (1.0 + W_PP));
localparam int a1 = 0;//QUANTIZE_F(0.0);
localparam int a0 = -666;//QUANTIZE_F((W_PP - 1.0)/(W_PP + 1.0));

typedef enum logic [2:0] {init, s0, s1, s2, s3, s4, s5} state_t;
state_t state, state_c;

logic [0:1][DEEMPH_DATA_WIDTH-1:0]shift_reg_x, shift_reg_y, shift_reg_x_c, shift_reg_y_c;
logic [DEEMPH_DATA_WIDTH-1:0] x_sum, x_sum_c;
logic [DEEMPH_DATA_WIDTH-1:0] x_mult0, x_mult1, x_mult0_c, x_mult1_c;
logic [DEEMPH_DATA_WIDTH-1:0] y_mult0, y_mult1, y_mult0_c, y_mult1_c;
logic [DEEMPH_DATA_WIDTH-1:0] y_sum, y_sum_c;

    

always_ff @(posedge clock or posedge clock) begin
    if (reset) begin
        shift_reg_x <= '{default: '0};
        shift_reg_y <= '{default: '0};
        state <= init;
        x_sum <= '0;
        y_sum <= '0;
        x_mult0 <= '0;
        x_mult1 <= '0;
        y_mult0 <= '0;
    end else begin
        state <= state_c;
        shift_reg_x <= shift_reg_x_c;
        shift_reg_y <= shift_reg_y_c;
        y_mult0 <= y_mult0_c;
        x_mult0 <= x_mult0_c;
        x_mult1 <= x_mult1_c;
        x_sum <= x_sum_c;
        y_sum <= y_sum_c;
    end
end

assign dout = y_sum;

always_comb begin
    shift_reg_x_c = shift_reg_x;
    shift_reg_y_c = shift_reg_y;
    state_c = state;
    in_rd_en = 1'b0;
    out_wr_en = 1'b0;
    y_mult0_c = y_mult0;
    x_mult0_c = x_mult0;
    x_mult1_c = x_mult1;
    x_sum_c = x_sum;
    y_sum_c = y_sum;

case (state) 

    (init): begin
        if (out_full == 1'b0) begin
            y_sum_c = '0;
            out_wr_en = 1'b1;
            state_c = s0;
    end
    end
    (s0): begin
        if (in_empty == 1'b0) begin
            in_rd_en = 1'b1;
            shift_reg_x_c[1] = shift_reg_x[0];
            shift_reg_x_c[0] = din;
            shift_reg_y_c[1] = shift_reg_y[0];
            shift_reg_y_c[0] = dout;
            x_mult0_c = $signed(din)*$signed(b0);
            state_c = s1;
        end
    end
    (s1): begin
        x_mult0_c = DEQUANTIZE(x_mult0);
        x_mult1_c = $signed(shift_reg_x[1]) * $signed(b1);
        //x_mult0_c = DEQUANTIZE($signed(shift_reg_x[0])*$signed(b0));
        state_c = s2;
    end
    (s2): begin
        x_mult1_c = DEQUANTIZE(x_mult1);
        y_mult0_c = $signed(dout) * $signed(a0);
        
        state_c = s3;
    end
    (s3): begin
        y_mult0_c = DEQUANTIZE(y_mult0);
        x_sum_c = $signed(x_mult0) + $signed(x_mult1);
        state_c = s4;
    end
    (s4): begin
        y_sum_c = $signed(x_sum) + $signed(y_mult0);
        state_c = s5;
        
    end
    (s5): begin
        if (out_full == 1'b0) begin
            out_wr_en = 1'b1;
            state_c = s0;
    end
    end
    
endcase




end

endmodule
