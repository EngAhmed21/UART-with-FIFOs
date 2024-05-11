import states_pkg::*;

module uart_rx #(parameter BIT_WIDTH = 16, DBIT = 8, SB_TICK = 16) (
    input logic clk, rst_n, s_tick, rx, 
    output logic rx_done,
    output logic [DBIT-1:0] rx_dout
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
                IDLE:       cs <= (rx) ? IDLE : START;
                START:      cs <= (s_tick && (s_cnt == ((BIT_WIDTH/2)-1))) ? DATA : START;
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
                    if (~rx)
                        s_cnt <= 'd0;
                START:
                    if (s_tick) 
                        if (s_cnt == ((BIT_WIDTH/2)-1))
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
            if ((cs == START) && (s_cnt == ((BIT_WIDTH/2)-1)))
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
            b_reg <= 'd0;
        else if (s_tick && (cs == DATA) && (s_cnt == (BIT_WIDTH-1)))
            b_reg <= {rx, b_reg[(DBIT-1):1]};
    end

    // Output Logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            rx_done <= 0;
        else 
            rx_done = (s_tick && (cs == STOP) && ((s_cnt == (SB_TICK-1)))); 
    end

    assign rx_dout = rx_done ? b_reg : 'd0;    



    `ifdef UART_RX_SIM
        // reset_out
        always_comb begin
            if (!rst_n) 
                uart_rx_out_rst_a: assert final ((~rx_done) && (rx_dout == 0));
        end

        // reset_internal
        always_comb begin
            if (!rst_n) 
                uart_rx_internal_rst_a: assert final ((cs == IDLE) && (s_cnt == 0) && (n_cnt == 0) && (b_reg == 0));
        end
        
        // s_cnt = 0
        sequence uart_rx_s_cnt_0_s;
            (((cs == IDLE) && (~rx)) || (s_tick && (((cs == START) && (s_cnt == ((BIT_WIDTH/2)-1))) || ((cs == DATA) && (s_cnt == (BIT_WIDTH-1))))));
        endsequence
        property uart_rx_s_cnt_0_p;
            @(posedge clk) disable iff((!rst_n)) (uart_rx_s_cnt_0_s) |=> (s_cnt == 0);
        endproperty
        uart_rx_s_cnt_0_a: assert property (uart_rx_s_cnt_0_p);
        uart_rx_s_cnt_0_c: cover  property (uart_rx_s_cnt_0_p);

        // s_cnt++
        sequence uart_rx_s_cnt_incr_s;
            (s_tick && (((cs == START) && (s_cnt != ((BIT_WIDTH/2)-1))) || ((cs == DATA) && (s_cnt != (BIT_WIDTH-1)) || ((cs == STOP) && (s_cnt != (SB_TICK-1))))));
        endsequence
        property uart_rx_s_cnt_incr_p;
            @(posedge clk) disable iff ((!rst_n)) (uart_rx_s_cnt_incr_s) |=> (s_cnt == ($past(s_cnt) + 1'b1));
        endproperty
        uart_rx_s_cnt_incr_a: assert property (uart_rx_s_cnt_incr_p);
        uart_rx_s_cnt_incr_c: cover  property (uart_rx_s_cnt_incr_p);

        // n_cnt = 0
        sequence uart_rx_n_cnt_0_s;
            (s_tick && (((cs == START) && (s_cnt == ((BIT_WIDTH/2)-1))) || ((cs == DATA) && (s_cnt == (BIT_WIDTH-1)) && (n_cnt == (DBIT-1)))));
        endsequence
        property uart_rx_n_cnt_0_p;
            @(posedge clk) disable iff ((!rst_n)) (uart_rx_n_cnt_0_s) |=> (n_cnt == 0);
        endproperty
        uart_rx_n_cnt_0_a: assert property (uart_rx_n_cnt_0_p);
        uart_rx_n_cnt_0_c: cover  property (uart_rx_n_cnt_0_p);

        // n_cnt++
        sequence uart_rx_n_cnt_incr_s;
            (s_tick && (cs == DATA) && (s_cnt == (BIT_WIDTH-1)) && (n_cnt == (DBIT-1)));
        endsequence
        property uart_rx_n_cnt_incr_p;
            @(posedge clk) disable iff ((!rst_n)) (uart_rx_n_cnt_incr_s) |=> (n_cnt == ($past(n_cnt) + 1'b1));
        endproperty
        uart_rx_n_cnt_incr_a: assert property (uart_rx_n_cnt_incr_p);
        uart_rx_n_cnt_incr_c: cover  property (uart_rx_n_cnt_incr_p);

        // b_reg
        property uart_rx_b_reg_p;
            @(posedge clk) disable iff (!rst_n) (s_tick && (cs == DATA) && (s_cnt == (BIT_WIDTH-1))) |=> (b_reg == ({$past(rx), $past(b_reg[(DBIT-1):1])}));
        endproperty
        uart_rx_b_reg_a: assert property (uart_rx_b_reg_p);
        uart_rx_b_reg_c: cover  property (uart_rx_b_reg_p);

        // rx_done
        property uart_rx_done_p;
            @(posedge clk) disable iff (!rst_n) (s_tick && (cs == STOP) && ((s_cnt == (SB_TICK-1)))) |=> (rx_done);
        endproperty
        uart_rx_done_a: assert property (uart_rx_done_p);
        uart_rx_done_c: cover  property (uart_rx_done_p);

        // rx_dout
        always_comb begin
            if (rx_done)
                uart_rx_dout_a: assert final (rx_dout == b_reg);
        end
    `endif
endmodule