package uart_sys_coverage_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;
    import uart_sys_shared_pkg::*;

    class uart_sys_coverage extends uvm_component;
        `uvm_component_utils(uart_sys_coverage)

        uart_sys_seq_item cov_seq_item;
        uvm_analysis_export #(uart_sys_seq_item) cov_exp;
        uvm_tlm_analysis_fifo #(uart_sys_seq_item) cov_fifo;

        covergroup cvGrp; 
            option.auto_bin_max = 256;

            tx_full_cp:  coverpoint cov_seq_item.tx_full  iff (cov_seq_item.rst_n);
            rx_empty_cp: coverpoint cov_seq_item.rx_empty iff (cov_seq_item.rst_n);
        endgroup

        function new(string name = "uart_sys_coverage", uvm_component parent = null);
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