package uart_rx_pkg;
    import states_pkg::*;
    import param_pkg::*;
    import ref_pkg::*;

    class uart_rx_rc;
        rand bit rst_n, s_tick, rx;
        bit rx_done;
        bit [$clog2(RATE)-1:0] tick_counter;

        constraint rst_c {rst_n == 1'b1;}
        constraint rx_c  {
            if (cs_ref == START)
                rx dist {0 := 90, 1 := 10};
            else
                rx dist {0 := 40, 1 := 60};
        }
        constraint s_tick_c {s_tick == (tick_counter == (RATE-1));}

        covergroup cvGrp; 
            rx_done_cp: coverpoint rx_done iff (rst_n) {
                bins rx_done_bin = {1};
            } 
        endgroup

        function void pre_randomize();
            // tick_counter
            if (!rst_n)
                tick_counter = 'd0;
            else if (s_tick)
                tick_counter = 'd0;
            else 
                tick_counter++;

            // rx
            if ((tick_counter != (RATE-1)) || (cs_ref == STOP) || ((cs_ref == DATA) && (s_cnt_ref != (BIT_WIDTH-1))))
                rx.rand_mode(0);
            else
                rx.rand_mode(1);
        endfunction
    

        function new();
            cvGrp = new;
            tick_counter = 'd0;
        endfunction //new()
    endclass //uart_rx_rc
endpackage