vlib work

vlog states_pkg.sv param_pkg.sv ref_pkg.sv timer.sv FIFO.sv uart_sys_IF.sv uart_rx.sv uart_tx.sv uart_sys_pkg.sv uart_sys.sv uart_sys_tb.sv uart_sys_top.sv +define+FIFO_SIM +define+UART_RX_SIM +define+UART_TX_SIM +cover

vsim -voptargs=+acc work.uart_sys_top -cover -sv_seed random

add wave -position insertpoint sim:/uart_sys_top/IF/*

coverage save UART_cv.ucdb -onexit

run -all