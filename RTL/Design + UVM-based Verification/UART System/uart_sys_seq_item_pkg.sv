package uart_sys_seq_item_pkg;
    import states_pkg::*;
    import sys_ref_pkg::*;
    import uart_sys_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_sys_seq_item extends uvm_sequence_item;
        `uvm_object_utils(uart_sys_seq_item)

        rand bit rst_n, rx, rd_uart, wr_uart;
        rand bit [DBIT-1:0] w_data;
        bit [DBIT-1:0] w_data_past;
        bit rx_empty, tx_full, w_data_r, tx_full_seq, rx_full_seq, wr_i;
        bit [1:0] wr_uart_past;
        logic tx;
        logic [DBIT-1:0] r_data;

        constraint rst_c {rst_n == 1'b1;}
        constraint rx_c  {
            if (rx_cs == START)
                rx dist {0 := 70, 1 := 30};
            else
                rx dist {0 := 40, 1 := 60};
        }
        constraint rd_uart_c {
            if (rx_full_seq)
                (rd_uart == 0);
            else
                (rd_uart == (~rx_empty));
        }
        constraint wr_uart_c {
            if (tx_full_seq)
                $onehot({wr_uart_past, wr_uart});
        }
        constraint w_data_c {
            if (tx_full_seq && (~wr_uart))
                (w_data == w_data_past);
            else
                ($countones(w_data) > 2);
        }

        function void pre_randomize();
            // rx
            if ((~s_tick) || (rx_cs == STOP) || ((rx_cs == DATA) && (rx_s_cnt != (BIT_WIDTH-1))))
                rx.rand_mode(0);
            else
                rx.rand_mode(1);

            // w_data
            if (~tx_full_seq) begin
                wr_uart.rand_mode(0);
                if ((tx_cs == IDLE) && (~w_data_r)) begin
                    w_data.rand_mode(1);
                    wr_uart = 1;
                end
                else begin
                    w_data.rand_mode(0);
                    wr_uart = 0;
                end
            end
            else begin
                wr_uart.rand_mode(1);
                w_data.rand_mode(1);
            end

            // w_data_r
            w_data_r = (tx_cs == IDLE);
        endfunction

        function void post_randomize;
            wr_uart_past[wr_i] = wr_uart;
            wr_i++;
            w_data_past = w_data;
        endfunction

        function new (string name = "uart_sys_seq_item");
            super.new(name);
            w_data_r = 0;
            wr_i = 0;
            tx_full_seq = 0;
            rx_full_seq = 0;
        endfunction

        function string convert2string_stim();
            convert2string_stim =  $sformatf("rst_n = %0b, rx = %0b, rd_uart = %0b, wr_uart = %0b, w_data = %0d",
             rst_n, rx, rd_uart, wr_uart, w_data);
        endfunction

        function string convert2string();
            convert2string = $sformatf("%s, rst_n = %0b, rx = %0b, rd_uart = %0b, wr_uart = %0b, w_data = %0d, rx_empty = %0b, r_data = %0d, tx_full = %0b, tx = %0b",
             super.convert2string(), rst_n, rx, rd_uart, wr_uart, w_data, rx_empty, r_data, tx_full, tx);
        endfunction
    endclass
endpackage