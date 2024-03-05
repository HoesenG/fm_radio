`timescale 1ns/1ns

module iir_fast_tb ();

/* files */
localparam string IN_FILE_NAME = "../left_channel.txt";
localparam string CMP_FILE_NAME = "../left_deemph.txt";

localparam int DATA_WIDTH = 32;
localparam int DATA_SIZE = 100;
localparam int CLOCK_PERIOD = 10;

/* signals for tb */
logic start, out_read_done, in_write_done;
logic in_wr_en;
logic in_full;
logic out_rd_en;
logic out_empty;
integer out_errors = 0;

/* signals interfacing iir */
logic clock, reset;
logic [DATA_WIDTH-1:0] din, dout;

/* iir instance */
iir_fast_top dut (
    .clock(clock),
    .reset(reset),
    .din(din),
    .in_wr_en(in_wr_en),
    .in_full(in_full),
    .dout(dout),
    .out_rd_en(out_rd_en),
    .out_empty(out_empty)
);

/* clock */
always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

/* reset */
initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clock);
    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    start = 1'b1;
    @(posedge clock);
    start = 1'b0;

    wait(out_read_done);
    end_time = $time;

    // report metrics
    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", out_errors);

    // end the simulation
    $finish;
end

initial begin : read_process
    int i, r;
    int in_file;
    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IN_FILE_NAME);
    in_write_done = 1'b0;

    in_file = $fopen(IN_FILE_NAME, "r");
    in_wr_en = 1'b0;
    i = 0;
    while (i < DATA_SIZE) begin
        @(negedge clock);
        if (in_full == 1'b0) begin
            r = $fscanf(in_file, "%08h", din);
            in_wr_en = 1'b1;
            i++;
        end else begin
            in_wr_en = 1'b0;
        end
    end

    @(negedge clock);
    in_wr_en = 1'b0;
    $fclose(in_file);
    in_write_done = 1'b1;
end

initial begin : comp_process
    int i, r;
    int cmp_file;
    logic [DATA_WIDTH-1:0] cmp_dout;

    @(negedge reset);
    @(posedge clock);

    $display("@ %0t: Comparing file %s...", $time, CMP_FILE_NAME);
    
    cmp_file = $fopen(CMP_FILE_NAME, "r");
    out_rd_en = 1'b0;
    i = 0;
    while (i < (DATA_SIZE)) begin
        @(negedge clock);
        out_rd_en = 1'b0;
            if (out_empty == 1'b0) begin
                out_rd_en = 1'b1;
                r = $fscanf(cmp_file, "%08h", cmp_dout);
                if (cmp_dout != dout) begin
                    out_errors++;
                    $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, "out file", i+1, {dout}, cmp_dout, i);
                end
                i++;
            end 
        end

    @(negedge clock);
    out_rd_en = 1'b0;
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule


