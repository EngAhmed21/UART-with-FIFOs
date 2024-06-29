package FIFO_agent_pkg;
    import FIFO_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;
    import FIFO_config_pkg::*;
    import FIFO_driver_pkg::*;
    import FIFO_sequencer_pkg::*;
    import FIFO_monitor_pkg::*;

    class FIFO_agent extends uvm_agent;
        `uvm_component_utils(FIFO_agent)

        FIFO_driver drv;
        FIFO_monitor mon;
        FIFO_sequencer sqr;
        
        FIFO_config F_config;

        uvm_analysis_port #(FIFO_seq_item) agt_ap;

        function new(string name = "FIFO_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!(uvm_config_db #(FIFO_config)::get(this, "", "FIFO_CFG", F_config)))
                `uvm_fatal("build_phase", "Agent - Unable to get the FIFO config_object from the uvm_config_db")

            drv = FIFO_driver::type_id::create("drv", this);
            mon = FIFO_monitor::type_id::create("mon", this);
            sqr = FIFO_sequencer::type_id::create("sqr", this);

            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            drv.FIFO_vif = F_config.FIFO_vif;
            mon.FIFO_vif = F_config.FIFO_vif;

            drv.seq_item_port.connect(sqr.seq_item_export);

            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage