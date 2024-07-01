package uart_sys_agent_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;
    import uart_sys_config_pkg::*;
    import uart_sys_driver_pkg::*;
    import uart_sys_sequencer_pkg::*;
    import uart_sys_monitor_pkg::*;

    class uart_sys_agent extends uvm_agent;
        `uvm_component_utils(uart_sys_agent)

        uart_sys_driver drv;
        uart_sys_monitor mon;
        uart_sys_sequencer sqr;
        
        uart_sys_config sys_config;

        uvm_analysis_port #(uart_sys_seq_item) agt_ap;

        function new(string name = "uart_sys_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!(uvm_config_db #(uart_sys_config)::get(this, "", "UART_SYS_CFG", sys_config)))
                `uvm_fatal("build_phase", "Agent - Unable to get the uart_sys config_object from the uvm_config_db")

            drv = uart_sys_driver::type_id::create("drv", this);
            mon = uart_sys_monitor::type_id::create("mon", this);
            sqr = uart_sys_sequencer::type_id::create("sqr", this);

            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            drv.uart_sys_vif = sys_config.uart_sys_vif;
            mon.uart_sys_vif = sys_config.uart_sys_vif;

            drv.seq_item_port.connect(sqr.seq_item_export);

            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage