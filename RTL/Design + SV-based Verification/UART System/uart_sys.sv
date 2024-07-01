module uart_sys (uart_sys_IF.DUT IF);
    localparam BIT_WIDTH   = IF.BIT_WIDTH;
    localparam DBIT        = IF.DBIT;
    localparam SB_TICK     = IF.SB_TICK;
    localparam FINAL_VALUE = IF.FINAL_VALUE;
    localparam FIFO_DEPTH  = IF.FIFO_DEPTH;

    logic clk, rst_n, rx, rd_uart, wr_uart, tx, rx_empty, tx_full;
    logic [DBIT-1:0] w_data, r_data;

    assign clk         = IF.clk;
    assign rst_n       = IF.rst_n;
    assign rx          = IF.rx;
    assign rd_uart     = IF.rd_uart;
    assign wr_uart     = IF.wr_uart;
    assign w_data      = IF.w_data;
    assign IF.tx       = tx;
    assign IF.rx_empty = rx_empty;
    assign IF.tx_full  = tx_full;
    assign IF.r_data   = r_data;

    logic s_tick, tx_done, fifo_tx_empty, rx_done, tx_start;
    logic [DBIT-1:0] tx_din, rx_dout;

    // Baud Rate Generator
    timer #(.FINAL_VALUE(FINAL_VALUE)) BRG (.clk(clk), .rst_n(rst_n), .en(1'b1), .done(s_tick));

    // UART_TX
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            tx_start <= 0;
        else
            tx_start <= (~fifo_tx_empty);
    end
    uart_tx #(.BIT_WIDTH(BIT_WIDTH), .DBIT(DBIT), .SB_TICK(SB_TICK)) UART_TX (.clk(clk), .rst_n(rst_n), .s_tick(s_tick),
     .tx_start(tx_start), .tx_din(tx_din), .tx(tx), .tx_done(tx_done));

    // FIFO_TX
    FIFO #(.WIDTH(DBIT), .DEPTH(FIFO_DEPTH)) FIFO_TX (.clk(clk), .rst_n(rst_n), .WE(wr_uart), .RE(tx_done), .din(w_data),
     .full(tx_full), .empty(fifo_tx_empty), .dout(tx_din));

    // UART_RX
    uart_rx #(.BIT_WIDTH(BIT_WIDTH), .DBIT(DBIT), .SB_TICK(SB_TICK)) UART_RX (.clk(clk), .rst_n(rst_n), .s_tick(s_tick),
     .rx(rx), .rx_done(rx_done), .rx_dout(rx_dout));

    // FIFO_RX
    FIFO #(.WIDTH(DBIT), .DEPTH(FIFO_DEPTH)) FIFO_RX (.clk(clk), .rst_n(rst_n), .WE(rx_done), .RE(rd_uart), .din(rx_dout),
     .full(), .empty(rx_empty), .dout(r_data));
endmodule
