

module gain_n #(
    DATA_WIDTH = 32,
    GAIN = 1
)
(
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

logic [31:0] mult;
logic [31:0] deq;
logic [31:0] shift;
int BITS = 10;



always_comb begin
    mult = din * GAIN;
    shift = mult << (14-BITS);
    dout = shift;
end
endmodule