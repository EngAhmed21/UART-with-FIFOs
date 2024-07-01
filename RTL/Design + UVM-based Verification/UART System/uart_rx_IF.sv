interface uart_rx_IF #(parameter DBIT = 8, SB_TICK = 16, BIT_WIDTH = 16) (input logic clk);
    logic rst_n, s_tick, rx, rx_done;
    logic [DBIT-1:0] rx_dout;

    modport DUT (
    input clk, rst_n, s_tick, rx,
    output rx_done, rx_dout
    );

    modport TEST (
    input clk, rx_done, rx_dout,
    output rst_n, s_tick, rx
    );
endinterface //uart_rx_IF