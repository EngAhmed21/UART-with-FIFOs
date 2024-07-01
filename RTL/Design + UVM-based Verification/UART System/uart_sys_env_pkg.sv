package uart_sys_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_agent_pkg::*;
    import uart_sys_scoreboard_pkg::*;
    import uart_sys_coverage_pkg::*;

    class uart_sys_env extends uvm_env;
        `uvm_component_utils(uart_sys_env)

        uart_sys_agent agt;
        uart_sys_scoreboard sb;
        uart_sys_coverage cov;

        function new(string name = "uart_sys_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agt = uart_sys_agent::type_id::create("agt", this);
            sb  = uart_sys_scoreboard::type_id::create("sb", this);
            cov = uart_sys_coverage::type_id::create("cov", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            agt.agt_ap.connect(sb.sb_exp);
            agt.agt_ap.connect(cov.cov_exp);
        endfunction
    endclass
endpackage