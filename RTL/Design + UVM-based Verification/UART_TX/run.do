vlib work

vlog -f Files.txt +define+UART_tX_SIM +cover

vsim -voptargs=+acc work.uart_tx_top -cover -sv_seed random

add wave -position insertpoint sim:/uart_tx_top/IF/*

coverage save UART_TX_cv.ucdb -onexit

run -all