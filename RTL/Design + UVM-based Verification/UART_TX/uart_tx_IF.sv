interface uart_tx_IF #(parameter DBIT = 8, SB_TICK = 16, BIT_WIDTH = 16) (input logic clk);
    logic rst_n, s_tick, tx_start, tx, tx_done;
    logic [DBIT-1:0] tx_din;

    modport DUT (
    input clk, rst_n, s_tick, tx_start, tx_din,
    output tx, tx_done
    );

    modport TEST (
    input clk, tx, tx_done,
    output rst_n, s_tick, tx_start, tx_din
    );
endinterface //uart_rx_IF