######################################################################
#
# File name : aes_engine_top_tb_compile.do
# Created on: Thu May 05 17:57:02 +0100 2022
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vlib comp_libraries/work
vlib comp_libraries/msim

vlib comp_libraries/msim/xil_defaultlib
vlib comp_libraries/msim/aes_engine
vlib comp_libraries/msim/tb_lib

vmap xil_defaultlib comp_libraries/msim/xil_defaultlib
vmap aes_engine comp_libraries/msim/aes_engine
vmap tb_lib comp_libraries/msim/tb_lib

vlog  -incr -mfcu -work xil_defaultlib \
"../../../imp/code/vendor/aes_engine_fifo/aes_engine_fifo.gen/sources_1/ip/axis_data_fifo_0/sim/axis_data_fifo_0.v" \
"../../../imp/code/vendor/aes_engine_fifo/aes_engine_fifo.gen/sources_1/ip/aes_engine_key_bram_blk_mem_gen_0_0/sim/aes_engine_key_bram_blk_mem_gen_0_0.v" \

vcom  -2008 -work aes_engine  \
"../../../imp/code/devlib/aes_engine/aes_engine_pkg.vhd" \
"../../../imp/code/devlib/aes_engine/aes_engine_decrypt.vhd" \
"../../../imp/code/devlib/aes_engine/aes_engine_key_expansion.vhd" \
"../../../imp/code/devlib/aes_engine/aes_engine_round.vhd" \
"../../../imp/code/devlib/aes_engine/aes_pkg.vhd" \
"../../../imp/code/devlib/aes_engine/gcm_pkg.vhd" \
"../../../imp/code/devlib/aes_engine/ghash_gfmul.vhd" \
"../../../imp/code/devlib/aes_engine/gcm_ghash.vhd" \

vcom  -2008 -work tb_lib  \
"../../../dev_sim/code/aes_engine_tb_pkg.vhd" \

vcom  -2008 -work aes_engine  \
"../../../imp/code/devlib/aes_engine/aes_engine_top.vhd" \

vcom  -2008 -work xil_defaultlib  \
"../../../dev_sim/code/aes_engine_top/aes_engine_top_tb.vhd"

