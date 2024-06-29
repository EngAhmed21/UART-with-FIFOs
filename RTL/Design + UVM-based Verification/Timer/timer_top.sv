import timer_ref_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import timer_test_pkg::*;

module timer_top;
    bit clk;

    timer_IF #(.FINAL_VALUE(FINAL_VALUE)) IF (clk);

    timer DUT (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual timer_IF #(FINAL_VALUE).TEST)::set(null, "uvm_test_top", "VIF", IF);

        run_test("timer_test");
    end
endmodule
