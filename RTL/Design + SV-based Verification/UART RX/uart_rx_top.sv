import param_pkg::*;

module uart_rx_top;
    logic clk;

    uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) IF (clk);

    uart_rx DUT (IF);

    uart_rx_tb TEST (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
endmodule