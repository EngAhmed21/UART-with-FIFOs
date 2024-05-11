module timer_top;
    localparam FINAL_VALUE = 16;

    logic clk;

    timer_IF #(.FINAL_VALUE(FINAL_VALUE)) IF (clk);

    timer DUT (IF);

    timer_tb TEST (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
endmodule