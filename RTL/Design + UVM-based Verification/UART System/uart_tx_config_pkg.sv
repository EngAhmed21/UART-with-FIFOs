package uart_tx_config_pkg;
import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_tx_config extends uvm_object;
        `uvm_object_utils(uart_tx_config)

        virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_tx_vif;

        uvm_active_passive_enum active;

        function new(string name = "uart_tx_config");
            super.new(name);
        endfunction
    endclass
endpackage