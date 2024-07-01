package timer_agent_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;
    import timer_config_pkg::*;
    import timer_driver_pkg::*;
    import timer_sequencer_pkg::*;
    import timer_monitor_pkg::*;

    class timer_agent extends uvm_agent;
        `uvm_component_utils(timer_agent)

        timer_driver drv;
        timer_monitor mon;
        timer_sequencer sqr;
        
        timer_config t_config;

        uvm_analysis_port #(timer_seq_item) agt_ap;

        function new(string name = "timer_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!(uvm_config_db #(timer_config)::get(this, "", "TIMER_CFG", t_config)))
                `uvm_fatal("build_phase", "Agent - Unable to get the Timer config_object from the uvm_config_db")

            if (t_config.active == UVM_ACTIVE) begin
                drv = timer_driver::type_id::create("drv", this);
                
                sqr = timer_sequencer::type_id::create("sqr", this);
            end
            mon = timer_monitor::type_id::create("mon", this);

            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            if (t_config.active == UVM_ACTIVE) begin
                drv.timer_vif = t_config.timer_vif;
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
            
            mon.timer_vif = t_config.timer_vif;
            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage