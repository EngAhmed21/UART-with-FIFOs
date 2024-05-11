import states_pkg::*;
import ref_pkg::*;
import uart_tx_pkg::*;

module uart_tx_tb (uart_tx_IF.TEST IF);
    localparam BIT_WIDTH = IF.BIT_WIDTH;
    localparam DBIT     = IF.DBIT;
    localparam SB_TICK  = IF.SB_TICK;

    logic clk, rst_n, s_tick, tx_start, tx, tx_done;
    logic [DBIT-1:0] tx_din;

    assign clk         = IF.clk;
    assign IF.rst_n    = rst_n;
    assign IF.s_tick   = s_tick;
    assign IF.tx_start = tx_start;
    assign IF.tx_din   = tx_din;
    assign tx          = IF.tx;
    assign tx_done     = IF.tx_done;

    int error, correct;
    bit [$clog2(DBIT)-1:0] n_cnt_ref;
    bit tx_done_ref, tx_ref;
    bit [DBIT-1:0] b_reg_ref;

    uart_rx_rc rc;

    always @(posedge clk) begin
        rc.cvGrp.sample();
    end

    always @(*) begin
        rc.tx_done = tx_done;
    end

    initial begin
        rc = new;

        cs_ref      = IDLE;     n_cnt_ref   = 'd0;      
        s_cnt_ref   = 'd0;      tx_done_ref = 0;        
        tx_ref      = 'd0;      

        check_rst;

        repeat (10000) begin
            assert (rc.randomize());
            rst_n    = rc.rst_n;
            s_tick   = rc.s_tick;
            tx_start = rc.tx_start;
            tx_din   = rc.tx_din;
            
            check_result (rst_n, s_tick, tx_start, tx_din);
        end

        $display("Simulation finished with error counter = %0d, correct counter = %0d", error, correct);

        $stop;
    end

    task check_rst;
        rst_n = 0;

        @(negedge clk);
        if ((~tx) || (tx_done)) begin
            $display("Check rst failed at time = %0t, tx = %0d, tx_done = %0d", $time, tx, tx_done);
            error++;
        end
        else
            correct++;

        rst_n = 1;
    endtask //

    task golden_ref (input logic rst_n, s_tick, tx_start, input logic [DBIT-1:0] tx_din);
        // cs 
        if (!rst_n)
            cs_ref <= IDLE;
        else
            case (cs_ref)
                IDLE:       cs_ref <= (tx_start) ? START : IDLE;
                START:      cs_ref <= (s_tick && (s_cnt_ref == (BIT_WIDTH-1))) ? DATA : START;
                DATA:       cs_ref <= (s_tick && (s_cnt_ref == (BIT_WIDTH-1)) && (n_cnt_ref == (DBIT-1))) ? STOP : DATA;
                STOP:       cs_ref <= (s_tick && (s_cnt_ref == (SB_TICK-1))) ? IDLE : STOP;
                default:    cs_ref <= IDLE; 
            endcase

        // S counter 
        if (!rst_n)
            s_cnt_ref <= 0;
        else 
            case (cs_ref)
                IDLE:
                    if (tx_start)
                        s_cnt_ref <= 0;       
                START: 
                    if (s_tick) 
                        if (s_cnt_ref == (BIT_WIDTH-1))
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
            if ((cs_ref == START) && (s_cnt_ref == (BIT_WIDTH-1)))
                n_cnt_ref <= 0;
            else if ((cs_ref == DATA) && (s_cnt_ref == (BIT_WIDTH-1)))
                if (n_cnt_ref == (DBIT-1))
                    n_cnt_ref <= 0;
                else 
                    n_cnt_ref <= n_cnt_ref + 1;

        // b_reg_ref
        if (!rst_n)
           b_reg_ref <= 0;
        else if (tx_start && (cs_ref == IDLE))
            b_reg_ref <= tx_din;
        else if (s_tick && (cs_ref == DATA) && (s_cnt_ref == (BIT_WIDTH-1)))
            b_reg_ref <= (b_reg_ref >> 1);

        // tx_ref
        if (!rst_n)
            tx_ref <= 1;
        else if (cs_ref == START)
            tx_ref <= 0;
        else if ((cs_ref == IDLE) || (cs_ref == STOP))
            tx_ref <= 1;
        else if (s_tick && (cs_ref == DATA))
            tx_ref <= b_reg_ref[0];
        
        // tx_done_ref
        if (!rst_n)
            tx_done_ref <= 0;
        else
            tx_done_ref <= (s_tick && (cs_ref == STOP) && (s_cnt_ref == (SB_TICK-1)));
    endtask //

    task check_result (input logic rst_n, s_tick, tx_start, input logic [DBIT-1:0] tx_din);
        golden_ref (rst_n, s_tick, tx_start, tx_din);

        @(negedge clk);
        if ((tx_done_ref != tx_done) || (tx_ref != tx)) begin
            $display("Check result failed at time = %0t, rst_n = %0d, s_tick = %0d, tx_start = %0d, tx_din = %0d, tx_done = %0d, tx_done_ref = %0d, tx = %0b, tx_ref = %0b",
             $time, rst_n, s_tick, tx_start, tx_din, tx_done, tx_done_ref, tx, tx_ref);
            error++;
        end
        else
            correct++;
    endtask //
endmodule