package uart_tx_coverage_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_seq_item_pkg::*;

    class uart_tx_coverage extends uvm_component;
        `uvm_component_utils(uart_tx_coverage)

        uart_tx_seq_item cov_seq_item;
        uvm_analysis_export #(uart_tx_seq_item) cov_exp;
        uvm_tlm_analysis_fifo #(uart_tx_seq_item) cov_fifo;

        covergroup cvGrp; 
            tx_done_cp: coverpoint cov_seq_item.tx_done iff (cov_seq_item.rst_n) {
                bins tx_done_bin = {1};
            } 
        endgroup

        function new(string name = "uart_tx_coverage", uvm_component parent = null);
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