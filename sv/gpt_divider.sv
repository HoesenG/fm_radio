module signed_divider (
  input signed [31:0] dividend,
  input signed [31:0] divisor,
  output signed [31:0] quotient,
  output signed [31:0] remainder
);

  parameter WIDTH = 32;
  
  typedef enum logic [1:0] {
    IDLE,
    NEGATE_DIVIDEND,
    NEGATE_DIVISOR,
    SHIFT,
    SUBTRACT,
    DONE
  } state_t;
  
  state_t state;
  int unsigned dividend_abs;
  int unsigned divisor_abs;
  int signed quotient_temp;
  int signed remainder_temp;
  
  always_comb begin
    case (state)
      IDLE:
        if (dividend < 0)
          state = NEGATE_DIVIDEND;
        else if (divisor < 0)
          state = NEGATE_DIVISOR;
        else
          state = SHIFT;
      NEGATE_DIVIDEND:
        dividend_abs = -dividend;
        state = NEGATE_DIVISOR;
      NEGATE_DIVISOR:
        divisor_abs = -divisor;
        state = SHIFT;
      SHIFT:
        quotient_temp = 0;
        remainder_temp = dividend_abs;
        for (int i = WIDTH - 1; i >= 0; i--) begin
          quotient_temp <<= 1;
          remainder_temp <<= 1;
          quotient_temp[0] = remainder_temp[WIDTH];
          if (remainder_temp >= divisor_abs) begin
            remainder_temp -= divisor_abs;
            quotient_temp[0] = 1;
          end
        end
        if (dividend < 0 ^ divisor < 0)
          quotient_temp = -quotient_temp;
        quotient = quotient_temp;
        remainder = remainder_temp;
        state = DONE;
      DONE:
        // Do nothing
    endcase
  end
  
endmodule