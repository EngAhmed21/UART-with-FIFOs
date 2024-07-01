package FIFO_rx_scoreboard_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;

    class FIFO_rx_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_rx_scoreboard)

        FIFO_seq_item sb_seq_item;
        uvm_analysis_export #(FIFO_seq_item) sb_exp;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;

        bit WE;
        bit [DBIT-1:0] din;
        logic [DBIT-1:0] MEM [FIFO_DEPTH];
        logic [FIFO_ADDR:0] rd_ptr, wr_ptr;
        logic [DBIT-1:0] dout_ref;
        logic full_ref, empty_ref;
        
        int correct, error;

        function new(string name = "FIFO_rx_scoreboard", uvm_component parent = null);
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

            forever begin
                sb_fifo.get(sb_seq_item);
                ref_model(sb_seq_item);

                if ((sb_seq_item.dout != dout_ref) || (sb_seq_item.full != full_ref) || (sb_seq_item.empty != empty_ref)) begin
                    `uvm_error("run_phase", $sformatf("Scoreboard - Comparison failed, Transaction received by the DUT: %0s, while the ref model out: dout_ref = %0d, full_ref = %0b, empty_ref = %0b",
                     sb_seq_item.convert2string(), dout_ref, full_ref, empty_ref))
                    error++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct FIFO out: %0s", sb_seq_item.convert2string()), UVM_HIGH)
                    correct++;
                end
            end
        endtask

        task ref_model(FIFO_seq_item chk_seq_item);
            // Write
            if (!sb_seq_item.rst_n) 
                wr_ptr = 0;
            else if (WE && (!full_ref)) begin
                MEM[wr_ptr[FIFO_ADDR-1:0]] = din;
                wr_ptr++;
            end

            // Read
            if (!sb_seq_item.rst_n) begin
                rd_ptr   = 0;
                dout_ref = 0;
            end
            else if (sb_seq_item.RE && (!empty_ref)) begin
                dout_ref = MEM[rd_ptr[FIFO_ADDR-1:0]];
                rd_ptr++;
            end

            // Flags
            full_ref  = ((wr_ptr[FIFO_ADDR-1:0] == rd_ptr[FIFO_ADDR-1:0]) && (wr_ptr[FIFO_ADDR] != rd_ptr[FIFO_ADDR]));
            empty_ref = (wr_ptr == rd_ptr);

            WE  = sb_seq_item.WE;
            din = sb_seq_item.din;
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct), UVM_LOW)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error), UVM_LOW)
        endfunction
    endclass
endpackage