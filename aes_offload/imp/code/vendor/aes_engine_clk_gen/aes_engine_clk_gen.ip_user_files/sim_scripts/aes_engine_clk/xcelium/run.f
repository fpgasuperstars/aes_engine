-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/aes_engine_clk/ip/aes_engine_clk_clk_wiz_0_0/aes_engine_clk_clk_wiz_0_0_clk_wiz.v" \
  "../../../bd/aes_engine_clk/ip/aes_engine_clk_clk_wiz_0_0/aes_engine_clk_clk_wiz_0_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/aes_engine_clk/sim/aes_engine_clk.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

