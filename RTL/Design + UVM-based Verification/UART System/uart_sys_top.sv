import sys_ref_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import uart_sys_test_pkg::*;

module uart_sys_top;
    logic clk;

    uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)) sys_if (clk);
    FIFO_IF #(.DEPTH(FIFO_DEPTH), .WIDTH(DBIT)) fifo_rx_if(clk);
    FIFO_IF #(.DEPTH(FIFO_DEPTH), .WIDTH(DBIT)) fifo_tx_if(clk);
    timer_IF #(FINAL_VALUE) timer_if(clk);
    uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_rx_if(clk); 
    uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_tx_if(clk); 

    uart_sys DUT (sys_if);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)).TEST)::set(null, "uvm_test_top", "SYS_IF", sys_if);
        uvm_config_db #(virtual timer_IF #(FINAL_VALUE).TEST)::set(null, "uvm_test_top", "TIMER_IF", timer_if);
        uvm_config_db #(virtual FIFO_IF #(.DEPTH(FIFO_DEPTH), .WIDTH(DBIT)).TEST)::set(null, "uvm_test_top", "FIFO_RX_IF", fifo_rx_if);
        uvm_config_db #(virtual FIFO_IF #(.DEPTH(FIFO_DEPTH), .WIDTH(DBIT)).TEST)::set(null, "uvm_test_top", "FIFO_TX_IF", fifo_tx_if);
        uvm_config_db #(virtual uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)).TEST)::set(null, "uvm_test_top", "UART_RX_IF", uart_rx_if);
        uvm_config_db #(virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)).TEST)::set(null, "uvm_test_top", "UART_TX_IF", uart_tx_if);

        run_test("uart_sys_test");
    end

    assign timer_if.rst_n = DUT.BRG.rst_n;
    assign timer_if.en    = DUT.BRG.en;
    assign timer_if.done  = DUT.BRG.done;

    assign fifo_rx_if.rst_n = DUT.FIFO_RX.rst_n;
    assign fifo_rx_if.WE    = DUT.FIFO_RX.WE;
    assign fifo_rx_if.RE    = DUT.FIFO_RX.RE;
    assign fifo_rx_if.din   = DUT.FIFO_RX.din;
    assign fifo_rx_if.full  = DUT.FIFO_RX.full;
    assign fifo_rx_if.empty = DUT.FIFO_RX.empty;
    assign fifo_rx_if.dout  = DUT.FIFO_RX.dout;

    assign fifo_tx_if.rst_n = DUT.FIFO_TX.rst_n;
    assign fifo_tx_if.WE    = DUT.FIFO_TX.WE;
    assign fifo_tx_if.RE    = DUT.FIFO_TX.RE;
    assign fifo_tx_if.din   = DUT.FIFO_TX.din;
    assign fifo_tx_if.full  = DUT.FIFO_TX.full;
    assign fifo_tx_if.empty = DUT.FIFO_TX.empty;
    assign fifo_tx_if.dout  = DUT.FIFO_TX.dout;

    assign uart_rx_if.rst_n   = DUT.UART_RX.rst_n;
    assign uart_rx_if.s_tick  = DUT.UART_RX.s_tick;
    assign uart_rx_if.rx      = DUT.UART_RX.rx;
    assign uart_rx_if.rx_done = DUT.UART_RX.rx_done;
    assign uart_rx_if.rx_dout = DUT.UART_RX.rx_dout;

    assign uart_tx_if.rst_n    = DUT.UART_TX.rst_n;
    assign uart_tx_if.s_tick   = DUT.UART_TX.s_tick;
    assign uart_tx_if.tx_start = DUT.UART_TX.tx_start;
    assign uart_tx_if.tx_din   = DUT.UART_TX.tx_din;
    assign uart_tx_if.tx       = DUT.UART_TX.tx;
    assign uart_tx_if.tx_done  = DUT.UART_TX.tx_done;
endmodule