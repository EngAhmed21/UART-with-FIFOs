package FIFO_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_rx_agent_pkg::*;
    import FIFO_tx_agent_pkg::*;
    import FIFO_rx_scoreboard_pkg::*;
    import FIFO_tx_scoreboard_pkg::*;
    import FIFO_rx_coverage_pkg::*;
    import FIFO_tx_coverage_pkg::*;

    class FIFO_env extends uvm_env;
        `uvm_component_utils(FIFO_env)

        FIFO_rx_agent rx_agt;
        FIFO_tx_agent tx_agt;
        FIFO_rx_scoreboard rx_sb;
        FIFO_tx_scoreboard tx_sb;
        FIFO_rx_coverage rx_cov;
        FIFO_tx_coverage tx_cov;

        function new(string name = "FIFO_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            rx_agt = FIFO_rx_agent::type_id::create("rx_agt", this);
            tx_agt = FIFO_tx_agent::type_id::create("tx_agt", this);
            rx_sb  = FIFO_rx_scoreboard::type_id::create("rx_sb", this);
            tx_sb  = FIFO_tx_scoreboard::type_id::create("tx_sb", this);
            rx_cov = FIFO_rx_coverage::type_id::create("rx_cov", this);
            tx_cov = FIFO_tx_coverage::type_id::create("tx_cov", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            rx_agt.agt_ap.connect(rx_sb.sb_exp);
            rx_agt.agt_ap.connect(rx_cov.cov_exp);

            tx_agt.agt_ap.connect(tx_sb.sb_exp);
            tx_agt.agt_ap.connect(tx_cov.cov_exp);
        endfunction
    endclass
endpackage