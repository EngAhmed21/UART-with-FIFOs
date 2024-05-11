vlib work

vlog uart_tx_IF.sv states_pkg.sv uart_tx.sv ref_pkg.sv uart_tx_pkg.sv param_pkg.sv uart_tx_tb.sv uart_tx_top.sv +define+UART_tX_SIM +cover

vsim -voptargs=+acc work.uart_tx_top -cover -sv_seed random

add wave -position insertpoint sim:/uart_tx_top/IF/*

coverage save UART_TX_cv.ucdb -onexit

run -all