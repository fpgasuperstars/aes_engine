vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu -sv "+incdir+../../../../aes_engine_clk_gen.gen/sources_1/bd/aes_engine_clk/ipshared/62b6" \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93 \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../../aes_engine_clk_gen.gen/sources_1/bd/aes_engine_clk/ipshared/62b6" \
"../../../bd/aes_engine_clk/ip/aes_engine_clk_clk_wiz_0_0/aes_engine_clk_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/aes_engine_clk/ip/aes_engine_clk_clk_wiz_0_0/aes_engine_clk_clk_wiz_0_0.v" \

vcom -work xil_defaultlib  -93 \
"../../../bd/aes_engine_clk/sim/aes_engine_clk.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

