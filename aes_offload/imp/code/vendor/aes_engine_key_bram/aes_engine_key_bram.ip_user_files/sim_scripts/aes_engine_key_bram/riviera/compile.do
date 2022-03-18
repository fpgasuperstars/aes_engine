vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/blk_mem_gen_v8_4_5
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap blk_mem_gen_v8_4_5 riviera/blk_mem_gen_v8_4_5
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -sv2k12 \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_5  -v2k5 \
"../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/ipshared/25a8/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/ip/aes_engine_key_bram_blk_mem_gen_0_0/sim/aes_engine_key_bram_blk_mem_gen_0_0.v" \

vcom -work xil_defaultlib -93 \
"../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/sim/aes_engine_key_bram.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

