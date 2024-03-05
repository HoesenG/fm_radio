`include "../coeffs.svh"

module coeffs_tb;

import macros::*;
import coeffs::*;

initial begin
    $display(IIR_Y_COEFFS);
    $display(IIR_X_COEFFS);
    $display(CHANNEL_COEFFS_IMAG);
    $display(AUDIO_LPR_COEFFS);
    $display(PI);
end

endmodule