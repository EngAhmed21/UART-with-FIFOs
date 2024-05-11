vlib work

vlog FIFO_IF.sv FIFO.sv FIFO_pkg.sv FIFO_tb.sv FIFO_top.sv +define+FIFO_SIM +cover

vsim -voptargs=+acc work.FIFO_top -cover -sv_seed random

add wave -position insertpoint sim:/FIFO_top/IF/*

coverage save FIFO_cv.ucdb -onexit

run -all