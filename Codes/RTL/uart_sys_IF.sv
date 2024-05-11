// FINAL_VALUE = f / (BIT_WIDTH * b) 
// for f = 100 MHZ, b = 9600 bit/sec, BIT_WIDTH = 16 >> FINAL_VALUE = 650

interface uart_sys_IF #(parameter DBIT = 8, SB_TICK = 16, BIT_WIDTH = 16, FINAL_VALUE = 650, FIFO_DEPTH = 256) (input logic clk);
     logic rst_n, rx, rd_uart, wr_uart, tx, rx_empty, tx_full;
     logic [DBIT-1:0] w_data, r_data;

     modport DUT (
     input clk, rst_n, rx, rd_uart, wr_uart, w_data,
     output tx, rx_empty, tx_full, r_data
     ); 

     modport TEST (
     input clk, tx, rx_empty, tx_full, r_data,
     output rst_n, rx, rd_uart, wr_uart, w_data
     );
endinterface //uart_sys_IF