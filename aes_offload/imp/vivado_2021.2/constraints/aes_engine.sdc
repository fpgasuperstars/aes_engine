# ------------------------------------------------------------------------------
# Clocks
# ------------------------------------------------------------------------------
# sys clock
create_clock -period 20.00 -name sys_clk [get_ports sys_clk_i]

# SPI
set spi_ctrl_clk_period 227.270
create_clock -period $spi_ctrl_clk_period -name spi_ctrl_clk [get_ports spi_ctrl_sck_i]

set spi_mon_clk_period $spi_ctrl_clk_period
create_clock -period $spi_mon_clk_period -name spi_mon_clk [get_ports spi_mon_sck_i]

# Asynchronous groups
set_clock_groups -name {async} -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {spi_ctrl_clk}] -group [get_clocks {spi_mon_clk}]

# ------------------------------------------------------------------------------
# SPI
# ------------------------------------------------------------------------------
# As example. Required in the model : 60ns max
set spi_sck_to_out 20

# Model board 
set spi_board_min 15

# Required setup time example 50 max
set spi_setup 15

# Required hold time in the model example min 100ns
set spi_hold 15

# the configurable minimum in the PRM is 2*7.58ns
set spi_cs_to_sck 15
set spi_sck_to_cs 15

# ------------------------------------------------------------------------------
# SPI control
# ------------------------------------------------------------------------------
# Max clock to output / impact in the processor setup
set_output_delay [expr $spi_ctrl_clk_period - $spi_sck_to_out] -fall -max -clock_fall -clock [get_clocks spi_ctrl_clk] [get_ports {spi_ctrl_miso_o}]
# Min clock to output / impact in the processor hold
set_output_delay $spi_board_min                                -fall -min -clock_fall -clock [get_clocks spi_ctrl_clk] [get_ports {spi_ctrl_miso_o}]

# FPGA setup
set_input_delay [expr $spi_ctrl_clk_period - $spi_setup] -rise -max -clock [get_clocks spi_ctrl_clk] [get_ports {spi_ctrl_mosi_i}]
# FPGA hold
set_input_delay $spi_hold                                -rise -min -clock [get_clocks spi_ctrl_clk] [get_ports {spi_ctrl_mosi_i}]

#falling edge of CS to SCK
set_input_delay -clock [get_clocks spi_ctrl_clk] -rise -max -clock_fall [expr $spi_ctrl_clk_period   - $spi_cs_to_sck] [get_ports {spi_ctrl_cs_n_i}]
set_input_delay -clock [get_clocks spi_ctrl_clk] -fall -max -clock_fall [expr $spi_ctrl_clk_period/2 - $spi_cs_to_sck] [get_ports {spi_ctrl_cs_n_i}]

# Falling edge of SCK to the rising edge of CS
set_input_delay -clock [get_clocks spi_ctrl_clk] -fall -min -clock_fall $spi_sck_to_cs                                 [get_ports {spi_ctrl_cs_n_i}]
set_input_delay -clock [get_clocks spi_ctrl_clk] -rise -min -clock_fall [expr $spi_ctrl_clk_period/2 + $spi_sck_to_cs] [get_ports {spi_ctrl_cs_n_i}]

# ------------------------------------------------------------------------------
# SPI Monitor
# ------------------------------------------------------------------------------
# Max clock to output / impact in the processor setup
set_output_delay [expr $spi_mon_clk_period - $spi_sck_to_out] -fall -max -clock_fall -clock [get_clocks spi_mon_clk] [get_ports {spi_mon_miso_o}]
# Min clock to output / impact in the processor hold
set_output_delay $spi_board_min                                -fall -min -clock_fall -clock [get_clocks spi_mon_clk] [get_ports {spi_mon_miso_o}]

# FPGA setup
set_input_delay [expr $spi_mon_clk_period - $spi_setup] -rise -max -clock [get_clocks spi_mon_clk] [get_ports {spi_mon_mosi_i}]
# FPGA hold
set_input_delay $spi_hold                                -rise -min -clock [get_clocks spi_mon_clk] [get_ports {spi_mon_mosi_i}]

#falling edge of CS to SCK
set_input_delay -clock [get_clocks spi_mon_clk] -rise -max -clock_fall [expr $spi_mon_clk_period   - $spi_cs_to_sck] [get_ports {spi_mon_cs_n_i}]
set_input_delay -clock [get_clocks spi_mon_clk] -fall -max -clock_fall [expr $spi_mon_clk_period/2 - $spi_cs_to_sck] [get_ports {spi_mon_cs_n_i}]

# Falling edge of SCK to the rising edge of CS
set_input_delay -clock [get_clocks spi_mon_clk] -fall -min -clock_fall $spi_sck_to_cs                                [get_ports {spi_mon_cs_n_i}]
set_input_delay -clock [get_clocks spi_mon_clk] -rise -min -clock_fall [expr $spi_mon_clk_period/2 + $spi_sck_to_cs] [get_ports {spi_mon_cs_n_i}]