package uart_rx_scoreboard_pkg;
    import uart_ref_pkg::*;
    import shared_pkg::*;
    import states_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_rx_seq_item_pkg::*;

    class uart_rx_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(uart_rx_scoreboard)

        uart_rx_seq_item sb_seq_item;
        uvm_analysis_export #(uart_rx_seq_item) sb_exp;
        uvm_tlm_analysis_fifo #(uart_rx_seq_item) sb_fifo;

        int error, correct;

        bit [$clog2(DBIT)-1:0] n_cnt_ref;
        bit [SCNT_BIT-1:0] s_cnt_nxt;
        state_e ns_ref;
        logic rx_done_ref;
        logic [DBIT-1:0] b_reg_ref, rx_dout_ref;

        function new(string name = "uart_rx_scoreboard", uvm_component parent = null);
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

                if ((sb_seq_item.rx_done != rx_done_ref) || (sb_seq_item.rx_dout != rx_dout_ref)) begin
                    `uvm_error("run_phase", $sformatf("Scoreboard - Comparison failed, Transaction received by the DUT: %0s, while the ref model out: rx_done_ref = %0b, rx_dout_ref = %0d",
                     sb_seq_item.convert2string(), rx_done_ref, rx_dout_ref))
                    error++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct uart_rx out: %0s", sb_seq_item.convert2string()), UVM_HIGH)
                    correct++;
                end
            end
        endtask

        task initialize;
            cs_ref      = IDLE;     n_cnt_ref   = 'd0;      
            s_cnt_ref   = 'd0;      rx_done_ref = 0;        
            rx_dout_ref = 'd0;      b_reg_ref   = 0;    
            ns_ref      = IDLE;     s_cnt_nxt   = 'd0;      
        endtask

        task ref_model(uart_rx_seq_item chk_seq_item);
            // ns 
            if (!chk_seq_item.rst_n)
                ns_ref = IDLE;
            else
                case (cs_ref)
                    IDLE:      ns_ref = (chk_seq_item.rx) ? IDLE : START;
                    START:     ns_ref = (chk_seq_item.s_tick && (s_cnt_ref == ((BIT_WIDTH/2)-1))) ? DATA : START;
                    DATA:      ns_ref = (chk_seq_item.s_tick && (s_cnt_ref == (BIT_WIDTH-1)) && (n_cnt_ref == (DBIT-1))) ? STOP : DATA;
                    STOP:      ns_ref = (chk_seq_item.s_tick && (s_cnt_ref == (SB_TICK-1))) ? IDLE : STOP;
                endcase

            // S counter next 
            if (!chk_seq_item.rst_n)
                s_cnt_nxt = 0;
            else 
                case (cs_ref)
                    IDLE:
                        if (~chk_seq_item.rx)
                            s_cnt_nxt = 0;       
                    START: 
                        if (chk_seq_item.s_tick) 
                            if (s_cnt_ref == ((BIT_WIDTH/2)-1))
                                s_cnt_nxt = 0;
                            else    
                                s_cnt_nxt = s_cnt_ref + 1;
                    DATA:      
                        if (chk_seq_item.s_tick) 
                            if (s_cnt_ref == (BIT_WIDTH-1))
                                s_cnt_nxt = 0;
                            else    
                                s_cnt_nxt = s_cnt_ref + 1;
                    STOP:       
                        if (chk_seq_item.s_tick) 
                            if (s_cnt_ref == (SB_TICK-1))
                                s_cnt_nxt = 0;
                            else    
                                s_cnt_nxt = s_cnt_ref + 1;
                endcase

            // N counter 
            if (!chk_seq_item.rst_n)
                n_cnt_ref = 0;
            else if (chk_seq_item.s_tick)
                if ((cs_ref == START) && (s_cnt_ref == ((BIT_WIDTH/2)-1)))
                    n_cnt_ref = 0;
                else if ((cs_ref == DATA) && (s_cnt_ref == (BIT_WIDTH-1)))
                    if (n_cnt_ref == (DBIT-1))
                        n_cnt_ref = 0;
                    else 
                        n_cnt_ref = n_cnt_ref + 1;

            // b_reg_ref
            if (!chk_seq_item.rst_n)
                b_reg_ref = 0;
            else if (chk_seq_item.s_tick && (cs_ref == DATA) && (s_cnt_ref == (BIT_WIDTH-1)))
                b_reg_ref = {chk_seq_item.rx, b_reg_ref[(DBIT-1):1]};

            // rx_done_ref
            if (!chk_seq_item.rst_n)
                rx_done_ref = 0;
            else
                rx_done_ref = (chk_seq_item.s_tick && (cs_ref == STOP) && (s_cnt_ref == (SB_TICK-1)));

            // rx_dout_ref
            rx_dout_ref = (rx_done_ref) ? b_reg_ref : 0;

            // next logic
            cs_ref    = ns_ref;
            s_cnt_ref = s_cnt_nxt;
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct), UVM_LOW)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error), UVM_LOW)
        endfunction
    endclass
endpackage