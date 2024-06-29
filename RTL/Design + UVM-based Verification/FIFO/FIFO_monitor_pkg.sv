package FIFO_monitor_pkg;
    import FIFO_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;

    class FIFO_monitor extends uvm_monitor;
        `uvm_component_utils(FIFO_monitor)

        virtual FIFO_IF #(.WIDTH(WIDTH), .DEPTH(DEPTH)) FIFO_vif;
        FIFO_seq_item rsp_seq_item;

        uvm_analysis_port #(FIFO_seq_item) mon_ap;

        function new(string name = "FIFO_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                rsp_seq_item = FIFO_seq_item::type_id::create("rsp_seq_item");

                @(negedge FIFO_vif.clk);
                rsp_seq_item.rst_n = FIFO_vif.rst_n;
                rsp_seq_item.WE    = FIFO_vif.WE;
                rsp_seq_item.RE    = FIFO_vif.RE;
                rsp_seq_item.din   = FIFO_vif.din;
                rsp_seq_item.full  = FIFO_vif.full;
                rsp_seq_item.empty = FIFO_vif.empty;
                rsp_seq_item.dout  = FIFO_vif.dout;

                mon_ap.write(rsp_seq_item);

                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask
    endclass 
endpackage