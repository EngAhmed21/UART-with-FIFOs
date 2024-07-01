package uart_tx_sequencer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_seq_item_pkg::*;

    class uart_tx_sequencer extends uvm_sequencer #(uart_tx_seq_item);
        `uvm_component_utils(uart_tx_sequencer)

        function new(string name = "uart_tx_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage