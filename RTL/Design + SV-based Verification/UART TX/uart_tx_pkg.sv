package uart_tx_pkg;
    import states_pkg::*;
    import param_pkg::*;
    import ref_pkg::*;

    class uart_rx_rc;
        rand bit rst_n, s_tick, tx_start;
        rand bit [DBIT-1:0] tx_din;
        bit tx_done, din_r;
        bit [$clog2(RATE)-1:0] tick_counter;

        constraint rst_c {rst_n == 1'b1;}
        constraint tx_start_c  {tx_start dist {1 := 98, 0 := 2};}
        constraint s_tick_c {s_tick == (tick_counter == (RATE-1));}

        covergroup cvGrp; 
            tx_done_cp: coverpoint tx_done iff (rst_n) {
                bins tx_done_bin = {1};
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

            // din
            if (cs_ref == IDLE) begin
                tx_start.rand_mode(1);
                if(~din_r)
                    tx_din.rand_mode(1);
                else
                    tx_din.rand_mode(0);
            end
            else begin
                tx_start.rand_mode(0);
                tx_din.rand_mode(0);
            end

            // din_r
            din_r = (cs_ref == IDLE);
        endfunction
    

        function new();
            cvGrp = new;
            din_r = 0;
            tick_counter = 'd0;
        endfunction //new()
    endclass //uart_tx_rc
endpackage