package timer_monitor_pkg;
    import timer_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;

    class timer_monitor extends uvm_monitor;
        `uvm_component_utils(timer_monitor)

        virtual timer_IF #(FINAL_VALUE) timer_vif;
        timer_seq_item rsp_seq_item;

        uvm_analysis_port #(timer_seq_item) mon_ap;

        function new(string name = "timer_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                rsp_seq_item = timer_seq_item::type_id::create("rsp_seq_item");

                @(negedge timer_vif.clk);
                rsp_seq_item.rst_n = timer_vif.rst_n;
                rsp_seq_item.en    = timer_vif.en;
                rsp_seq_item.done  = timer_vif.done;

                mon_ap.write(rsp_seq_item);

                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask
    endclass 
endpackage