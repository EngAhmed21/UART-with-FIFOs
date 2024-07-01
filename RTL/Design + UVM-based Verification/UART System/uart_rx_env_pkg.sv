package uart_rx_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_rx_agent_pkg::*;
    import uart_rx_scoreboard_pkg::*;
    import uart_rx_coverage_pkg::*;

    class uart_rx_env extends uvm_env;
        `uvm_component_utils(uart_rx_env)

        uart_rx_agent agt;
        uart_rx_scoreboard sb;
        uart_rx_coverage cov;

        function new(string name = "uart_rx_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agt = uart_rx_agent::type_id::create("agt", this);
            sb  = uart_rx_scoreboard::type_id::create("sb", this);
            cov = uart_rx_coverage::type_id::create("cov", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            agt.agt_ap.connect(sb.sb_exp);
            agt.agt_ap.connect(cov.cov_exp);
        endfunction
    endclass
endpackage