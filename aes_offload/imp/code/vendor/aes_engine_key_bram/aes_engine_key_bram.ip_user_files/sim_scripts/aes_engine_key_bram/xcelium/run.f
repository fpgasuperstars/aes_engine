-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_5 \
  "../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/ipshared/25a8/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/ip/aes_engine_key_bram_blk_mem_gen_0_0/sim/aes_engine_key_bram_blk_mem_gen_0_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../aes_engine_key_bram.gen/sources_1/bd/aes_engine_key_bram/sim/aes_engine_key_bram.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

