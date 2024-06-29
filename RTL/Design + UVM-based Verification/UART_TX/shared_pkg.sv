// This package is shared between seq_item and scoreboard 

package shared_pkg;
    import states_pkg::*;
    import uart_ref_pkg::*;

    state_e cs_ref;
    bit [SCNT_BIT-1:0] s_cnt_ref;
endpackage