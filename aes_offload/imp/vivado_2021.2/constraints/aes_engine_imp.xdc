#clk diff pair
create_clock -period 3.333 [get_ports i_clk_p]
set_input_jitter [get_clocks -of_objects [get_ports i_clk_p]] 0.033
set_property PACKAGE_PIN AL8 [get_ports i_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports i_clk_p]
set_property PACKAGE_PIN AL7 [get_ports i_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports i_clk_n]