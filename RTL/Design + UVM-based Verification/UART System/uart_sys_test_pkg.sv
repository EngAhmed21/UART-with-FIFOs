package uart_sys_test_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_env_pkg::*;
    import timer_config_pkg::*;
    import FIFO_env_pkg::*;
    import FIFO_config_pkg::*;
    import uart_rx_env_pkg::*;
    import uart_rx_config_pkg::*;
    import uart_tx_env_pkg::*;
    import uart_tx_config_pkg::*;
    import uart_sys_env_pkg::*;
    import uart_sys_sequence_pkg::*;
    import uart_sys_config_pkg::*;

    class uart_sys_test extends uvm_test;
        `uvm_component_utils(uart_sys_test)

        timer_env timer_env_i;
        timer_config timer_config_i;
        FIFO_env fifo_env_i;
        FIFO_config fifo_rx_config, fifo_tx_config;
        uart_rx_env rx_env_i;
        uart_rx_config rx_config_i;
        uart_tx_env tx_env_i;
        uart_tx_config tx_config_i;
        uart_sys_env sys_env_i;
        uart_sys_config sys_config_i;
        uart_sys_main_sequence main_seq;
        uart_sys_rst_sequence rst_seq;
        uart_sys_full_sequence full_seq;

        function new(string name = "uart_sys_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            timer_env_i = timer_env::type_id::create("timer_env_i", this);
            fifo_env_i = FIFO_env::type_id::create("fifo_env_i", this);
            rx_env_i    = uart_rx_env::type_id::create("rx_env_i", this);
            tx_env_i    = uart_tx_env::type_id::create("tx_env_i", this);
            sys_env_i   = uart_sys_env::type_id::create("sys_env_i", this);

            timer_config_i = timer_config::type_id::create("timer_config_i");
            fifo_rx_config = FIFO_config::type_id::create("fifo_rx_config");
            fifo_tx_config = FIFO_config::type_id::create("fifo_tx_config");
            rx_config_i    = uart_rx_config::type_id::create("rx_config_i");
            tx_config_i    = uart_tx_config::type_id::create("tx_config_i");
            sys_config_i   = uart_sys_config::type_id::create("sys_config_i");

            main_seq  = uart_sys_main_sequence::type_id::create("main_seq");
            rst_seq   = uart_sys_rst_sequence::type_id::create("rst_seq");
            full_seq  = uart_sys_full_sequence::type_id::create("full_seq");
            

            if (!(uvm_config_db #(virtual timer_IF #(FINAL_VALUE).TEST)::get(this, "", "TIMER_IF", timer_config_i.timer_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the timer from uvm_config_db")
            timer_config_i.active = UVM_PASSIVE;
            uvm_config_db #(timer_config)::set(this, "*", "TIMER_CFG", timer_config_i); 

            if (!(uvm_config_db #(virtual FIFO_IF #(.WIDTH(DBIT), .DEPTH(FIFO_DEPTH)).TEST)::get(this, "", "FIFO_RX_IF", fifo_rx_config.FIFO_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the RX FIFO from uvm_config_db")
            fifo_rx_config.active = UVM_PASSIVE;
            uvm_config_db #(FIFO_config)::set(this, "*", "FIFO_RX_CFG", fifo_rx_config); 

             if (!(uvm_config_db #(virtual FIFO_IF #(.WIDTH(DBIT), .DEPTH(FIFO_DEPTH)).TEST)::get(this, "", "FIFO_TX_IF", fifo_tx_config.FIFO_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the TX FIFO from uvm_config_db")
            fifo_tx_config.active = UVM_PASSIVE;
            uvm_config_db #(FIFO_config)::set(this, "*", "FIFO_TX_CFG", fifo_tx_config); 

            if (!(uvm_config_db #(virtual uart_rx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)).TEST)::get(this, "", "UART_RX_IF", rx_config_i.uart_rx_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the UART RX from uvm_config_db")
            rx_config_i.active = UVM_PASSIVE;
            uvm_config_db #(uart_rx_config)::set(this, "*", "UART_RX_CFG", rx_config_i); 

            if (!(uvm_config_db #(virtual uart_tx_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH)).TEST)::get(this, "", "UART_TX_IF", tx_config_i.uart_tx_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the UART TX from uvm_config_db")
            tx_config_i.active = UVM_PASSIVE;
            uvm_config_db #(uart_tx_config)::set(this, "*", "UART_TX_CFG", tx_config_i); 

            if (!(uvm_config_db #(virtual uart_sys_IF #(.DBIT(DBIT), .SB_TICK(SB_TICK), .BIT_WIDTH(BIT_WIDTH), .FINAL_VALUE(FINAL_VALUE), .FIFO_DEPTH(FIFO_DEPTH)).TEST)::get(this, "", "SYS_IF", sys_config_i.uart_sys_vif)))
                `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the timer from uvm_config_db")
            uvm_config_db #(uart_sys_config)::set(this, "*", "UART_SYS_CFG", sys_config_i); 
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            phase.raise_objection(this);

            `uvm_info("run_phase", "Reset asserted", UVM_LOW)
            rst_seq.start(sys_env_i.agt.sqr);
            `uvm_info("run_phase", "Reset de-asserted", UVM_LOW)

            `uvm_info("run_phase", "Stimulus generation started", UVM_LOW)
            main_seq.start(sys_env_i.agt.sqr);
            `uvm_info("run_phase", "Stimulus generation ended", UVM_LOW)

            `uvm_info("run_phase", "Full Sequence started", UVM_LOW)
            full_seq.start(sys_env_i.agt.sqr);
            `uvm_info("run_phase", "Full Sequence ended", UVM_LOW)


            phase.drop_objection(this);
        endtask
    endclass
endpackage
