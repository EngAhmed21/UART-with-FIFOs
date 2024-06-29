package uart_tx_driver_pkg;
    import uart_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_seq_item_pkg::*;

    class uart_tx_driver extends uvm_driver #(uart_tx_seq_item);
        `uvm_component_utils(uart_tx_driver)

        virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_tx_vif;
        uart_tx_seq_item stim_seq_item;

        function new(string name = "uart_tx_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                stim_seq_item = uart_tx_seq_item::type_id::create("stim_seq_item");

                seq_item_port.get_next_item(stim_seq_item);

                uart_tx_vif.rst_n    = stim_seq_item.rst_n;
                uart_tx_vif.s_tick   = stim_seq_item.s_tick;
                uart_tx_vif.tx_start = stim_seq_item.tx_start;
                uart_tx_vif.tx_din   = stim_seq_item.tx_din;

                @(negedge uart_tx_vif.clk);
                seq_item_port.item_done();

                `uvm_info("run_phase", stim_seq_item.convert2string_stim(), UVM_HIGH)
            end
        endtask
    endclass
endpackage