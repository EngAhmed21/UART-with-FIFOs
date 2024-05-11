package param_pkg;
    localparam BIT_WIDTH   = 4;
    localparam DBIT        = 8;
    localparam SB_TICK     = 4;
    localparam FINAL_VALUE = 3;
    localparam FIFO_DEPTH  = 16;
    localparam SCNT_BIT = (SB_TICK > BIT_WIDTH) ? $clog2(SB_TICK) : $clog2(BIT_WIDTH);
endpackage