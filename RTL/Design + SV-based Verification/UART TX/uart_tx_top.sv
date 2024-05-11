import param_pkg::*;

module uart_tx_top;
    logic clk;

    uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) IF (clk);

    uart_tx DUT (IF);

    uart_tx_tb TEST (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
endmodule