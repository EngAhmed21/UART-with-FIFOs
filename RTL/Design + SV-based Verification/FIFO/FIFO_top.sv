module FIFO_top;
    localparam WIDTH = 8;
    localparam DEPTH = 128;

    logic clk;

    FIFO_IF #(.WIDTH(WIDTH), .DEPTH(DEPTH)) IF (clk);

    FIFO DUT (IF);

    FIFO_tb TEST (IF);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
endmodule