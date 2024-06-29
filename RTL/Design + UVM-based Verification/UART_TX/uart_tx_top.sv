import uart_ref_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import uart_tx_test_pkg::*;

module uart_tx_top;
    logic clk;

    uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) IF (clk);

    uart_tx DUT (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)).TEST)::set(null, "uvm_test_top", "VIF", IF);

        run_test("uart_tx_test");
    end
endmodule
