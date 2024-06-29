package uart_tx_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_tx_seq_item_pkg::*;

    class uart_tx_rst_sequence extends uvm_sequence #(uart_tx_seq_item);
        `uvm_object_utils(uart_tx_rst_sequence)

        uart_tx_seq_item rst_seq_item;

        function new(string name = "uart_tx_rst_sequence");
            super.new(name);
        endfunction

        task pre_body;
            rst_seq_item = uart_tx_seq_item::type_id::create("rst_seq_item");
        endtask

        task body;
            start_item(rst_seq_item);
                rst_seq_item.rst_n    = 0;
                rst_seq_item.s_tick   = 0;
                rst_seq_item.tx_start = 0;
                rst_seq_item.tx_din   = 0;
            finish_item(rst_seq_item);
        endtask
    endclass

    class uart_tx_main_sequence extends uvm_sequence #(uart_tx_seq_item);
        `uvm_object_utils(uart_tx_main_sequence)

        uart_tx_seq_item main_seq_item;

        function new(string name = "uart_tx_main_sequence");
            super.new(name);
        endfunction

        task pre_body;
            main_seq_item = uart_tx_seq_item::type_id::create("main_seq_item");
        endtask

        task body;
            repeat(10000) begin
                start_item(main_seq_item);
                    assert(main_seq_item.randomize());
                finish_item(main_seq_item);
            end
        endtask
    endclass
endpackage