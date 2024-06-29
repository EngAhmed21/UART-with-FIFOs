package uart_tx_test_pkg;
    import uart_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_env_pkg::*;
    import uart_tx_sequence_pkg::*;
    import uart_tx_config_pkg::*;

    class uart_tx_test extends uvm_test;
        `uvm_component_utils(uart_tx_test)

        uart_tx_env env;
        uart_tx_config tx_config;
        uart_tx_main_sequence main_seq;
        uart_tx_rst_sequence rst_seq;

        function new(string name = "uart_tx_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            env       = uart_tx_env::type_id::create("env", this);
            main_seq  = uart_tx_main_sequence::type_id::create("main_seq");
            rst_seq   = uart_tx_rst_sequence::type_id::create("rst_seq");
            tx_config = uart_tx_config::type_id::create("tx_config");

            if (!(uvm_config_db #(virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)))::get(this, "", "VIF", tx_config.uart_tx_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the uart_tx from uvm_config_db")
            
            uvm_config_db #(uart_tx_config)::set(this, "*", "uart_tx_CFG", tx_config); 
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