package timer_seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class timer_seq_item extends uvm_sequence_item;
        `uvm_object_utils(timer_seq_item)

        rand bit rst_n, en;
        bit done;

        constraint rst_c {rst_n dist {0 := 1,  1 := 99};}
        constraint en_c  {en    dist {0 := 10, 1 := 90};}

        function new (string name = "timer_seq_item");
            super.new(name);
        endfunction

        function string convert2string_stim();
            convert2string_stim =  $sformatf("rst_n = %0b, en = %0b", rst_n, en);
        endfunction

        function string convert2string();
            convert2string = $sformatf("%s, rst_n = %0b, en = %0b, done = %0b", super.convert2string(), rst_n, en, done);
        endfunction
    endclass
endpackage