package FIFO_coverage_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;

    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)

        FIFO_seq_item cov_seq_item;
        uvm_analysis_export #(FIFO_seq_item) cov_exp;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;

        covergroup cvGrp;
            option.auto_bin_max = (2**DBIT)-1;

            WE_cp:    coverpoint cov_seq_item.WE    iff (cov_seq_item.rst_n);
            RE_cp:    coverpoint cov_seq_item.RE    iff (cov_seq_item.rst_n);
            din_cp:   coverpoint cov_seq_item.din   iff (cov_seq_item.rst_n && cov_seq_item.WE);
            dout_cp:  coverpoint cov_seq_item.dout  iff (cov_seq_item.rst_n && cov_seq_item.RE);
            full_cp:  coverpoint cov_seq_item.full  iff (cov_seq_item.rst_n) {bins full_bin  = {1};}
            empty_cp: coverpoint cov_seq_item.empty iff (cov_seq_item.rst_n) {bins empty_bin = {1};}
        endgroup

        function new(string name = "FIFO_coverage", uvm_component parent = null);
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