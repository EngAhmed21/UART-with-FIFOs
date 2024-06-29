package timer_driver_pkg;
    import timer_ref_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import timer_seq_item_pkg::*;

    class timer_driver extends uvm_driver #(timer_seq_item);
        `uvm_component_utils(timer_driver)

        virtual timer_IF #(FINAL_VALUE) timer_vif;
        timer_seq_item stim_seq_item;

        function new(string name = "timer_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                stim_seq_item = timer_seq_item::type_id::create("stim_seq_item");

                seq_item_port.get_next_item(stim_seq_item);

                timer_vif.rst_n = stim_seq_item.rst_n;
                timer_vif.en    = stim_seq_item.en;

                @(negedge timer_vif.clk);
                seq_item_port.item_done();

                `uvm_info("run_phase", stim_seq_item.convert2string_stim(), UVM_HIGH)
            end
        endtask
    endclass
endpackage