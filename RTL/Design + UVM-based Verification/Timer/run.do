vlib work

vlog -f Files.txt +define+TIMER_SIM +cover

vsim -voptargs=+acc work.timer_top -cover -sv_seed random

add wave -position insertpoint sim:/timer_top/IF/*

coverage save timer_cv.ucdb -onexit

run -all