package FIFO_seq_item_pkg;
    import sys_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_seq_item extends uvm_sequence_item;
        `uvm_object_utils(FIFO_seq_item)

        rand bit rst_n, WE, RE;
        rand bit [DBIT-1:0] din;
        logic full, empty;
        logic [DBIT-1:0] dout;

        constraint rst_c {rst_n dist {0 := 1,  1 := 99};}
        constraint WE_c  {WE    dist {0 := 30, 1 := 70};} 
        constraint RE_c  {RE    dist {0 := 30, 1 := 70};} 
        constraint din_c {($countones(din) > (DBIT/3));}

        function new (string name = "FIFO_seq_item");
            super.new(name);
        endfunction

        function string convert2string_stim();
            convert2string_stim =  $sformatf("rst_n = %0b, WE = %0b, RE = %0b, din = %0d", rst_n, WE, RE, din);
        endfunction

        function string convert2string();
            convert2string = $sformatf("%s, rst_n = %0b, WE = %0b, RE = %0b, din = %0d, full = %0b, empty = %0b, dout = %0d",
             super.convert2string(), rst_n, WE, RE, din, full, empty, dout);
        endfunction
    endclass
endpackage