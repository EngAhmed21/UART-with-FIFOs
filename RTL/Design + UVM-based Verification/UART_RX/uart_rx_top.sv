import uart_ref_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import uart_rx_test_pkg::*;

module uart_rx_top;
    bit clk;

    uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) IF (clk);

    uart_rx DUT (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)).TEST)::set(null, "uvm_test_top", "VIF", IF);

        run_test("uart_rx_test");
    end
endmodule
