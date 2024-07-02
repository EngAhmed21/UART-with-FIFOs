package uart_sys_scoreboard_pkg;
    import sys_ref_pkg::*;
    import uart_sys_shared_pkg::*;
    import states_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;

    class uart_sys_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(uart_sys_scoreboard)

        uart_sys_seq_item sb_seq_item;
        uvm_analysis_export #(uart_sys_seq_item) sb_exp;
        uvm_tlm_analysis_fifo #(uart_sys_seq_item) sb_fifo;

        int error, correct;

        state_e tx_ns, rx_ns;
        bit tx_full_ref, rx_empty_ref, rx_full, tx_empty, tx_start;
        bit [SCNT_BIT-1:0] tx_s_cnt_nxt, rx_s_cnt_nxt;
        bit [$clog2(DBIT)-1:0] tx_n_cnt, rx_n_cnt;
        bit [FIFO_ADDR:0] tx_wr_ptr, tx_rd_ptr, rx_wr_ptr, rx_rd_ptr;
        logic tx_done, tx_ref, rx_done;
        logic [$clog2(FINAL_VALUE+1)-1:0] BRG_Q;
        logic [DBIT-1:0] RX_FIFO [FIFO_DEPTH];
        logic [DBIT-1:0] TX_FIFO [FIFO_DEPTH];
        logic [DBIT-1:0] tx_b_reg, rx_dout, r_data_ref, tx_dout;

        function new(string name = "uart_sys_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            sb_exp  = new("sb_exp", this);
            sb_fifo = new("sb_fifo", this); 
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            
            sb_exp.connect(sb_fifo.analysis_export);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            initialize();
            forever begin
                sb_fifo.get(sb_seq_item);
                ref_model(sb_seq_item);

                if ((sb_seq_item.tx != tx_ref) || (sb_seq_item.tx_full != tx_full_ref || (sb_seq_item.rx_empty != rx_empty_ref) || (sb_seq_item.r_data != r_data_ref)) ) begin
                    `uvm_error("run_phase", $sformatf("Scoreboard - Comparison failed, Transaction received by the DUT: %0s, while the ref model out: tx_ref = %0b, tx_full_ref = %0b, rx_empty_ref = %0b, r_data_ref = %0d",
                     sb_seq_item.convert2string(), tx_ref, tx_full_ref, rx_empty_ref, r_data_ref))    
                    error++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct uart_sys out: %0s", sb_seq_item.convert2string()), UVM_HIGH)
                    correct++;
                end
            end
        endtask

        task initialize;
            tx_cs        = IDLE;      rx_cs        = IDLE;
            tx_ns        = IDLE;      rx_ns        = IDLE;  
            tx_s_cnt     = 'd0;       rx_s_cnt     = 'd0;
            rx_empty_ref = 1;         tx_empty     = 1;
            tx_n_cnt     = 0;         rx_n_cnt     = 0;
            tx_s_cnt_nxt = 0;         rx_s_cnt_nxt = 0;
        endtask

        task ref_model(uart_sys_seq_item chk_seq_item);
            //////////////////////////// Baud Rate Generator ////////////////////////////
            if ((!chk_seq_item.rst_n) || (BRG_Q == FINAL_VALUE))
                BRG_Q = 0;
            else
                BRG_Q = BRG_Q + 1;

            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            //////////////////////////// UART_TX ////////////////////////////
            // ns 
            if (!chk_seq_item.rst_n) begin
                tx_ns = IDLE;
                tx_cs = IDLE;
            end
            else
                case (tx_cs)
                    IDLE:      tx_ns = (tx_start) ? START : IDLE;
                    START:     tx_ns = (s_tick && (tx_s_cnt == (BIT_WIDTH-1))) ? DATA : START;
                    DATA:      tx_ns = (s_tick && (tx_s_cnt == (BIT_WIDTH-1)) && (tx_n_cnt == (DBIT-1))) ? STOP : DATA;
                    STOP:      tx_ns = (s_tick && (tx_s_cnt == (SB_TICK-1))) ? IDLE : STOP;
                endcase

           // S counter next 
            if (!chk_seq_item.rst_n) begin
                tx_s_cnt_nxt = 0;
                tx_s_cnt     = 0;
            end
            else 
                case (tx_cs)
                    IDLE:
                        if (tx_start)
                            tx_s_cnt_nxt = 0;       
                    START: 
                        if (s_tick) 
                            if (tx_s_cnt == (BIT_WIDTH-1))
                                tx_s_cnt_nxt = 0;
                            else    
                                tx_s_cnt_nxt = tx_s_cnt + 1;
                    DATA:      
                        if (s_tick) 
                            if (tx_s_cnt == (BIT_WIDTH-1))
                                tx_s_cnt_nxt = 0;
                            else    
                                tx_s_cnt_nxt = tx_s_cnt + 1;
                    STOP:       
                        if (s_tick) 
                            if (tx_s_cnt == (SB_TICK-1))
                                tx_s_cnt_nxt = 0;
                            else    
                                tx_s_cnt_nxt = tx_s_cnt + 1;
                endcase

            // N counter 
            if (!chk_seq_item.rst_n)
                tx_n_cnt = 0;
            else if (s_tick)
                if ((tx_cs == START) && (tx_s_cnt == (BIT_WIDTH-1)))
                    tx_n_cnt = 0;
                else if ((tx_cs == DATA) && (tx_s_cnt == (BIT_WIDTH-1)))
                    if (tx_n_cnt == (DBIT-1))
                        tx_n_cnt = 0;
                    else 
                        tx_n_cnt = tx_n_cnt + 1;

            // tx_ref
            if ((!chk_seq_item.rst_n) || (tx_cs == IDLE) || (tx_cs == STOP))
                tx_ref = 1;
            else if (tx_cs == START)
                tx_ref = 0;
            else if (tx_cs == DATA)
                tx_ref = tx_b_reg[0];

            // tx_b_reg
            if (!chk_seq_item.rst_n)
                tx_b_reg = 0;
            else if ((tx_s_cnt == 'd0) && (tx_cs == START))
                tx_b_reg = tx_dout;
            else if (s_tick && (tx_cs == DATA) && (tx_s_cnt == (BIT_WIDTH-1)))
                tx_b_reg = (tx_b_reg >> 1);

            // tx_start
            tx_start = ~tx_empty;

            //////////////////////////// FIFO_TX ////////////////////////////
            // Write
            if (!chk_seq_item.rst_n) 
                tx_wr_ptr = 0;
            else if (chk_seq_item.wr_uart && (!tx_full_ref)) begin
                TX_FIFO [tx_wr_ptr[FIFO_ADDR-1:0]] = chk_seq_item.w_data;
                tx_wr_ptr = tx_wr_ptr + 1;
            end

            // Read
            if (!chk_seq_item.rst_n) begin
                tx_rd_ptr = 0;
                tx_dout   = 0;
            end
            else if (tx_done && (!tx_empty)) begin
                tx_dout   = TX_FIFO [tx_rd_ptr[FIFO_ADDR-1:0]];
                tx_rd_ptr = tx_rd_ptr + 1;
            end

            // Flags
            tx_full_ref = ((tx_wr_ptr[FIFO_ADDR-1:0] == tx_rd_ptr[FIFO_ADDR-1:0]) && (tx_wr_ptr[FIFO_ADDR] != tx_rd_ptr[FIFO_ADDR]));
            tx_empty    = (tx_wr_ptr == tx_rd_ptr);


            //////////////////////////// TX next logic & done ////////////////////////////
            // tx_done
            if ((!chk_seq_item.rst_n) || (tx_cs == IDLE))
                tx_done = 1;
            else
                tx_done = (s_tick && (tx_cs == STOP) && (tx_s_cnt == (SB_TICK-1)));

            // next logic
            tx_cs    = tx_ns;
            tx_s_cnt = tx_s_cnt_nxt;

            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            //////////////////////////// FIFO_RX ////////////////////////////
            // Write
            if (!chk_seq_item.rst_n) 
                rx_wr_ptr = 0;
            else if (rx_done && (!rx_full)) begin
                RX_FIFO [rx_wr_ptr[FIFO_ADDR-1:0]] = rx_dout;
                rx_wr_ptr = rx_wr_ptr + 1;
            end

            // Read
            if (!chk_seq_item.rst_n) begin
                rx_rd_ptr  = 0;
                r_data_ref = 0;
            end
            else if (chk_seq_item.rd_uart && (!rx_empty_ref)) begin
                r_data_ref = RX_FIFO [rx_rd_ptr[FIFO_ADDR-1:0]];
                rx_rd_ptr = rx_rd_ptr + 1;
            end

            // Flags
            rx_full      = ((rx_wr_ptr[FIFO_ADDR-1:0] == rx_rd_ptr[FIFO_ADDR-1:0]) && (rx_wr_ptr[FIFO_ADDR] != rx_rd_ptr[FIFO_ADDR]));
            rx_empty_ref = (rx_wr_ptr == rx_rd_ptr);


            //////////////////////////// UART_RX ////////////////////////////
            // cs 
            if (!chk_seq_item.rst_n) begin
                rx_cs = IDLE;
                rx_ns = IDLE;

            end
            else
                case (rx_cs)
                    IDLE:      rx_ns = (chk_seq_item.rx) ? IDLE : START;
                    START:     rx_ns = (s_tick && (rx_s_cnt == ((BIT_WIDTH/2)-1))) ? DATA : START;
                    DATA:      rx_ns = (s_tick && (rx_s_cnt == (BIT_WIDTH-1)) && (rx_n_cnt == (DBIT-1))) ? STOP : DATA;
                    STOP:      rx_ns = (s_tick && (rx_s_cnt == (SB_TICK-1))) ? IDLE : STOP;
                endcase

            // S counter 
            if (!chk_seq_item.rst_n) begin
                rx_s_cnt     = 0;
                rx_s_cnt_nxt = 0;
            end
            else 
                case (rx_cs)
                    IDLE:
                        if (~chk_seq_item.rx)
                            rx_s_cnt_nxt = 0;       
                    START: 
                        if (s_tick) 
                            if (rx_s_cnt == ((BIT_WIDTH/2)-1))
                                rx_s_cnt_nxt = 0;
                            else    
                                rx_s_cnt_nxt = rx_s_cnt + 1;
                    DATA:      
                        if (s_tick) 
                            if (rx_s_cnt == (BIT_WIDTH-1))
                                rx_s_cnt_nxt = 0;
                            else    
                                rx_s_cnt_nxt = rx_s_cnt + 1;
                    STOP:       
                        if (s_tick) 
                            if (rx_s_cnt == (SB_TICK-1))
                                rx_s_cnt_nxt = 0;
                            else    
                                rx_s_cnt_nxt = rx_s_cnt + 1;
                endcase

            // N counter 
            if (!chk_seq_item.rst_n)
                rx_n_cnt = 0;
            else if (s_tick)
                if ((rx_cs == START) && (rx_s_cnt == ((BIT_WIDTH/2)-1)))
                    rx_n_cnt = 0;
                else if ((rx_cs == DATA) && (rx_s_cnt == (BIT_WIDTH-1)))
                    if (rx_n_cnt == (DBIT-1))
                        rx_n_cnt = 0;
                    else 
                        rx_n_cnt = rx_n_cnt + 1;

            // rx_dout
            if (!chk_seq_item.rst_n)
                rx_dout = 0;
            else if (s_tick && (rx_cs == DATA) && (rx_s_cnt == (BIT_WIDTH-1)))
                rx_dout = {chk_seq_item.rx, rx_dout[(DBIT-1):1]};

            // rx_done
            if (!chk_seq_item.rst_n)
                rx_done = 0;
            else
                rx_done = (s_tick && (rx_cs == STOP) && (rx_s_cnt == (SB_TICK-1)));

            // next logic
            rx_cs    = rx_ns;
            rx_s_cnt = rx_s_cnt_nxt;


            //////////////////////////// s_tick ////////////////////////////
            s_tick = (BRG_Q == FINAL_VALUE);

        endtask
        
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct), UVM_LOW)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error), UVM_LOW)
        endfunction
    endclass
endpackage
