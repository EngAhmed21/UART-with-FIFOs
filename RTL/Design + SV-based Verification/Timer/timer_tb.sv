import timer_pkg::*;

module timer_tb (timer_IF.TEST IF);
    localparam FINAL_VALUE = IF.FINAL_VALUE;
    localparam WIDTH = $clog2(FINAL_VALUE + 1);

    logic clk, rst_n, en, done;

    assign clk      = IF.clk;
    assign IF.rst_n = rst_n;
    assign IF.en    = en;
    assign done     = IF.done;

    bit [WIDTH-1:0] Q_ref;
    bit done_ref;
    int error, correct;

    timer_rc rc;

    always @(posedge clk) begin
        rc.cvGrp.sample();
    end

    always @(*) begin
        rc.done = done;
    end

    initial begin
        rc = new;

        done_ref = 0;
        Q_ref    = 0;

        check_rst;

        repeat (10000) begin
            assert (rc.randomize());
            rst_n = rc.rst_n;
            en    = rc.en;
            
            check_result (rst_n, en);
        end

        $display("Simulation finished with error counter = %0d, correct counter = %0d", error, correct);

        $stop;
    end

    task check_rst;
        rst_n = 0;

        @(negedge clk);
        if (done != 0) begin
            $display("Check rst failed at time = %0t, done = %0d", $time, done);
            error++;
        end
        else
            correct++;

        rst_n = 1;
    endtask //

    task golden_ref (input logic rst_n, en);
        if ((!rst_n) || done_ref)
            Q_ref = 0;
        else if (en)
            Q_ref++;

        done_ref = (Q_ref == FINAL_VALUE);
    endtask //

    task check_result (input logic rst_n, en);
        golden_ref (rst_n, en);

        @(negedge clk);
        if (done_ref != done) begin
            $display("Check result failed at time = %0t, rst_n = %0d, en = %0d, done = %0d, done_ref = %0d",
             $time, rst_n, en, done, done_ref);
            error++;
        end
        else
            correct++;
    endtask //
endmodule