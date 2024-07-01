package timer_sequencer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;

    class timer_sequencer extends uvm_sequencer #(timer_seq_item);
        `uvm_component_utils(timer_sequencer)

        function new(string name = "timer_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage