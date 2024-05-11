package timer_pkg;
    class timer_rc;
        rand bit rst_n, en;
        bit done;

        constraint rst_c {rst_n dist {0 := 1,  1 := 99};}
        constraint en_c  {en    dist {0 := 10, 1 := 90};}

        covergroup cvGrp;
            timer_done_cp: coverpoint done iff (rst_n) {
                bins timer_done = {1};
            }
        endgroup

        function new();
            cvGrp = new;
        endfunction //new()
    endclass //timer_rc
endpackage