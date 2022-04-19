onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aes_engine_top_tb/test_msg
add wave -noupdate /aes_engine_top_tb/dut/i_clk
add wave -noupdate /aes_engine_top_tb/dut/i_rst
add wave -noupdate -expand -group IO /aes_engine_top_tb/dut/i_t_data
add wave -noupdate -expand -group IO /aes_engine_top_tb/dut/o_t_data
add wave -noupdate /aes_engine_top_tb/exp_ct
add wave -noupdate -expand -group {internal values} /aes_engine_top_tb/dut/encrypt
add wave -noupdate -expand -group {internal values} /aes_engine_top_tb/dut/decrypt
add wave -noupdate -expand -group {internal values} /aes_engine_top_tb/dut/expanded_key_q
add wave -noupdate -expand -group {internal values} /aes_engine_top_tb/dut/t_data_q
add wave -noupdate /aes_engine_top_tb/dut/dec_expanded_key_q
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_last
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_keep
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/i_t_valid
add wave -noupdate -expand -group {axi stream} /aes_engine_top_tb/dut/o_t_ready
add wave -noupdate -expand -group {control and status} /aes_engine_top_tb/dut/speed_en
add wave -noupdate -expand -group {control and status} -radix unsigned /aes_engine_top_tb/dut/duty_cycle_cnt
add wave -noupdate -expand -group {control and status} -radix unsigned /aes_engine_top_tb/dut/en_cnt
add wave -noupdate -expand -group {control and status} /aes_engine_top_tb/dut/new_key
add wave -noupdate -expand -group {control and status} -radix unsigned /aes_engine_top_tb/dut/flushout_cnt
add wave -noupdate -expand -group {control and status} /aes_engine_top_tb/dut/state
add wave -noupdate -expand -group {control and status} /aes_engine_top_tb/dut/key_handle_q
add wave -noupdate -expand -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/mode
add wave -noupdate -expand -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/iv
add wave -noupdate -expand -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/aes_mode
add wave -noupdate -expand -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/en_decr
add wave -noupdate -group BRAM /aes_engine_top_tb/dut/u_bram_keys/clka
add wave -noupdate -group BRAM /aes_engine_top_tb/dut/u_bram_keys/ena
add wave -noupdate -group BRAM -radix unsigned /aes_engine_top_tb/dut/u_bram_keys/addra
add wave -noupdate -group BRAM /aes_engine_top_tb/dut/u_bram_keys/douta
add wave -noupdate -group BRAM -radix unsigned /aes_engine_top_tb/dut/i_key_handle
add wave -noupdate /aes_engine_top_tb/dut/dec_expanded_key_q
add wave -noupdate /aes_engine_top_tb/dut/last_rnd_dec
add wave -noupdate /aes_engine_top_tb/dut/gen_encryption_rounds(5)/u_enc_rnds/o_rndn_cipher_txt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {508007064 ps}
