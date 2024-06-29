package timer_config_pkg;
import timer_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class timer_config extends uvm_object;
        `uvm_object_utils(timer_config)

        virtual timer_IF #(FINAL_VALUE) timer_vif;

        function new(string name = "timer_config");
            super.new(name);
        endfunction
    endclass
endpackage