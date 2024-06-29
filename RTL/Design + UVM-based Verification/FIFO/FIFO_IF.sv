interface FIFO_IF #(parameter WIDTH = 8, DEPTH = 128) (input logic clk);
    logic rst_n, WE, RE, full, empty;
    logic [WIDTH-1:0] din, dout;

    modport DUT (
    input clk, rst_n, WE, RE, din,
    output full, empty, dout
    );

    modport TEST (
    input clk, full, empty, dout,
    output rst_n, WE, RE, din
    );
endinterface //FIFO_IF