vlib work

vlog uart_rx_IF.sv states_pkg.sv uart_rx.sv ref_pkg.sv uart_rx_pkg.sv param_pkg.sv uart_rx_tb.sv uart_rx_top.sv +define+UART_RX_SIM +cover

vsim -voptargs=+acc work.uart_rx_top -cover -sv_seed random

add wave -position insertpoint sim:/uart_rx_top/IF/*

coverage save UART_RX_cv.ucdb -onexit

run -all