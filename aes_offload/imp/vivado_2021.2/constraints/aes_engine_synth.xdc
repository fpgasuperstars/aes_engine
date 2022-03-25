create_clock -period 2.85 -name board_clk [get_ports i_clk]
set_property DONT_TOUCH TRUE [get_cells gen_128.gen_128_keys.g_function_input_reg]