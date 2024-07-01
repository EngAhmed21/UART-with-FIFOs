package uart_sys_shared_pkg;
    import states_pkg::*;
    import sys_ref_pkg::*;

    state_e tx_cs, rx_cs;
    bit [SCNT_BIT-1:0] tx_s_cnt, rx_s_cnt;
    logic s_tick;
endpackage