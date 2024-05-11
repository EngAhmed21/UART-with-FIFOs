import param_pkg::*;

module uart_sys_top;
    logic clk;

    uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)) IF (clk);

    uart_sys DUT (IF);

    uart_sys_tb TEST (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
endmodule