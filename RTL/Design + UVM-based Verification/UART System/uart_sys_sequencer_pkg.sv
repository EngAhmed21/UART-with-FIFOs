package uart_sys_sequencer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;

    class uart_sys_sequencer extends uvm_sequencer #(uart_sys_seq_item);
        `uvm_component_utils(uart_sys_sequencer)

        function new(string name = "uart_sys_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage