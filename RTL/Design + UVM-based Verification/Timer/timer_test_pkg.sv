package timer_test_pkg;
    import timer_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_env_pkg::*;
    import timer_sequence_pkg::*;
    import timer_config_pkg::*;

    class timer_test extends uvm_test;
        `uvm_component_utils(timer_test)

        timer_env env;
        timer_config t_config;
        timer_main_sequence main_seq;
        timer_rst_sequence rst_seq;

        function new(string name = "timer_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            env = timer_env::type_id::create("env", this);
            main_seq = timer_main_sequence::type_id::create("main_seq");
            rst_seq = timer_rst_sequence::type_id::create("rst_seq");
            t_config = timer_config::type_id::create("t_config");

            if (!(uvm_config_db #(virtual timer_IF #(FINAL_VALUE).TEST)::get(this, "", "VIF", t_config.timer_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the Timer from uvm_config_db")
            
            uvm_config_db #(timer_config)::set(this, "*", "TIMER_CFG", t_config); 
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            phase.raise_objection(this);

            `uvm_info("run_phase", "Reset asserted", UVM_LOW)
            rst_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Reset de-asserted", UVM_LOW)

            `uvm_info("run_phase", "Stimulus generation started", UVM_LOW)
            main_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Stimulus generation ended", UVM_LOW)

            phase.drop_objection(this);
        endtask
    endclass
endpackage
