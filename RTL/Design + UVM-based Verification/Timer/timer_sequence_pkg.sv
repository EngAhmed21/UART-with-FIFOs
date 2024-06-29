package timer_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;

    class timer_rst_sequence extends uvm_sequence #(timer_seq_item);
        `uvm_object_utils(timer_rst_sequence)

        timer_seq_item rst_seq_item;

        function new(string name = "timer_rst_sequence");
            super.new(name);
        endfunction

        task pre_body;
            rst_seq_item = timer_seq_item::type_id::create("rst_seq_item");
        endtask

        task body;
            start_item(rst_seq_item);
                rst_seq_item.rst_n = 0;
                rst_seq_item.en    = 0;
            finish_item(rst_seq_item);
        endtask
    endclass

    class timer_main_sequence extends uvm_sequence #(timer_seq_item);
        `uvm_object_utils(timer_main_sequence)

        timer_seq_item main_seq_item;

        function new(string name = "timer_main_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(10000) begin
                main_seq_item = timer_seq_item::type_id::create("main_seq_item");

                start_item(main_seq_item);
                    assert(main_seq_item.randomize());
                finish_item(main_seq_item);
            end
        endtask
    endclass
endpackage