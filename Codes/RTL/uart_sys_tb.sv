import states_pkg::*;
import ref_pkg::*;
import uart_sys_pkg::*;

module uart_sys_tb (uart_sys_IF.TEST IF);
    localparam BIT_WIDTH   = IF.BIT_WIDTH;
    localparam DBIT        = IF.DBIT;
    localparam SB_TICK     = IF.SB_TICK;
    localparam FINAL_VALUE = IF.FINAL_VALUE;
    localparam FIFO_DEPTH  = IF.FIFO_DEPTH;
    localparam FIFO_ADDR   = $clog2(FIFO_DEPTH);

    logic clk, rst_n, rx, rd_uart, wr_uart, tx, rx_empty, tx_full;
    logic [DBIT-1:0] w_data, r_data;

    assign clk        = IF.clk;
    assign IF.rst_n   = rst_n;
    assign IF.rx      = rx;
    assign IF.rd_uart = rd_uart;
    assign IF.wr_uart = wr_uart;
    assign IF.w_data  = w_data;
    assign tx         = IF.tx;
    assign rx_empty   = IF.rx_empty;
    assign tx_full    = IF.tx_full;
    assign r_data     = IF.r_data;

    int error_tx, correct_tx, error_rx, correct_rx;
    bit tx_start, tx_done, tx_ref, rx_done, tx_full_ref, rx_empty_ref, rx_full, tx_empty;
    bit [$clog2(FINAL_VALUE+1)-1:0] BRG_Q;
    bit [$clog2(DBIT)-1:0] tx_n_cnt, rx_n_cnt;
    bit [DBIT-1:0] tx_b_reg, rx_dout, r_data_ref, tx_dout;
    bit [DBIT-1:0] TX_FIFO [0:FIFO_DEPTH-1];
    bit [DBIT-1:0] RX_FIFO [0:FIFO_DEPTH-1];
    bit [FIFO_ADDR:0] tx_wr_ptr, tx_rd_ptr, rx_wr_ptr, rx_rd_ptr;

    uart_sys_rc rc;

    always @(posedge clk) begin
        rc.cvGrp.sample();
    end

    always @(*) begin
        rc.rx_empty = rx_empty;
        rc.tx_full  = tx_full;
        rc.r_data   = r_data;
    end

    initial begin
        rc = new;

        tx_cs        = IDLE;     tx_n_cnt    = 'd0;      
        tx_s_cnt     = 'd0;      rx_cs       = IDLE;
        rx_n_cnt     = 'd0;      rx_s_cnt    = 'd0;  
        s_tick       = 0;        tx_start    = 0;   
        tx_done      = 0;        tx_ref      = 1; 
        rx_done      = 0;        tx_full_ref = 0; 
        rx_empty_ref = 1;        rx_full     = 0;
        BRG_Q        = 0;        tx_b_reg    = 'd0;
        rx_dout      = 'd0;      r_data_ref  = 'd0;
        tx_wr_ptr    = 'd0;      tx_rd_ptr   = 'd0; 
        rx_wr_ptr    = 'd0;      rx_rd_ptr   = 'd0;
        tx_empty     = 1;

        check_rst;

        repeat (30000) begin
            assert (rc.randomize());
            rst_n   = rc.rst_n;
            wr_uart = rc.wr_uart;
            rd_uart = rc.rd_uart;
            rx      = rc.rx;
            w_data  = rc.w_data;
            
            check_result (rst_n, rd_uart, wr_uart, rx, w_data);
        end

        $display("\nSimulation finished with error_tx = %0d, correct_tx = %0d, error_rx = %0d, correct_rx = %0d", error_tx, correct_tx, error_rx, correct_rx);

        $stop;
    end

    task check_rst;
        rst_n = 0;

        @(negedge clk);

        // TX
        if ((~tx) || tx_full) begin
            $display("Check rst for TX failed at time = %0t, tx = %0d, tx_full = %0d", $time, tx, tx_full);
            error_tx++;
        end
        else
            correct_tx++;

        // RX
        if ((~rx_empty) || (r_data != 0)) begin
            $display("Check rst for RX failed at time = %0t, rx_empty = %0d, rx_empty = %0d", $time, rx_empty, r_data);
            error_rx++;
        end
        else
            correct_rx++;

        rst_n = 1;
    endtask //

    task golden_ref (input logic rst_n, rx, rd_uart, wr_uart, input logic [DBIT-1:0] w_data);
        // Baud Rate Generator
        if ((!rst_n) || (BRG_Q == FINAL_VALUE))
            BRG_Q <= 0;
        else
            BRG_Q <= BRG_Q + 1;

        s_tick = (BRG_Q == FINAL_VALUE);




        // UART_TX
        // tx_start
        if (!rst_n)
            tx_start <= 0;
        else
            tx_start <= (tx_wr_ptr != tx_rd_ptr);

        // cs 
        if (!rst_n)
            tx_cs <= IDLE;
        else
            case (tx_cs)
                IDLE:       tx_cs <= (tx_start) ? START : IDLE;
                START:      tx_cs <= (s_tick && (tx_s_cnt == (BIT_WIDTH-1))) ? DATA : START;
                DATA:       tx_cs <= (s_tick && (tx_s_cnt == (BIT_WIDTH-1)) && (tx_n_cnt == (DBIT-1))) ? STOP : DATA;
                STOP:       tx_cs <= (s_tick && (tx_s_cnt == (SB_TICK-1))) ? IDLE : STOP;
                default:    tx_cs <= IDLE; 
            endcase

        // S counter 
        if (!rst_n)
            tx_s_cnt <= 0;
        else 
            case (tx_cs)
                IDLE:
                    if (tx_start)
                        tx_s_cnt <= 0;       
                START: 
                    if (s_tick) 
                        if (tx_s_cnt == (BIT_WIDTH-1))
                            tx_s_cnt <= 0;
                        else    
                            tx_s_cnt <= tx_s_cnt + 1;
                DATA:      
                    if (s_tick) 
                        if (tx_s_cnt == (BIT_WIDTH-1))
                            tx_s_cnt <= 0;
                        else    
                            tx_s_cnt <= tx_s_cnt + 1;
                STOP:       
                    if (s_tick) 
                        if (tx_s_cnt == (SB_TICK-1))
                            tx_s_cnt <= 0;
                        else    
                            tx_s_cnt <= tx_s_cnt + 1;
            endcase

        // N counter 
        if (!rst_n)
            tx_n_cnt <= 0;
        else if (s_tick)
            if ((tx_cs == START) && (tx_s_cnt == (BIT_WIDTH-1)))
                tx_n_cnt <= 0;
            else if ((tx_cs == DATA) && (tx_s_cnt == (BIT_WIDTH-1)))
                if (tx_n_cnt == (DBIT-1))
                    tx_n_cnt <= 0;
                else 
                    tx_n_cnt <= tx_n_cnt + 1;

        // tx_b_reg
        if (!rst_n)
           tx_b_reg <= 0;
        else if ((tx_s_cnt == 'd0) && (tx_cs == START))
            tx_b_reg <= tx_dout;
        else if (s_tick && (tx_cs == DATA) && (tx_s_cnt == (BIT_WIDTH-1)))
            tx_b_reg <= (tx_b_reg >> 1);

        // tx_ref
        if (!rst_n)
            tx_ref <= 1;
        else if (tx_cs == START)
            tx_ref <= 0;
        else if ((tx_cs == IDLE) || (tx_cs == STOP))
            tx_ref <= 1;
        else if (tx_cs == DATA)
            tx_ref <= tx_b_reg[0];

        // tx_done
        if (!rst_n)
            tx_done <= 0;
        else
            tx_done <= (s_tick && (tx_cs == STOP) && (tx_s_cnt == (SB_TICK-1)));
        



        // FIFO_TX
        // Write
        if (!rst_n) 
            tx_wr_ptr <= 0;
        else if (wr_uart && (~((tx_wr_ptr[FIFO_ADDR-1:0] == tx_rd_ptr[FIFO_ADDR-1:0]) && (tx_wr_ptr[FIFO_ADDR] != tx_rd_ptr[FIFO_ADDR])))) begin
            TX_FIFO [tx_wr_ptr[FIFO_ADDR-1:0]] <= w_data;
            tx_wr_ptr <= tx_wr_ptr + 1;
        end

        // Read
        if (!rst_n) begin
            tx_rd_ptr <= 0;
            tx_dout <= 0;
        end
        else if (tx_done && (tx_wr_ptr != tx_rd_ptr)) begin
            tx_dout <= TX_FIFO [tx_rd_ptr[FIFO_ADDR-1:0]];
            tx_rd_ptr <= tx_rd_ptr + 1;
        end




        // UART_RX
        // cs 
        if (!rst_n)
            rx_cs <= IDLE;
        else
            case (rx_cs)
                IDLE:      rx_cs <= (rx) ? IDLE : START;
                START:     rx_cs <= (s_tick && (rx_s_cnt == ((BIT_WIDTH/2)-1))) ? DATA : START;
                DATA:      rx_cs <= (s_tick && (rx_s_cnt == (BIT_WIDTH-1)) && (rx_n_cnt == (DBIT-1))) ? STOP : DATA;
                STOP:      rx_cs <= (s_tick && (rx_s_cnt == (SB_TICK-1))) ? IDLE : STOP;
            endcase

        // S counter 
        if (!rst_n)
            rx_s_cnt <= 0;
        else 
            case (rx_cs)
                IDLE:
                    if (~rx)
                        rx_s_cnt <= 0;       
                START: 
                    if (s_tick) 
                        if (rx_s_cnt == ((BIT_WIDTH/2)-1))
                            rx_s_cnt <= 0;
                        else    
                            rx_s_cnt <= rx_s_cnt + 1;
                DATA:      
                    if (s_tick) 
                        if (rx_s_cnt == (BIT_WIDTH-1))
                            rx_s_cnt <= 0;
                        else    
                            rx_s_cnt <= rx_s_cnt + 1;
                STOP:       
                    if (s_tick) 
                        if (rx_s_cnt == (SB_TICK-1))
                            rx_s_cnt <= 0;
                        else    
                            rx_s_cnt <= rx_s_cnt + 1;
            endcase

        // N counter 
        if (!rst_n)
            rx_n_cnt <= 0;
        else if (s_tick)
            if ((rx_cs == START) && (rx_s_cnt == ((BIT_WIDTH/2)-1)))
                rx_n_cnt <= 0;
            else if ((rx_cs == DATA) && (rx_s_cnt == (BIT_WIDTH-1)))
                if (rx_n_cnt == (DBIT-1))
                    rx_n_cnt <= 0;
                else 
                    rx_n_cnt <= rx_n_cnt + 1;

        // rx_dout
        if (!rst_n)
            rx_dout <= 0;
        else if (s_tick && (rx_cs == DATA) && (rx_s_cnt == (BIT_WIDTH-1)))
            rx_dout <= {rx, rx_dout[(DBIT-1):1]};

        // rx_done
        if (!rst_n)
            rx_done <= 0;
        else
            rx_done <= (s_tick && (rx_cs == STOP) && (rx_s_cnt == (SB_TICK-1)));




        // FIFO_RX
        // Write
        if (!rst_n) 
            rx_wr_ptr <= 0;
        else if (rx_done && (~((rx_wr_ptr[FIFO_ADDR-1:0] == rx_rd_ptr[FIFO_ADDR-1:0]) && (rx_wr_ptr[FIFO_ADDR] != rx_rd_ptr[FIFO_ADDR])))) begin
            RX_FIFO[rx_wr_ptr[FIFO_ADDR-1:0]] <= rx_dout;
            rx_wr_ptr <= rx_wr_ptr + 1;
        end

        // Read
        if (!rst_n) begin
            rx_rd_ptr  <= 0;
            r_data_ref <= 0;
        end
        else if (rd_uart && (rx_wr_ptr != rx_rd_ptr)) begin
            r_data_ref <= RX_FIFO[rx_rd_ptr[FIFO_ADDR-1:0]];
            rx_rd_ptr  <= rx_rd_ptr + 1;
        end




        // Combinational
        @(negedge clk)
        // TX_Flags
        tx_full_ref  = ((tx_wr_ptr[FIFO_ADDR-1:0] == tx_rd_ptr[FIFO_ADDR-1:0]) && (tx_wr_ptr[FIFO_ADDR] != tx_rd_ptr[FIFO_ADDR]));
        tx_empty = (tx_wr_ptr == tx_rd_ptr);

        // RX Flags
        rx_full      = ((rx_wr_ptr[FIFO_ADDR-1:0] == rx_rd_ptr[FIFO_ADDR-1:0]) && (rx_wr_ptr[FIFO_ADDR] != rx_rd_ptr[FIFO_ADDR]));
        rx_empty_ref = (rx_wr_ptr == rx_rd_ptr);
    endtask //

    task check_result (input logic rst_n, rd_uart, wr_uart, rx, input logic [DBIT-1:0] w_data);
        golden_ref (rst_n, rx, rd_uart, wr_uart, w_data);

        // TX
        if ((tx != tx_ref) || (tx_full != tx_full_ref)) begin
            $display("Check result fot TX failed at time = %0t, rst_n = %0d, wr_uart = %0d, w_data = %0d, tx = %0d, tx_ref = %0b, tx_full = %0b, tx_full_ref = %0b",
             $time, rst_n, wr_uart, w_data, tx, tx_ref, tx_full, tx_full_ref);
            error_tx++;
        end
        else
            correct_tx++;

        // RX
        if ((r_data != r_data_ref) || (rx_empty != rx_empty_ref)) begin
            $display("Check result fot TX failed at time = %0t, rst_n = %0d, rd_uart = %0d, rx = %0d, r_data = %0d, r_data_ref = %0b, rx_empty = %0b, rx_empty_ref = %0b",
             $time, rst_n, rd_uart, rx, r_data, r_data_ref, rx_empty, rx_empty_ref);
            error_rx++;
        end
        else
            correct_rx++;
    endtask //
endmodule