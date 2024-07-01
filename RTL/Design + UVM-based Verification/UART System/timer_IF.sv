interface timer_IF #(parameter FINAL_VALUE = 16) (input logic clk);
    logic rst_n, en, done;

    modport DUT (
    input clk, rst_n, en,
    output done
    );

    modport TEST (
    input clk, done,
    output rst_n, en
    );
endinterface //timer_IF