import FIFO_ref_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_test_pkg::*;

module FIFO_top;
    bit clk;

    FIFO_IF #(.WIDTH(WIDTH), .DEPTH(DEPTH)) IF (clk);

    FIFO DUT (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual FIFO_IF #(.WIDTH(WIDTH), .DEPTH(DEPTH)).TEST)::set(null, "uvm_test_top", "VIF", IF);

        run_test("FIFO_test");
    end
endmodule
