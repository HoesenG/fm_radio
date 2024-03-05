module sub_n #
(
    DATA_WIDTH = 8,
    AUDIO_SAMPLES = 10
) (
    input logic                     clock,
    input logic                     reset,
    input logic  [DATA_WIDTH-1:0]   x_in,
    input logic  [DATA_WIDTH-1:0]   y_in,
    output logic                     out_wr_en,
    input logic                     x_in_empty,
    input logic                     y_in_empty,
    input logic                     out_full,
    output logic [DATA_WIDTH-1:0]   dout,
    output logic                    x_in_rd_en,
    output logic                    y_in_rd_en
);

typedef enum logic [1:0] {s0, s1, s2} state_t;
state_t state, state_c;
logic [AUDIO_SAMPLES-1:0] i, i_c;

always_ff @( posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        i <= '0;
    end else begin
        state <= state_c;
        i <= i_c;
    end
end

always_comb begin 
    x_in_rd_en = 1'b0;
    y_in_rd_en = 1'b0;
    out_wr_en = 1'b0;
    state_c = state;
    dout = 'b0;
    i_c = i;

    case (state)
        s0: begin
            i_c = '0;
            if (x_in_empty == 1'b0 && y_in_empty == 1'b0) begin
                x_in_rd_en = 1'b1;
                y_in_rd_en = 1'b1;
                state_c = s1;
            end
        end

        s1: begin
            if ($unsigned(i) < $unsigned(AUDIO_SAMPLES)) begin
                state_c = s2;
            end else  begin
                state_c = s0;
            end
        end

        s2: begin
            if (out_full == 1'b0) begin
                dout = $signed(x_in) - $signed(y_in);
                out_wr_en = 1'b1;
                i_c = i + 1;
                state_c = s1;
            end

            
            
        end
    endcase
end
endmodule