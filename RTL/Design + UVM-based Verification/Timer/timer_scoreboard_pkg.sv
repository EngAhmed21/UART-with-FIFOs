package timer_scoreboard_pkg;
    import timer_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;

    class timer_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(timer_scoreboard)

        timer_seq_item sb_seq_item;
        uvm_analysis_export #(timer_seq_item) sb_exp;
        uvm_tlm_analysis_fifo #(timer_seq_item) sb_fifo;

        logic done_ref;
        int correct, error;

        function new(string name = "timer_scoreboard", uvm_component parent = null);
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

                if (sb_seq_item.done != done_ref) begin
                    `uvm_error("run_phase", $sformatf("Scoreboard - Comparison failed, Transaction received by the DUT: %0s, while the ref model out: done_ref = %0b",
                     sb_seq_item.convert2string(), done_ref))
                    error++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct Timer out: %0s", sb_seq_item.convert2string()), UVM_HIGH)
                    correct++;
                end
            end
        endtask

        task ref_model(timer_seq_item chk_seq_item);
            logic [$clog2(FINAL_VALUE+1)-1:0] Q_ref;

            if ((!sb_seq_item.rst_n) || done_ref)
                Q_ref = 0;
            else if (sb_seq_item.en)
                Q_ref++;

            done_ref = (Q_ref == FINAL_VALUE);
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct), UVM_LOW)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error), UVM_LOW)
        endfunction
    endclass
endpackage