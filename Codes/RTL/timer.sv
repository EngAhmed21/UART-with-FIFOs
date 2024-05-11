module timer #(parameter FINAL_VALUE = 650) (
    input logic clk, rst_n, en,
    output logic done
);
    localparam WIDTH = $clog2(FINAL_VALUE + 1);

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

        // done
        always_comb begin
            if (Q == FINAL_VALUE)
                timer_done_a: assert final (done); 
        end
    `endif
endmodule