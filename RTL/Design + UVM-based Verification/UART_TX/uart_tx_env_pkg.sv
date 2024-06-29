package uart_tx_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_agent_pkg::*;
    import uart_tx_scoreboard_pkg::*;
    import uart_tx_coverage_pkg::*;

    class uart_tx_env extends uvm_env;
        `uvm_component_utils(uart_tx_env)

        uart_tx_agent agt;
        uart_tx_scoreboard sb;
        uart_tx_coverage cov;

        function new(string name = "uart_tx_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agt = uart_tx_agent::type_id::create("agt", this);
            sb  = uart_tx_scoreboard::type_id::create("sb", this);
            cov = uart_tx_coverage::type_id::create("cov", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            agt.agt_ap.connect(sb.sb_exp);
            agt.agt_ap.connect(cov.cov_exp);
        endfunction
    endclass
endpackage