package timer_coverage_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;

    class timer_coverage extends uvm_component;
        `uvm_component_utils(timer_coverage)

        timer_seq_item cov_seq_item;
        uvm_analysis_export #(timer_seq_item) cov_exp;
        uvm_tlm_analysis_fifo #(timer_seq_item) cov_fifo;

        covergroup cvGrp;
            timer_done_cp: coverpoint cov_seq_item.done iff (cov_seq_item.rst_n) {
                bins timer_done = {1};
            }
        endgroup

        function new(string name = "timer_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvGrp = new;
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            cov_exp  = new("cov_exp", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            cov_exp.connect(cov_fifo.analysis_export);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                cov_fifo.get(cov_seq_item);

                cvGrp.sample();
            end
        endtask
    endclass
endpackage