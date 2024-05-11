import states_pkg::*;
import ref_pkg::*;
import uart_rx_pkg::*;

module uart_rx_tb (uart_rx_IF.TEST IF);
    localparam BIT_WIDTH = IF.BIT_WIDTH;
    localparam DBIT     = IF.DBIT;
    localparam SB_TICK  = IF.SB_TICK;

    logic clk, rst_n, s_tick, rx, rx_done;
    logic [DBIT-1:0] rx_dout;

    assign clk       = IF.clk;
    assign IF.rst_n  = rst_n;
    assign IF.s_tick = s_tick;
    assign IF.rx     = rx;
    assign rx_done   = IF.rx_done;
    assign rx_dout   = IF.rx_dout;

    int error, correct;
    bit [$clog2(DBIT)-1:0] n_cnt_ref;
    bit rx_done_ref;
    bit [DBIT-1:0] b_reg_ref, rx_dout_ref;

    uart_rx_rc rc;

    always @(posedge clk) begin
        rc.cvGrp.sample();
    end

    always @(*) begin
        rc.rx_done = rx_done;
    end

    initial begin
        rc = new;

        cs_ref      = IDLE;     n_cnt_ref   = 'd0;      
        s_cnt_ref   = 'd0;      rx_done_ref = 0;        
        rx_dout_ref = 'd0;      

        check_rst;

        repeat (10000) begin
            assert (rc.randomize());
            rst_n  = rc.rst_n;
            s_tick = rc.s_tick;
            rx     = rc.rx;
            
            check_result (rst_n, s_tick, rx);
        end

        $display("Simulation finished with error counter = %0d, correct counter = %0d", error, correct);

        $stop;
    end

    task check_rst;
        rst_n = 0;

        @(negedge clk);
        if ((rx_dout != 0) || (rx_done)) begin
            $display("Check rst failed at time = %0t, rx_done = %0d, rx_dout = %0d", $time, rx_done, rx_dout);
            error++;
        end
        else
            correct++;

        rst_n = 1;
    endtask //

    task golden_ref (input logic rst_n, s_tick, rx);
        // cs 
        if (!rst_n)
            cs_ref <= IDLE;
        else
            case (cs_ref)
                IDLE:      cs_ref <= (rx) ? IDLE : START;
                START:     cs_ref <= (s_tick && (s_cnt_ref == ((BIT_WIDTH/2)-1))) ? DATA : START;
                DATA:      cs_ref <= (s_tick && (s_cnt_ref == (BIT_WIDTH-1)) && (n_cnt_ref == (DBIT-1))) ? STOP : DATA;
                STOP:      cs_ref <= (s_tick && (s_cnt_ref == (SB_TICK-1))) ? IDLE : STOP;
            endcase

        // S counter 
        if (!rst_n)
            s_cnt_ref <= 0;
        else 
            case (cs_ref)
                IDLE:
                    if (~rx)
                        s_cnt_ref <= 0;       
                START: 
                    if (s_tick) 
                        if (s_cnt_ref == ((BIT_WIDTH/2)-1))
                            s_cnt_ref <= 0;
                        else    
                            s_cnt_ref <= s_cnt_ref + 1;
                DATA:      
                    if (s_tick) 
                        if (s_cnt_ref == (BIT_WIDTH-1))
                            s_cnt_ref <= 0;
                        else    
                            s_cnt_ref <= s_cnt_ref + 1;
                STOP:       
                    if (s_tick) 
                        if (s_cnt_ref == (SB_TICK-1))
                            s_cnt_ref <= 0;
                        else    
                            s_cnt_ref <= s_cnt_ref + 1;
            endcase

        // N counter 
        if (!rst_n)
            n_cnt_ref <= 0;
        else if (s_tick)
            if ((cs_ref == START) && (s_cnt_ref == ((BIT_WIDTH/2)-1)))
                n_cnt_ref <= 0;
            else if ((cs_ref == DATA) && (s_cnt_ref == (BIT_WIDTH-1)))
                if (n_cnt_ref == (DBIT-1))
                    n_cnt_ref <= 0;
                else 
                    n_cnt_ref <= n_cnt_ref + 1;

        // b_reg_ref
        if (!rst_n)
            b_reg_ref <= 0;
        else if (s_tick && (cs_ref == DATA) && (s_cnt_ref == (BIT_WIDTH-1)))
            b_reg_ref <= {rx, b_reg_ref[(DBIT-1):1]};

        // rx_done_ref
        if (!rst_n)
            rx_done_ref <= 0;
        else
            rx_done_ref <= (s_tick && (cs_ref == STOP) && (s_cnt_ref == (SB_TICK-1)));
    endtask //

    task check_result (input logic rst_n, s_tick, rx);
        golden_ref (rst_n, s_tick, rx);

        @(negedge clk);

        // r_dout_ref
        rx_dout_ref = (rx_done_ref) ? b_reg_ref : 0;

        if ((rx_done_ref != rx_done) || (rx_dout_ref != rx_dout)) begin
            $display("Check result failed at time = %0t, rst_n = %0d, s_tick = %0d, rx = %0d, rx_done = %0d, rx_done_ref = %0d, rx_dout = %0b, rx_dout_ref = %0b",
             $time, rst_n, s_tick, rx, rx_done, rx_done_ref, rx_dout, rx_dout_ref);
            error++;
        end
        else
            correct++;
    endtask //
endmodule