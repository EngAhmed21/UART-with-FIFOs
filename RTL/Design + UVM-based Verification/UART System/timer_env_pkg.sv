package timer_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_agent_pkg::*;
    import timer_scoreboard_pkg::*;
    import timer_coverage_pkg::*;

    class timer_env extends uvm_env;
        `uvm_component_utils(timer_env)

        timer_agent agt;
        timer_scoreboard sb;
        timer_coverage cov;

        function new(string name = "timer_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agt = timer_agent::type_id::create("agt", this);
            sb  = timer_scoreboard::type_id::create("sb", this);
            cov = timer_coverage::type_id::create("cov", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            agt.agt_ap.connect(sb.sb_exp);
            agt.agt_ap.connect(cov.cov_exp);
        endfunction
    endclass
endpackage