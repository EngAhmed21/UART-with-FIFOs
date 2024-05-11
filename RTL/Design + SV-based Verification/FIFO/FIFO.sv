module FIFO (FIFO_IF.DUT IF);
    localparam WIDTH = IF.WIDTH;
    localparam DEPTH = IF.DEPTH;
    localparam ADDR  = $clog2(DEPTH);

    logic clk, rst_n, WE, RE, full, empty;
    logic [WIDTH-1:0] din, dout;

    assign clk      = IF.clk;
    assign rst_n    = IF.rst_n;
    assign WE       = IF.WE;
    assign RE       = IF.RE;
    assign din      = IF.din;
    assign IF.full  = full;
    assign IF.empty = empty;
    assign IF.dout  = dout;

    logic [WIDTH-1:0] FIFO_MEM [DEPTH];
    logic [ADDR:0] wr_ptr, rd_ptr;

    // Write
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (WE && (!full)) begin
            FIFO_MEM[wr_ptr[ADDR-1:0]] <= din;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            dout   <= 0;
        end
        else if (RE && (!empty)) begin
            rd_ptr <= rd_ptr + 1;
            dout   <= FIFO_MEM[rd_ptr[ADDR-1:0]]; 
        end
    end

    // Flags
    assign full  = ((rd_ptr[ADDR-1:0] == wr_ptr[ADDR-1:0]) && (rd_ptr[ADDR] != wr_ptr[ADDR]));
    assign empty = (rd_ptr == wr_ptr);

    // Assertions
    `ifdef FIFO_SIM
        // rstn
        always_comb begin
            if (!rst_n)
                fifo_rstn_a: assert final ((dout == 0) && (wr_ptr == 0) && (rd_ptr == 0));    
        end

        // Write
        property fifo_write_mem_p;
            @(posedge clk) disable iff (!rst_n) (WE && (!full)) |=> (FIFO_MEM[$past(wr_ptr[(ADDR-1):0])] == $past(din));
        endproperty
        fifo_write_mem_a: assert property (fifo_write_mem_p);
        fifo_write_mem_c: cover  property (fifo_write_mem_p);

        property fifo_write_ptr_p;
            @(posedge clk) disable iff (!rst_n) (WE && (!full)) |=> (wr_ptr == ($past(wr_ptr) + 1'b1));
        endproperty
        fifo_write_ptr_a: assert property (fifo_write_ptr_p);
        fifo_write_ptr_c: cover  property (fifo_write_ptr_p);

        // No Write
        property fifo_no_write_mem_p;
            @(posedge clk) disable iff (!rst_n) ((!WE) || full) |=> ($stable(FIFO_MEM));
        endproperty
        fifo_no_write_mem_a: assert property (fifo_no_write_mem_p);
        fifo_no_write_mem_c: cover  property (fifo_no_write_mem_p);

        property fifo_no_write_ptr_p;
            @(posedge clk) disable iff (!rst_n) ((!WE) || full) |=> ($stable(wr_ptr));
        endproperty
        fifo_no_write_ptr_a: assert property (fifo_no_write_ptr_p);
        fifo_no_write_ptr_c: cover  property (fifo_no_write_ptr_p);

        // Read
        property fifo_read_dout_p;
            @(posedge clk) disable iff (!rst_n) (RE && (!empty)) |=> (dout == (FIFO_MEM[$past(rd_ptr[(ADDR-1):0])]));
        endproperty
        fifo_read_dout_a: assert property (fifo_read_dout_p);
        fifo_read_dout_c: cover  property (fifo_read_dout_p);

        property fifo_read_ptr_p;
            @(posedge clk) disable iff (!rst_n) (RE && (!empty)) |=> (rd_ptr == ($past(rd_ptr) + 1'b1));
        endproperty
        fifo_read_ptr_a: assert property (fifo_read_ptr_p);
        fifo_read_ptr_c: cover  property (fifo_read_ptr_p);

        // No Read
        property fifo_no_read_dout_p;
            @(posedge clk) disable iff (!rst_n) ((!RE) || empty) |=> ($stable(dout));
        endproperty
        fifo_no_read_dout_a: assert property (fifo_no_read_dout_p);
        fifo_no_read_dout_c: cover  property (fifo_no_read_dout_p);

        property fifo_no_read_ptr_p;
            @(posedge clk) disable iff (!rst_n) ((!RE) || empty) |=> ($stable(rd_ptr));
        endproperty
        fifo_no_read_ptr_a: assert property (fifo_no_read_ptr_p);
        fifo_no_read_ptr_c: cover  property (fifo_no_read_ptr_p);


        // Full
        always_comb begin
            if ((wr_ptr[ADDR-1:0] == rd_ptr[ADDR-1:0]) && (wr_ptr[ADDR] != rd_ptr[ADDR]))
                fifo_full_a: assert final (full);
        end

        // Empty
        always_comb begin
            if (wr_ptr == rd_ptr)
                fifo_empty_a: assert final (empty); 
        end
    `endif 
endmodule
