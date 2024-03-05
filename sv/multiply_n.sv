
module multiply_n #(
    DATA_WIDTH = 32
)
(
    input  logic [DATA_WIDTH-1:0] x_in,
    input  logic [DATA_WIDTH-1:0] y_in,
    output logic [DATA_WIDTH-1:0] dout
    
);
int BITS = 10;
logic [31:0] QUANT_VAL = (1 << BITS);
function logic[31:0] DEQUANTIZE; 
input logic[31:0] i;
    begin
        return int'($signed(i) / $signed(QUANT_VAL));
    end
endfunction
assign dout = DEQUANTIZE(x_in * y_in);

endmodule