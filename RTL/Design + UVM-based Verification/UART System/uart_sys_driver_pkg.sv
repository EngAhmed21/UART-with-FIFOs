package uart_sys_driver_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;

    class uart_sys_driver extends uvm_driver #(uart_sys_seq_item);
        `uvm_component_utils(uart_sys_driver)

        virtual uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)) uart_sys_vif;
        uart_sys_seq_item stim_seq_item;

        function new(string name = "uart_sys_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                stim_seq_item = uart_sys_seq_item::type_id::create("stim_seq_item");

                seq_item_port.get_next_item(stim_seq_item);

                uart_sys_vif.rst_n   = stim_seq_item.rst_n;
                uart_sys_vif.rx      = stim_seq_item.rx;
                uart_sys_vif.rd_uart = stim_seq_item.rd_uart;
                uart_sys_vif.wr_uart = stim_seq_item.wr_uart;
                uart_sys_vif.w_data  = stim_seq_item.w_data;

                @(negedge uart_sys_vif.clk);
                seq_item_port.item_done();

                `uvm_info("run_phase", stim_seq_item.convert2string_stim(), UVM_HIGH)
            end
        endtask
    endclass
endpackage