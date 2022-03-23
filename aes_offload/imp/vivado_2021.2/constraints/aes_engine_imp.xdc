#clk diff pair

set_property PACKAGE_PIN G21 [get_ports i_clk_p] 	# SYS_CLK_p
set_property IOSTANDARD LVDS_25 [get_ports i_clk_p] # SYS_CLK_p
set_property PACKAGE_PIN F21 [get_ports i_clk_n] 	# SYS_CLK_n
set_property IOSTANDARD LVDS_25 [get_ports i_clk_n] # SYS_CLK_n