package uart_tx_monitor_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_seq_item_pkg::*;

    class uart_tx_monitor extends uvm_monitor;
        `uvm_component_utils(uart_tx_monitor)

        virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_tx_vif;
        uart_tx_seq_item rsp_seq_item;

        uvm_analysis_port #(uart_tx_seq_item) mon_ap;

        function new(string name = "uart_tx_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                rsp_seq_item = uart_tx_seq_item::type_id::create("rsp_seq_item");

                @(negedge uart_tx_vif.clk);
                rsp_seq_item.rst_n    = uart_tx_vif.rst_n;
                rsp_seq_item.s_tick   = uart_tx_vif.s_tick;
                rsp_seq_item.tx_start = uart_tx_vif.tx_start;
                rsp_seq_item.tx_din   = uart_tx_vif.tx_din;
                rsp_seq_item.tx_done  = uart_tx_vif.tx_done;
                rsp_seq_item.tx       = uart_tx_vif.tx;

                mon_ap.write(rsp_seq_item);

                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask
    endclass 
endpackage