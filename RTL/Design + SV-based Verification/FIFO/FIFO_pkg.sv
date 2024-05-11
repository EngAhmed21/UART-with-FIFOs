package FIFO_pkg;
    class FIFO_rc #(parameter WIDTH = 4);
        rand bit rst_n, WE, RE;
        rand bit [WIDTH-1:0] din;
        bit full, empty;
        bit [WIDTH-1:0] dout;

        constraint rst_c {rst_n dist {0 := 1,  1 := 99};}
        constraint WE_c  {WE    dist {0 := 30, 1 := 70};} 
        constraint RE_c  {RE    dist {0 := 30, 1 := 70};} 
        constraint din_c {($countones(din) > (WIDTH/3));}

        covergroup cvGrp;
            option.auto_bin_max = (2**WIDTH)-1;

            WE_cp:    coverpoint WE   iff (rst_n);
            RE_cp:    coverpoint RE   iff (rst_n);
            din_cp:   coverpoint din  iff (rst_n && WE);
            dout_cp:  coverpoint dout iff (rst_n && RE);
            full_cp:  coverpoint full iff (rst_n) {bins full_bin   = {1};}
            empty_cp: coverpoint empty iff (rst_n) {bins empty_bin = {1};}
        endgroup

        function new;
            cvGrp = new;
        endfunction //new()
    endclass //fifo_rc
endpackage