module timer (timer_IF.DUT IF);
    localparam FINAL_VALUE = IF.FINAL_VALUE;
    localparam WIDTH = $clog2(FINAL_VALUE + 1);

    logic clk, rst_n, en, done;

    assign clk     = IF.clk;
    assign rst_n   = IF.rst_n;
    assign en      = IF.en;
    assign IF.done = done;

    logic [WIDTH-1:0] Q;

    always @(posedge clk, negedge rst_n) begin
        if ((!rst_n) || done)
            Q <= 0;
        else if (en)
            Q <= Q + 1;
    end

    assign done = (Q == FINAL_VALUE);

    `ifdef TIMER_SIM
        // reset
        always_comb begin
            if (!rst_n)
                timer_rst_a: assert final (Q == 0);
        end

        // enable
        property timer_enable_p;
            @(posedge clk) disable iff (!rst_n) (en) |=> (($past(done) && (Q == 0)) || ((~($past(done))) && (Q == ($past(Q) + 1'b1))));
        endproperty
        timer_enable_a: assert property (timer_enable_p);
        timer_enable_c: cover  property (timer_enable_p);

        // not enable
        property timer_not_enable_p;
            @(posedge clk) disable iff ((!rst_n)) (!en) |=> (($past(done) && (Q == 0)) || ((~($past(done))) && ($stable(Q))));
        endproperty
        timer_not_enable_a: assert property (timer_not_enable_p);
        timer_not_enable_c: cover  property (timer_not_enable_p);

        // done
        always_comb begin
            if (Q == FINAL_VALUE)
                timer_done_a: assert final (done); 
        end
    `endif
endmodule
