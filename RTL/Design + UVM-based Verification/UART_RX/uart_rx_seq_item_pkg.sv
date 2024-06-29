package uart_rx_seq_item_pkg;
    import states_pkg::*;
    import uart_ref_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_rx_seq_item extends uvm_sequence_item;
        `uvm_object_utils(uart_rx_seq_item)

        rand bit rst_n, s_tick, rx;
        logic rx_done;
        logic [DBIT-1:0] rx_dout;
        bit [$clog2(RATE)-1:0] tick_counter;

        constraint rst_c {rst_n == 1;}
        constraint rx_c  {
            if (cs_ref == START)
                rx dist {0 := 90, 1 := 10};
            else
                rx dist {0 := 40, 1 := 60};
        }
        constraint s_tick_c {s_tick == (tick_counter == (RATE-1));}

        function void pre_randomize();
            // tick_counter
            if ((!rst_n) || s_tick)
                tick_counter = 'd0;
            else 
                tick_counter++;

            // rx
            if ((tick_counter != (RATE-1)) || (cs_ref == STOP) || ((cs_ref == DATA) && (s_cnt_ref != (BIT_WIDTH-1))))
                rx.rand_mode(0);
            else
                rx.rand_mode(1);
        endfunction

        function new (string name = "uart_rx_seq_item");
            super.new(name);
            tick_counter = 'd0;
        endfunction

        function string convert2string_stim();
            convert2string_stim =  $sformatf("rst_n = %0b, s_tick = %0b, rx = %0b", rst_n, s_tick, rx);
        endfunction

        function string convert2string();
            convert2string = $sformatf("%s, rst_n = %0b, s_tick = %0b, rx = %0b, rx_done = %0b, rx_dout = %0d",
             super.convert2string(), rst_n, s_tick, rx, rx_done, rx_dout);
        endfunction
    endclass
endpackage