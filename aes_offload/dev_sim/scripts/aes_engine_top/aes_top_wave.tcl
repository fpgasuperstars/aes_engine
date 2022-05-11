onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aes_engine_top_tb/test_msg
add wave -noupdate -group {clk rst} /aes_engine_top_tb/dut/i_rst
add wave -noupdate -group {clk rst} /aes_engine_top_tb/u_fifo/s_axis_aclk
add wave -noupdate -group {clk rst} /aes_engine_top_tb/u_fifo/m_axis_aclk
add wave -noupdate -radix hexadecimal /aes_engine_top_tb/exp_ct
add wave -noupdate -expand -group IO -expand -group {axi stream} -radix hexadecimal /aes_engine_top_tb/dut/i_t_data
add wave -noupdate -expand -group IO -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_valid
add wave -noupdate -expand -group IO -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_last
add wave -noupdate -expand -group IO -expand -group {axi stream} -radix hexadecimal /aes_engine_top_tb/dut/i_t_keep
add wave -noupdate -expand -group IO -expand -group {axi stream} -radix hexadecimal /aes_engine_top_tb/dut/o_t_data
add wave -noupdate -expand -group IO -expand -group {axi stream} /aes_engine_top_tb/dut/o_t_valid
add wave -noupdate -expand -group IO -expand -group {axi stream} /aes_engine_top_tb/dut/o_t_last
add wave -noupdate -expand -group IO -expand -group {axi stream} -radix hexadecimal /aes_engine_top_tb/dut/o_t_keep
add wave -noupdate -expand -group IO -expand -group {axi stream} /aes_engine_top_tb/dut/o_t_ready
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/lo_spd_cnt_enc
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/expanded_key_lo_q
add wave -noupdate -expand -group {internal values} -radix hexadecimal -childformat {{/aes_engine_top_tb/dut/encrypt(0) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(1) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(2) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(3) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(4) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(5) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(6) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(7) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(8) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(9) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(10) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(11) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(12) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(13) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(14) -radix hexadecimal}} -subitemconfig {/aes_engine_top_tb/dut/encrypt(0) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(1) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(2) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(3) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(4) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(5) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(6) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(7) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(8) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(9) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(10) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(11) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(12) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(13) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(14) {-height 15 -radix hexadecimal}} /aes_engine_top_tb/dut/encrypt
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/decrypt
add wave -noupdate -expand -group {internal values} -radix hexadecimal -childformat {{/aes_engine_top_tb/dut/expanded_key_q(0) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(1) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(2) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(3) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(4) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(5) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(6) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(7) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(8) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(9) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(10) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(11) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(12) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(13) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(14) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(15) -radix hexadecimal}} -subitemconfig {/aes_engine_top_tb/dut/expanded_key_q(0) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(1) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(2) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(3) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(4) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(5) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(6) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(7) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(8) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(9) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(10) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(11) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(12) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(13) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(14) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(15) {-height 15 -radix hexadecimal}} /aes_engine_top_tb/dut/expanded_key_q
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/t_data_q
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/t_data
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/nonce_cnt
add wave -noupdate -expand -group {internal values} /aes_engine_top_tb/dut/last_flag
add wave -noupdate -expand -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/encrypt_input_data
add wave -noupdate -group {control and status} /aes_engine_top_tb/dut/speed_en
add wave -noupdate -group {control and status} -radix unsigned /aes_engine_top_tb/dut/duty_cycle_cnt
add wave -noupdate -group {control and status} -radix unsigned /aes_engine_top_tb/dut/en_cnt
add wave -noupdate -group {control and status} /aes_engine_top_tb/dut/new_key
add wave -noupdate -group {control and status} -radix unsigned /aes_engine_top_tb/dut/flushout_cnt
add wave -noupdate -group {control and status} /aes_engine_top_tb/dut/state
add wave -noupdate -group {control and status} -radix hexadecimal /aes_engine_top_tb/dut/key_handle_q
add wave -noupdate -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/mode
add wave -noupdate -group {control and status} -expand -group configuration -radix hexadecimal /aes_engine_top_tb/dut/iv
add wave -noupdate -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/aes_mode
add wave -noupdate -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/en_decr
add wave -noupdate -group {control and status} /aes_engine_top_tb/dut/o_done
add wave -noupdate -group BRAM /aes_engine_top_tb/dut/u_bram_keys/clka
add wave -noupdate -group BRAM /aes_engine_top_tb/dut/u_bram_keys/ena
add wave -noupdate -group BRAM -radix unsigned /aes_engine_top_tb/dut/u_bram_keys/addra
add wave -noupdate -group BRAM /aes_engine_top_tb/dut/u_bram_keys/douta
add wave -noupdate -group BRAM -radix unsigned /aes_engine_top_tb/dut/i_key_handle
add wave -noupdate -group FIFO -expand -group fifo /aes_engine_top_tb/u_fifo/s_axis_tvalid
add wave -noupdate -group FIFO -expand -group fifo /aes_engine_top_tb/u_fifo/s_axis_tready
add wave -noupdate -group FIFO -expand -group fifo -radix hexadecimal /aes_engine_top_tb/u_fifo/s_axis_tdata
add wave -noupdate -group FIFO -expand -group fifo /aes_engine_top_tb/u_fifo/s_axis_tlast
add wave -noupdate -group FIFO -expand -group master /aes_engine_top_tb/u_fifo/m_axis_tvalid
add wave -noupdate -group FIFO -expand -group master /aes_engine_top_tb/u_fifo/m_axis_tready
add wave -noupdate -group FIFO -expand -group master -radix hexadecimal /aes_engine_top_tb/u_fifo/m_axis_tdata
add wave -noupdate -group FIFO -expand -group master /aes_engine_top_tb/u_fifo/m_axis_tlast
add wave -noupdate -group FIFO /aes_engine_top_tb/u_fifo/almost_empty
add wave -noupdate -group FIFO /aes_engine_top_tb/u_fifo/almost_full
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3150000000 fs} 0} {{Cursor 2} {93917752 fs} 0} {{Cursor 3} {1008621325 fs} 0} {{Cursor 4} {105437663 fs} 0} {{Cursor 5} {374570990 fs} 0} {{Cursor 6} {630000000 fs} 0}
quietly wave cursor active 6
configure wave -namecolwidth 179
configure wave -valuecolwidth 526
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {280535885 fs} {983379635 fs}
