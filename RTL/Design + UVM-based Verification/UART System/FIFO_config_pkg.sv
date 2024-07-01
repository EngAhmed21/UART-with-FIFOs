package FIFO_config_pkg;
import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_config extends uvm_object;
        `uvm_object_utils(FIFO_config)

        virtual FIFO_IF #(.WIDTH(DBIT), .DEPTH(FIFO_DEPTH)) FIFO_vif;

        uvm_active_passive_enum active;

        function new(string name = "FIFO_config");
            super.new(name);
        endfunction
    endclass
endpackage