create_clock -period 3.333 -name board_clk [get_ports clk]
set_input_jitter [get_clocks -of_objects [get_ports clk]] 0.033
set_property DONT_TOUCH TRUE [get_cells gen_128.gen_128_keys.g_function_input_reg]