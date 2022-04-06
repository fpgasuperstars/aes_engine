#clk diff pair
create_clock -period 3.33 -name board_clk [get_ports i_clk_p]
set_property PACKAGE_PIN AL8 [get_ports i_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports i_clk_p]
set_property PACKAGE_PIN AL7 [get_ports i_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports i_clk_n]