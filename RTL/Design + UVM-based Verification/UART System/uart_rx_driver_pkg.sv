package uart_rx_driver_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_rx_seq_item_pkg::*;

    class uart_rx_driver extends uvm_driver #(uart_rx_seq_item);
        `uvm_component_utils(uart_rx_driver)

        virtual uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_rx_vif;
        uart_rx_seq_item stim_seq_item;

        function new(string name = "uart_rx_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                stim_seq_item = uart_rx_seq_item::type_id::create("stim_seq_item");

                seq_item_port.get_next_item(stim_seq_item);

                uart_rx_vif.rst_n  = stim_seq_item.rst_n;
                uart_rx_vif.s_tick = stim_seq_item.s_tick;
                uart_rx_vif.rx     = stim_seq_item.rx;

                @(negedge uart_rx_vif.clk);
                seq_item_port.item_done();

                `uvm_info("run_phase", stim_seq_item.convert2string_stim(), UVM_HIGH)
            end
        endtask
    endclass
endpackage