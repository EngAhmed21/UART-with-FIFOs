package FIFO_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;

    class FIFO_rst_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_rst_sequence)

        FIFO_seq_item rst_seq_item;

        function new(string name = "FIFO_rst_sequence");
            super.new(name);
        endfunction

        task pre_body;
            rst_seq_item = FIFO_seq_item::type_id::create("rst_seq_item");
        endtask

        task body;
            start_item(rst_seq_item);
                rst_seq_item.rst_n = 0;
                rst_seq_item.WE    = 0;
                rst_seq_item.RE    = 0;
                rst_seq_item.din   = 0;
            finish_item(rst_seq_item);
        endtask
    endclass

    class FIFO_main_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_main_sequence)

        FIFO_seq_item main_seq_item;

        function new(string name = "FIFO_main_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(10000) begin
                main_seq_item = FIFO_seq_item::type_id::create("main_seq_item");

                start_item(main_seq_item);
                    assert(main_seq_item.randomize());
                finish_item(main_seq_item);
            end
        endtask
    endclass

    class FIFO_full_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_full_sequence)

        FIFO_seq_item full_seq_item;

        function new(string name = "FIFO_full_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(1000) begin
                full_seq_item = FIFO_seq_item::type_id::create("full_seq_item");

                start_item(full_seq_item);
                    full_seq_item.rst_n = 1;
                    full_seq_item.WE    = 1;
                    full_seq_item.RE    = 0;
                    full_seq_item.din   = $rand();
                finish_item(full_seq_item);
            end
        endtask
    endclass
endpackage