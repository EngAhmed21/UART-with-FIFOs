package uart_sys_config_pkg;
import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_sys_config extends uvm_object;
        `uvm_object_utils(uart_sys_config)

        virtual uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)) uart_sys_vif;

        function new(string name = "uart_sys_config");
            super.new(name);
        endfunction
    endclass
endpackage