import states_pkg::*;

module uart_tx #(parameter BIT_WIDTH = 16, DBIT = 8, SB_TICK = 16) (
    input logic clk, rst_n, s_tick, tx_start, 
    input logic [DBIT-1:0] tx_din,
    output logic tx, tx_done
);
    localparam SCNT_BIT = (SB_TICK > BIT_WIDTH) ? $clog2(SB_TICK) : $clog2(BIT_WIDTH);

    state_e cs;

    logic [$clog2(DBIT)-1:0] n_cnt;
    logic [SCNT_BIT-1:0] s_cnt;
    logic [DBIT-1:0] b_reg;

    // Current State Logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            case (cs)
                IDLE:       cs <= (tx_start) ? START : IDLE;
                START:      cs <= (s_tick && (s_cnt == (BIT_WIDTH-1))) ? DATA : START;
                DATA:       cs <= (s_tick && (s_cnt == (BIT_WIDTH-1)) && (n_cnt == (DBIT-1))) ? STOP : DATA;
                STOP:       cs <= (s_tick && (s_cnt == (SB_TICK-1))) ? IDLE : STOP;
                default:    cs <= IDLE; 
            endcase
    end

    // S Counter Logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            s_cnt <= 'd0;
        else 
            case (cs)
                IDLE:   
                    if (tx_start)
                        s_cnt <= 'd0;
                START:
                    if (s_tick) 
                        if (s_cnt == (BIT_WIDTH-1))
                            s_cnt <= 'd0;
                        else
                            s_cnt <= s_cnt + 1;
                DATA:
                    if (s_tick)
                        if (s_cnt == (BIT_WIDTH-1))
                            s_cnt <= 'd0;
                        else
                            s_cnt <= s_cnt + 1;
                STOP:
                    if (s_tick)
                        if (s_cnt != (SB_TICK-1))
                            s_cnt <= s_cnt + 1;
            endcase
    end

    // N Counter Logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            n_cnt <= 'd0;
        else if (s_tick)
            if ((cs == START) && (s_cnt == (BIT_WIDTH-1)))
                n_cnt <= 'd0;
            else if ((cs == DATA) && (s_cnt == (BIT_WIDTH-1)))
                if (n_cnt == (DBIT-1))
                    n_cnt <= 'd0;
                else
                    n_cnt <= n_cnt + 1;
    end

    // b_reg
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            b_reg <= 0;
        else if ((s_cnt == 'd0) && (cs == START))
            b_reg <= tx_din;
        else if (s_tick && (cs == DATA) && (s_cnt == (BIT_WIDTH-1)))
            b_reg <= (b_reg >> 1);
    end

    // Output Logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            tx <= 1;
        else if (cs == START)
            tx <= 0;
        else if ((cs == IDLE) || (cs == STOP))
            tx <= 1;
        else if (cs == DATA)
            tx <= b_reg[0];
    end

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            tx_done <= 0;
        else
            tx_done <= (s_tick && (cs == STOP) && (s_cnt == (SB_TICK-1)));
    end


    `ifdef UART_TX_SIM
        // reset_out
        always_comb begin
            if (!rst_n) 
                uart_tx_out_rst_a: assert final ((~tx_done) && tx);
        end

        // reset_internal
        always_comb begin
            if (!rst_n) 
                uart_tx_internal_rst_a: assert final ((cs == IDLE) && (s_cnt == 0) && (n_cnt == 0) && (b_reg == 0));
        end
        
        // s_cnt = 0
        sequence uart_tx_s_cnt_0_s;
            (((cs == IDLE) && (tx_start)) || (s_tick && (((cs == START) || (cs == DATA)) && (s_cnt == (BIT_WIDTH-1)))));
        endsequence
        property uart_tx_s_cnt_0_p;
            @(posedge clk) disable iff((!rst_n)) (uart_tx_s_cnt_0_s) |=> (s_cnt == 0);
        endproperty
        uart_tx_s_cnt_0_a: assert property (uart_tx_s_cnt_0_p);
        uart_tx_s_cnt_0_c: cover  property (uart_tx_s_cnt_0_p);

        // s_cnt++
        sequence uart_tx_s_cnt_incr_s;
            (s_tick && (((cs == START) || (cs == DATA) && (s_cnt != (BIT_WIDTH-1))) || ((cs == STOP) && (s_cnt != (SB_TICK-1)))));
        endsequence
        property uart_tx_s_cnt_incr_p;
            @(posedge clk) disable iff ((!rst_n)) (uart_tx_s_cnt_incr_s) |=> (s_cnt == ($past(s_cnt) + 1'b1));
        endproperty
        uart_tx_s_cnt_incr_a: assert property (uart_tx_s_cnt_incr_p);
        uart_tx_s_cnt_incr_c: cover  property (uart_tx_s_cnt_incr_p);

        // n_cnt = 0
        sequence uart_tx_n_cnt_0_s;
            (s_tick && ((s_cnt == (BIT_WIDTH-1)) && ((cs == START) || ((cs == DATA) && (n_cnt == (DBIT-1)))))); 
        endsequence
        property uart_tx_n_cnt_0_p;
            @(posedge clk) disable iff ((!rst_n)) (uart_tx_n_cnt_0_s) |=> (n_cnt == 0);
        endproperty
        uart_tx_n_cnt_0_a: assert property (uart_tx_n_cnt_0_p);
        uart_tx_n_cnt_0_c: cover  property (uart_tx_n_cnt_0_p);

        // n_cnt++
        sequence uart_tx_n_cnt_incr_s;
            (s_tick && (cs == DATA) && (s_cnt == (BIT_WIDTH-1)) && (n_cnt == (DBIT-1)));
        endsequence
        property uart_tx_n_cnt_incr_p;
            @(posedge clk) disable iff ((!rst_n)) (uart_tx_n_cnt_incr_s) |=> (n_cnt == ($past(n_cnt) + 1'b1));
        endproperty
        uart_tx_n_cnt_incr_a: assert property (uart_tx_n_cnt_incr_p);
        uart_tx_n_cnt_incr_c: cover  property (uart_tx_n_cnt_incr_p);

        // b_reg IDLE
        property uart_tx_b_reg_start_p;
            @(posedge clk) disable iff (!rst_n) ((s_cnt == 'd0) && (cs == START)) |=> (b_reg == $past(tx_din));
        endproperty
        uart_tx_b_reg_idle_a: assert property (uart_tx_b_reg_start_p);
        uart_tx_b_reg_idle_c: cover  property (uart_tx_b_reg_start_p);

        // b_reg
        property uart_tx_b_reg_p;
            @(posedge clk) disable iff (!rst_n) (s_tick && (cs == DATA) && (s_cnt == (BIT_WIDTH-1))) |=> (b_reg == ($past(b_reg) >> 1));
        endproperty
        uart_tx_b_reg_a: assert property (uart_tx_b_reg_p);
        uart_tx_b_reg_c: cover  property (uart_tx_b_reg_p);

        // tx_done
        property uart_tx_done_p;
            @(posedge clk) disable iff (!rst_n) (s_tick && (cs == STOP) && ((s_cnt == (SB_TICK-1)))) |=> (tx_done);
        endproperty
        uart_tx_done_a: assert property (uart_tx_done_p);
        uart_tx_done_c: cover  property (uart_tx_done_p);

        // tx 0
        property uart_tx_0_p;
            @(posedge clk) disable iff (!rst_n) (cs == START) |=> (~tx);
        endproperty
        uart_tx_0_a: assert property (uart_tx_0_p);
        uart_tx_0_c: cover  property (uart_tx_0_p);

        // tx 1
        property uart_tx_1_p;
            @(posedge clk) disable iff (!rst_n) ((cs == IDLE) || (cs == STOP)) |=> (tx);
        endproperty
        uart_tx_1_a: assert property (uart_tx_1_p);
        uart_tx_1_c: cover  property (uart_tx_1_p);

        // tx 2
        property uart_tx_2_p;
            @(posedge clk) disable iff (!rst_n) (cs == DATA) |=> (tx == $past(b_reg[0]));
        endproperty
        uart_tx_2_a: assert property (uart_tx_2_p);
        uart_tx_2_c: cover  property (uart_tx_2_p);
    `endif
endmodule