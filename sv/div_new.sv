
module div #(
    parameter data_width = 16
) (
    input  logic clock,
    input  logic reset,
    input  logic start,
    input  logic                        valid_in,
    output logic                        valid_out,
    input  logic [data_width-1:0] dividend,
    input  logic [data_width-1:0] divisor,
    output logic [data_width-1:0] quotient,
    output logic [data_width-1:0] remainder,
    output logic wr_en
);

typedef enum logic [2:0]{IDLE, S0, S1, S2, S3, S4, S5} state_t;
state_t state, state_c;

logic [data_width-1:0] a, b, q, a_c, b_c, q_c, quo_c, rem_c;
logic sign, sign_c, wr_en_c;
logic [data_width-1:0] divd_abs, divs_abs, p, p_c;

function automatic logic [7:0] get_msb (input[31:0]y, input[7:0]top, input[7:0] bottom);
    logic[7:0] res = 0;
    logic[7:0] upper = 0;
    logic[7:0] lower = 0;

    if (top - bottom == 1)begin
		    if(y[bottom] == 1)begin
			      return bottom;
		    end else begin
			      return res;
        end
		end else begin
		    upper = get_msb(y, top, bottom + ((top - bottom)>>1));
		    lower = get_msb(y, bottom + ((top - bottom)>>1), bottom);
		    if ($unsigned(upper)>$unsigned(lower)) begin
			     return upper;
		    end else begin
			     return lower;
		    end
	  end
endfunction

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        a <= 0;
        b <= 0;
        q <= 0;
        sign <= 0;
        state <= IDLE;
        wr_en <= 0;
        quotient <= 0;
        remainder <= 0;
        p <= 0;
    end else begin
        a <= a_c;
        b <= b_c;
        q <= q_c;
        sign <= sign_c;
        state <= state_c;
        wr_en <= wr_en_c;
        quotient <= quo_c;
        remainder <= rem_c;
        p <= p_c;
    end
end


always_comb begin
    state_c = state;
    quo_c = 0;
    rem_c = 0;
    a_c = a;
    b_c = b;
    q_c = q;
    sign_c = sign;
    divd_abs = 0;
    divs_abs = 0;
    wr_en_c = 0;
    p_c = p;


    case(state)
      IDLE: begin
  			if (start == 1)begin
  				  state_c = S0;
  			end else begin
  				  if (sign==1)begin
  				      quo_c =-q;
  				  end else begin
  					    quo_c = q;
  				  end

  				  if(dividend[31]==1)begin
  					     rem_c = -a;
  				  end else begin
  					     rem_c = a;
  				  end
  				  state_c = IDLE;
  			end
      end

      S0: begin
          q_c = 0;

          if($signed(dividend) < 0)begin
              divd_abs = -dividend;
          end else begin
              divd_abs = dividend;
          end

          if($signed(divisor) < 0)begin
              b_c = -divisor;
              divs_abs = -divisor;
          end else begin
              b_c = divisor;
              divs_abs = divisor;
          end

          if (divs_abs == 1)begin
              q_c = divd_abs;
              a_c = 0;
              state_c = S1;
          end else begin
              a_c = divd_abs;
              state_c = S2;
          end
          sign_c = dividend[31] ^ divisor[31];
      end

      S1: begin
          if (sign == 1)begin
              quo_c = -q;
          end else begin
              quo_c = q;
          end
          if(dividend[31] == 1)begin
              rem_c = -a;
          end else begin
              rem_c = a;
          end
          wr_en_c = 1;
          state_c = IDLE;
      end

      S2 : begin
    			if( (b !=0) && ($unsigned(a)>=$unsigned(b))) begin
      				p_c = get_msb(a, 32, 0) - get_msb(b, 32, 0);
              state_c = S3;

    			end else begin
    				  state_c = S1;
    			end
      end
      S3: begin
          if( $unsigned(b << p) > $unsigned(a))begin
              state_c = S4;
          end else begin
              state_c = S5;
          end
      end
      S4: begin
          q_c = q + (1 << (p-1));
          a_c = a - (b << (p-1));
          state_c = S2;
      end

      S5: begin
          q_c = q + (1 << p);
          a_c = a - (b << p);
          state_c = S2;
      end

    endcase
end
endmodule