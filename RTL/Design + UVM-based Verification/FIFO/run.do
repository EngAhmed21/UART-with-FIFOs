vlib work

vlog -f Files.txt +define+FIFO_SIM +cover

vsim -voptargs=+acc work.FIFO_top -cover -sv_seed random

add wave -position insertpoint sim:/FIFO_top/IF/*

coverage save FIFO_cv.ucdb -onexit

run -all