package uart_sys_pkg;
    import states_pkg::*;
    import param_pkg::*;
    import ref_pkg::*;

    class uart_sys_rc;
        rand bit rst_n, rx, rd_uart;
        rand bit [DBIT-1:0] w_data;
        bit rx_empty, tx_full, rd_uart_past, w_data_r, wr_uart;
        bit [DBIT-1:0] r_data;

        constraint rst_c {rst_n == 1'b1;}
        constraint rx_c  {
            if (rx_cs == START)
                rx dist {0 := 70, 1 := 30};
            else
                rx dist {0 := 40, 1 := 60};
        }
        constraint rd_uart_c {
            (rd_uart == (~rx_empty));
        }
        covergroup cvGrp; 
            option.auto_bin_max = 256;

            tx_full_cp:  coverpoint tx_full  iff (rst_n);
            rx_empty_cp: coverpoint rx_empty iff (rst_n);
            r_data_cp:   coverpoint r_data   iff (rst_n && rd_uart_past);
        endgroup

        function void pre_randomize();
            // rx
            if ((~s_tick) || (rx_cs == STOP) || ((rx_cs == DATA) && (rx_s_cnt != (BIT_WIDTH-1))))
                rx.rand_mode(0);
            else
                rx.rand_mode(1);

            // rd_uart_past
            rd_uart_past = rd_uart;

            // w_data
            if ((tx_cs == IDLE) && (~w_data_r)) begin
                w_data.rand_mode(1);
                wr_uart = 1;
            end
            else begin
                w_data.rand_mode(0);
                wr_uart = 0;
            end

            // w_data_r
            w_data_r = (tx_cs == IDLE);
        endfunction

        function new();
            w_data_r = 0;
            rd_uart_past = 0;

            cvGrp = new;
        endfunction //new()
    endclass //uart_sys_rc
endpackage
