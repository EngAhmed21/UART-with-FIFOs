package ref_pkg;
    import states_pkg::*;
    import param_pkg::*;

    state_e tx_cs, rx_cs;
    bit [SCNT_BIT-1:0] tx_s_cnt, rx_s_cnt;
    bit s_tick;
endpackage