
Conversation opened. 2 messages. 1 message unread.

Skip to content
Using @u.northwestern.edu Mail with screen readers
1 of 2,512
(no subject)
Inbox
Zifeng Zhang
	
	10:06 AM (4 hours ago)
fm_radio.zip
Alan Guo
	
2:11 PM (15 minutes ago)
	
to me


module div #(
    parameter DIVIDEND_WIDTH = 32,
    parameter DIVISOR_WIDTH = 32
)
(
    input  logic                        clk,
    input  logic                        reset,
    input  logic                        valid_in,
    input  logic [DIVIDEND_WIDTH-1:0]   dividend,
    input  logic [DIVISOR_WIDTH-1:0]    divisor,
    output logic [DIVIDEND_WIDTH-1:0]   quotient,
    output logic [DIVISOR_WIDTH-1:0]    remainder,
    output logic                        valid_out,
    output logic                        overflow
);

typedef enum logic [2:0] { INIT, IDLE, LOOP1, LOOP2, EPILOGUE, DONE } state_t;
state_t state, state_c;

    
logic [DIVIDEND_WIDTH-1:0] a, a_c,z,z_c;
logic [DIVISOR_WIDTH-1:0] b, b_c;
logic [DIVIDEND_WIDTH-1:0] q, q_c;
// logic [DIVISOR_WIDTH-1:0] r, r_c;
logic internal_sign;
integer p;
integer one;
integer a_minus_b;
integer remainder_condition;


// function automatic logic [7:0] get_msb_pos;
//     input [31:0] val;
//     integer i;
//     begin
//         get_msb_pos = 0;
//         for (i=31;i>0;i--)begin
//             if(val[i]==1'b1) return i;
//         end
//     end

// endfunction

function automatic logic [7:0] get_msb_pos (input[31:0]y, input[7:0]top, input[7:0] bottom);
    logic[7:0] res = 0;
    logic[7:0] upper = 0;
    logic[7:0] lower = 0;
    begin
    if (top - bottom == 1)begin
            if(y[bottom] == 1)begin
                  return bottom;
            end else begin
                  return res;
        end
        end else begin
            upper = get_msb_pos(y, top, bottom + ((top - bottom)>>1));
            lower = get_msb_pos(y, bottom + ((top - bottom)>>1), bottom);
            if ($unsigned(upper)>$unsigned(lower)) begin
                 return upper;
            end else begin
                 return lower;
            end
        end
    end
endfunction

always_ff @( posedge clk or posedge reset ) begin
    if (reset == 1'b1) begin
        state <= IDLE;
        a <= '0;
        b <= '0;
        q <= '0;
    end else begin
        state <= state_c;
        a <= a_c;
        b <= b_c;
        q <= q_c;
        z <= z_c;
    end
end

assign quotient = z;

always_comb begin
    // Initialize all combinational variables to default values
    a_c = a;
    b_c = b;
    q_c = q;
    p = '0; // Initialize p to a default value
    state_c = state; // Default next state is the current state
    valid_out = '0; // Default output valid signal is '0'
    overflow = '0; // Default overflow is '0' to avoid latch
    remainder_condition ='0;
    remainder= '0;
    //quotient='0;
    z_c=z;
    // Your existing case statement follows
    case(state)
        IDLE: begin
            if (valid_in) begin
                state_c = INIT;
            end else begin
                state_c = IDLE;
            end
        end

        INIT: begin
            overflow = 0; // Reset overflow for this cycle
            a_c = (dividend[31] == 1'b0) ? $signed(dividend) : $signed(-dividend);
            b_c = (divisor[31] == 1'b0) ? $signed(divisor) : $signed(-divisor);
            q_c = '0;
            // if (divisor == 1) begin
            //     state_c = B_EQ_1;
            // if (divisor == 0) begin
            //     overflow = 1; // Set overflow if divisor is 0
            //     state_c = DONE; // Assuming DONE is a final state for handling overflow
            // end else begin
            state_c = LOOP1;
            // end
        end

        // B_EQ_1: begin
        //     q_c = dividend;
        //     a_c = '0;
        //     state_c = EPILOGUE;
        // end

        LOOP1: begin
            // Calculate new values for a_c, b_c, q_c, and p based on logic
            // You already have this part written out, make sure every path assigns values
            // Update: Ensure p has a default value or is always assigned before used
            //p = get_msb_pos(a) - get_msb_pos(b);
            p = get_msb_pos(a,32,0) - get_msb_pos(b,32,0);
            state_c = LOOP2;
        end

        LOOP2: begin
            if (($signed(b) << p) > $signed(a)) begin
                p = p - 1;
                state_c = LOOP3;
            end
            q_c = DIVIDEND_WIDTH'(q + (1 << p));
            if (($signed(b) != '0) && ($signed(b) <= $signed(a))) begin
                a_minus_b = $signed(a) - $signed($signed(b) << p);
                a_c = a_minus_b;
            end else begin
              
                remainder_condition = $signed(dividend) >>> (DIVIDEND_WIDTH - 1);
                  state_c = EPILOGUE;
            end
        end
        
        EPILOGUE: begin
            internal_sign = dividend[DIVIDEND_WIDTH-1] ^ divisor[DIVISOR_WIDTH-1];
            z_c = (internal_sign == 1'b0) ? q : -q;

            remainder = (remainder_condition != 1) ? a : -a;
            valid_out= 1;
            state_c =IDLE;
        end
        
        // DONE: begin

        // end
        
        // default: begin
    
        //     p = '0; // Initialize p to a default value
        //     state_c = state; // Default next state is the current state
        //     valid_out = '0; // Default output valid signal is '0'
        //     //overflow = '0;
        // end
    endcase
end


endmodule
Best,
Alan Guo


On Mon, Mar 4, 2024 at 10:07 AM Zifeng Zhang <zifengzhang2025@u.northwestern.edu> wrote:

     fm_radio.zip

 One attachment  •  Scanned by Gmail
	
Thanks a lot.
Thanks a lot for sharing.
Fixed!
