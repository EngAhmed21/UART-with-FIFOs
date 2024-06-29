package uart_rx_agent_pkg;
    import uart_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_rx_seq_item_pkg::*;
    import uart_rx_config_pkg::*;
    import uart_rx_driver_pkg::*;
    import uart_rx_sequencer_pkg::*;
    import uart_rx_monitor_pkg::*;

    class uart_rx_agent extends uvm_agent;
        `uvm_component_utils(uart_rx_agent)

        uart_rx_driver drv;
        uart_rx_monitor mon;
        uart_rx_sequencer sqr;
        
        uart_rx_config rx_config;

        uvm_analysis_port #(uart_rx_seq_item) agt_ap;

        function new(string name = "uart_rx_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!(uvm_config_db #(uart_rx_config)::get(this, "", "uart_rx_CFG", rx_config)))
                `uvm_fatal("build_phase", "Agent - Unable to get the uart_rx config_object from the uvm_config_db")

            drv = uart_rx_driver::type_id::create("drv", this);
            mon = uart_rx_monitor::type_id::create("mon", this);
            sqr = uart_rx_sequencer::type_id::create("sqr", this);

            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            drv.uart_rx_vif = rx_config.uart_rx_vif;
            mon.uart_rx_vif = rx_config.uart_rx_vif;

            drv.seq_item_port.connect(sqr.seq_item_export);

            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage