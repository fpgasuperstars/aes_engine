onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aes_engine_top_tb/test_msg
add wave -noupdate /aes_engine_top_tb/dut/i_clk
add wave -noupdate /aes_engine_top_tb/dut/i_rst
add wave -noupdate -expand -group IO /aes_engine_top_tb/dut/i_t_data
add wave -noupdate -expand -group IO /aes_engine_top_tb/dut/o_t_data
add wave -noupdate -expand -group keys -radix unsigned /aes_engine_top_tb/dut/i_key_handle
add wave -noupdate -expand -group {internal values} -expand /aes_engine_top_tb/dut/rnd_cipher_txt
add wave -noupdate -expand -group {internal values} -expand /aes_engine_top_tb/dut/expanded_key_q
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_last
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_keep
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_valid
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/t_valid_q
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/o_t_valid
add wave -noupdate -expand -group {control and status} /aes_engine_top_tb/dut/speed_en
add wave -noupdate -expand -group {control and status} /aes_engine_top_tb/dut/config_data
add wave -noupdate -expand -group {control and status} -radix unsigned /aes_engine_top_tb/dut/duty_cycle_cnt
add wave -noupdate -expand -group {control and status} -radix unsigned /aes_engine_top_tb/dut/en_cnt
add wave -noupdate -radix unsigned /aes_engine_top_tb/dut/flushout_cnt
add wave -noupdate /aes_engine_top_tb/dut/o_t_ready
add wave -noupdate /aes_engine_top_tb/dut/new_key
add wave -noupdate /aes_engine_top_tb/dut/state
add wave -noupdate /aes_engine_top_tb/dut/t_data_q
add wave -noupdate /aes_engine_top_tb/exp_ct
add wave -noupdate /aes_engine_top_tb/dut/u_bram_keys/U0/native_mem_module/blk_mem_gen_v8_4_5_inst/mif_data
add wave -noupdate -expand -group BRAM /aes_engine_top_tb/dut/u_bram_keys/clka
add wave -noupdate -expand -group BRAM /aes_engine_top_tb/dut/u_bram_keys/ena
add wave -noupdate -expand -group BRAM -radix unsigned /aes_engine_top_tb/dut/u_bram_keys/addra
add wave -noupdate -expand -group BRAM /aes_engine_top_tb/dut/u_bram_keys/douta
add wave -noupdate /aes_engine_top_tb/dut/key_handle_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1070000 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {869073 ps} {1486933 ps}
