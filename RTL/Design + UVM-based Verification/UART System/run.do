vlib work

vlog -f Files.txt +define+TIMER_SIM +define+FIFO_SIM +define+UART_RX_SIM +define+UART_TX_SIM +cover

vsim -voptargs=+acc work.uart_sys_top -classdebug -uvmcontrol=all -cover -sv_seed random

add wave -position insertpoint sim:/uart_sys_top/sys_if/*

coverage save UART_cv.ucdb -onexit

run -all