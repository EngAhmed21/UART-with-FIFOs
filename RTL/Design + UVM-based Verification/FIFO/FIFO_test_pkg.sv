package FIFO_test_pkg;
    import FIFO_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_env_pkg::*;
    import FIFO_sequence_pkg::*;
    import FIFO_config_pkg::*;

    class FIFO_test extends uvm_test;
        `uvm_component_utils(FIFO_test)

        FIFO_env env;
        FIFO_config F_config;
        FIFO_main_sequence main_seq;
        FIFO_rst_sequence rst_seq;
        FIFO_full_sequence full_seq;

        function new(string name = "FIFO_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            env      = FIFO_env::type_id::create("env", this);
            main_seq = FIFO_main_sequence::type_id::create("main_seq");
            full_seq = FIFO_full_sequence::type_id::create("full_seq");
            rst_seq  = FIFO_rst_sequence::type_id::create("rst_seq");
            F_config = FIFO_config::type_id::create("F_config");

            if (!(uvm_config_db #(virtual FIFO_IF #(.WIDTH(WIDTH), .DEPTH(DEPTH)).TEST)::get(this, "", "VIF", F_config.FIFO_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the FIFO from uvm_config_db")
            
            uvm_config_db #(FIFO_config)::set(this, "*", "FIFO_CFG", F_config); 
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

            `uvm_info("run_phase", "Full FIFO sequence started", UVM_LOW)
            full_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Full FIFO sequence ended", UVM_LOW)

            phase.drop_objection(this);
        endtask
    endclass
endpackage
