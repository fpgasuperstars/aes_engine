######################################################################
#
# File name : aes_engine_top_tb_simulate.do
# Created on: Thu May 05 17:57:05 +0100 2022
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L xil_defaultlib -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_7 -L blk_mem_gen_v8_4_5 -L aes_engine -L tb_lib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.aes_engine_top_tb xil_defaultlib.glbl -msgmode both -displaymsgmode both

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {C:\git\aes_engine\aes_offload\dev_sim\scripts\aes_engine_top\aes_top_wave.tcl}

view wave
view structure
view signals

log -r /*

do {aes_engine_top_tb.udo}

run -all
