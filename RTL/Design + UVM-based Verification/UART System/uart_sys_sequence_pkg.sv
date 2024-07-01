package uart_sys_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_sys_seq_item_pkg::*;

    class uart_sys_rst_sequence extends uvm_sequence #(uart_sys_seq_item);
        `uvm_object_utils(uart_sys_rst_sequence)

        uart_sys_seq_item rst_seq_item;

        function new(string name = "uart_sys_rst_sequence");
            super.new(name);
        endfunction

        task pre_body;
            rst_seq_item = uart_sys_seq_item::type_id::create("rst_seq_item");
        endtask

        task body;
            start_item(rst_seq_item);
                rst_seq_item.rst_n   = 0;
                rst_seq_item.rx      = 0;
                rst_seq_item.rd_uart = 0;
                rst_seq_item.wr_uart = 0;
                rst_seq_item.w_data  = 0;
            finish_item(rst_seq_item);
        endtask
    endclass

    class uart_sys_main_sequence extends uvm_sequence #(uart_sys_seq_item);
        `uvm_object_utils(uart_sys_main_sequence)

        uart_sys_seq_item main_seq_item;

        function new(string name = "uart_sys_main_sequence");
            super.new(name);
        endfunction

        task pre_body;
            main_seq_item = uart_sys_seq_item::type_id::create("main_seq_item");
        endtask

        task body;
            repeat(30000) begin
                start_item(main_seq_item);
                    assert(main_seq_item.randomize());
                finish_item(main_seq_item);
            end
        endtask
    endclass

    class uart_sys_full_sequence extends uvm_sequence #(uart_sys_seq_item);
        `uvm_object_utils(uart_sys_full_sequence)

        uart_sys_seq_item full_seq_item;

        function new(string name = "uart_sys_full_sequence");
            super.new(name);
        endfunction

        task pre_body;
            full_seq_item = uart_sys_seq_item::type_id::create("full_seq_item");
        endtask

        task body;
            repeat(10000) begin
                start_item(full_seq_item);
                    full_seq_item.rst_n   = 1;
                    full_seq_item.rx      = $random();
                    full_seq_item.rd_uart = 0;
                    full_seq_item.wr_uart = 1;
                    full_seq_item.rst_n   = 1;
                    full_seq_item.w_data  = $random();
                finish_item(full_seq_item);
            end
        endtask
    endclass
endpackage
