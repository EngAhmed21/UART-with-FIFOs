package uart_tx_seq_item_pkg;
    import states_pkg::*;
    import sys_ref_pkg::*;
    import uart_tx_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_tx_seq_item extends uvm_sequence_item;
        `uvm_object_utils(uart_tx_seq_item)

        rand bit rst_n, s_tick, tx_start;
        rand bit [DBIT-1:0] tx_din;
        logic tx_done, tx;
        bit din_r;
        bit [$clog2(FINAL_VALUE+1)-1:0] tick_counter;

        constraint rst_c {rst_n == 1'b1;}
        constraint tx_start_c  {tx_start dist {1 := 98, 0 := 2};}
        constraint s_tick_c {s_tick == (tick_counter == (FINAL_VALUE-1));}

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

        function new (string name = "uart_tx_seq_item");
            super.new(name);
            din_r = 0;
            tick_counter = 'd0;
        endfunction

        function string convert2string_stim();
            convert2string_stim =  $sformatf("rst_n = %0b, s_tick = %0b, tx_start = %0b, tx_din = %0d", rst_n, s_tick,
             tx_start, tx_din);
        endfunction

        function string convert2string();
            convert2string = $sformatf("%s, rst_n = %0b, s_tick = %0b, tx_start = %0b, tx_din = %0d, tx_done = %0b, tx = %0b",
             super.convert2string(), rst_n, s_tick, tx_start, tx_din, tx_done, tx);
        endfunction
    endclass
endpackage