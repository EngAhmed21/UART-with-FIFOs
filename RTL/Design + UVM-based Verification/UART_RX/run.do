vlib work

vlog -f Files.txt +define+UART_RX_SIM +cover

vsim -voptargs=+acc work.uart_rx_top -cover -sv_seed random

add wave -position insertpoint sim:/uart_rx_top/IF/*

coverage save UART_RX_cv.ucdb -onexit

run -all