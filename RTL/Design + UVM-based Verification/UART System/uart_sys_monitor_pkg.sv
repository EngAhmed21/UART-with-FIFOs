package uart_sys_monitor_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;

    class uart_sys_monitor extends uvm_monitor;
        `uvm_component_utils(uart_sys_monitor)

        virtual uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)) uart_sys_vif;
        uart_sys_seq_item rsp_seq_item;

        uvm_analysis_port #(uart_sys_seq_item) mon_ap;

        function new(string name = "uart_sys_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                rsp_seq_item = uart_sys_seq_item::type_id::create("rsp_seq_item");

                @(negedge uart_sys_vif.clk);
                rsp_seq_item.rst_n    = uart_sys_vif.rst_n;
                rsp_seq_item.rx       = uart_sys_vif.rx;
                rsp_seq_item.rd_uart  = uart_sys_vif.rd_uart;
                rsp_seq_item.wr_uart  = uart_sys_vif.wr_uart;
                rsp_seq_item.w_data   = uart_sys_vif.w_data;
                rsp_seq_item.tx       = uart_sys_vif.tx;
                rsp_seq_item.tx_full  = uart_sys_vif.tx_full;
                rsp_seq_item.rx_empty = uart_sys_vif.rx_empty;
                rsp_seq_item.r_data   = uart_sys_vif.r_data;

                mon_ap.write(rsp_seq_item);

                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask
    endclass 
endpackage