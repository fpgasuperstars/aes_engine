vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/blk_mem_gen_v8_4_5
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap blk_mem_gen_v8_4_5 modelsim_lib/msim/blk_mem_gen_v8_4_5
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu -sv \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_5  -incr -mfcu \
"../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/ipshared/25a8/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu \
"../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/ip/aes_engine_key_bram_blk_mem_gen_0_0/sim/aes_engine_key_bram_blk_mem_gen_0_0.v" \

vcom -work xil_defaultlib  -93 \
"../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/sim/aes_engine_key_bram.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

