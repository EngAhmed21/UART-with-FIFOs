package uart_rx_sequencer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_rx_seq_item_pkg::*;

    class uart_rx_sequencer extends uvm_sequencer #(uart_rx_seq_item);
        `uvm_component_utils(uart_rx_sequencer)

        function new(string name = "uart_rx_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage