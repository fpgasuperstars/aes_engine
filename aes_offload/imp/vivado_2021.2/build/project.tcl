# ============================================================================================
# Settings
# ============================================================================================
#read_ip ../../code/vendor/aes_engine_clk_gen/aes_engine_clk_gen.srcs/sources_1/bd/aes_engine_clk/ip/aes_engine_clk_clk_wiz_0_0/aes_engine_clk_clk_wiz_0_0.xci
read_ip ../../code/vendor/aes_engine_key_bram/aes_engine_key_bram.srcs/sources_1/bd/aes_engine_key_bram/ip/aes_engine_key_bram_blk_mem_gen_0_0/aes_engine_key_bram_blk_mem_gen_0_0.xci
read_vhdl -vhdl2008 -library aes_engine ../../code/devlib/aes_engine/aes_engine_pkg.vhd
read_vhdl -vhdl2008 -library aes_engine ../../code/devlib/aes_engine/aes_engine_key_expansion.vhd
read_vhdl -vhdl2008 -library aes_engine ../../code/devlib/aes_engine/aes_engine_round.vhd
read_vhdl -vhdl2008 -library aes_engine ../../code/devlib/aes_engine/aes_engine_top.vhd