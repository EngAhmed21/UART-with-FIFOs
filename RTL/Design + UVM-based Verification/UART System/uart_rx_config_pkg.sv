package uart_rx_config_pkg;
import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_rx_config extends uvm_object;
        `uvm_object_utils(uart_rx_config)

        virtual uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)) uart_rx_vif;

        uvm_active_passive_enum active;

        function new(string name = "uart_rx_config");
            super.new(name);
        endfunction
    endclass
endpackage