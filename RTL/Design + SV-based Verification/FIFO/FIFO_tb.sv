import FIFO_pkg::*;

module FIFO_tb (FIFO_IF.TEST IF);
    localparam WIDTH = IF.WIDTH;
    localparam DEPTH = IF.DEPTH;
    localparam ADDR  = $clog2(DEPTH);

    logic clk, rst_n, WE, RE, full, empty;
    logic [WIDTH-1:0] din, dout;

    assign clk      = IF.clk;
    assign IF.rst_n = rst_n;
    assign IF.WE    = WE;
    assign IF.RE    = RE;
    assign IF.din   = din;
    assign full     = IF.full;
    assign empty    = IF.empty;
    assign dout     = IF.dout;

    bit full_ref, empty_ref;
    bit [WIDTH-1:0] dout_ref;
    bit [WIDTH-1:0] MEM_ref [DEPTH];
    bit [ADDR:0] rd_ptr_ref, wr_ptr_ref;
    int error, correct;

    FIFO_rc #(.WIDTH(WIDTH)) rc;

    always @(*)
        rc.dout = dout;

    always @(posedge clk)
        rc.cvGrp.sample();

    initial begin
        rc = new;

        dout_ref  = 0;
        full_ref  = 0;
        empty_ref = 1;

        check_rst;

        repeat (10000) begin
            assert (rc.randomize());
            rst_n = rc.rst_n;
            WE    = rc.WE;
            RE    = rc.RE;
            din   = rc.din;

            check_result (rst_n, WE, RE, din);
        end

        $display("Simulation finished with error counter = %0d, correct counter = %0d", error, correct);

        $stop;
    end

    task check_rst;
        rst_n = 0;

        @(negedge clk);
        if ((dout != 0) || full || (~empty)) begin
            $display("Check rst failed at time = %0t, dout = %0d, full = %0d, empty = %0d", $time, dout, full, empty);
            error++;
        end
        else
            correct++;

        rst_n = 1;
    endtask //

    task golden_ref (input bit rst_n, WE, RE, input bit [WIDTH-1:0] din);
        // Write
        if (!rst_n) 
            wr_ptr_ref = 0;
        else if (WE && (!full_ref)) begin
            MEM_ref[wr_ptr_ref[ADDR-1:0]] = din;
            wr_ptr_ref++;
        end

        // Read
        if (!rst_n) begin
            rd_ptr_ref = 0;
            dout_ref   = 0;
        end
        else if (RE && (!empty_ref)) begin
            dout_ref = MEM_ref[rd_ptr_ref[ADDR-1:0]];
            rd_ptr_ref++;
        end

        // Flags
        full_ref  = ((wr_ptr_ref[ADDR-1:0] == rd_ptr_ref[ADDR-1:0]) && (wr_ptr_ref[ADDR] != rd_ptr_ref[ADDR]));
        empty_ref = (wr_ptr_ref == rd_ptr_ref);
    endtask //

    task check_result (input bit rst_n, WE, RE, input bit [WIDTH-1:0] din);
        golden_ref (rst_n, WE, RE, din);

        @(negedge clk);
        if ((dout_ref != dout) || (full_ref != full) || (empty_ref != empty)) begin
            $display("Check result failed at time = %0t, rst_n = %0d, WE = %0d, RE = %0d, din = %0d, dout = %0d, dout_ref = %0d, full = %0d, full_ref = %0d, empty = %0d, empty_ref = %0d",
             $time, rst_n, WE, RE, din, dout, dout_ref, full, full_ref, empty, empty_ref);
            error++;
        end
        else
            correct++;
    endtask //
endmodule