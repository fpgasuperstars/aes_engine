#clk diff pair
create_clock -period 3.3333 -name board_clk [get_ports i_clk_p]
set_property PACKAGE_PIN AL8 [get_ports i_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports i_clk_p]
set_property PACKAGE_PIN AL7 [get_ports i_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports i_clk_n]

#LED DS37
set_property PACKAGE_PIN AF13 [get_ports o_done]
set_property IOSTANDARD LVCMOS33 [get_ports o_done]