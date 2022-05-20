onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aes_engine_top_tb/test_msg
add wave -noupdate -expand -group {AES Engine} -group {clk rst} /aes_engine_top_tb/dut/i_rst
add wave -noupdate -expand -group {AES Engine} -group {clk rst} /aes_engine_top_tb/dut/i_clk
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axi stream in} -radix hexadecimal /aes_engine_top_tb/dut/i_t_data
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axi stream in} /aes_engine_top_tb/dut/i_t_valid
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axi stream in} /aes_engine_top_tb/dut/i_t_last
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axi stream in} -radix hexadecimal /aes_engine_top_tb/dut/i_t_keep
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axis out} -radix hexadecimal /aes_engine_top_tb/dut/o_t_data
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axis out} /aes_engine_top_tb/dut/o_t_valid
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axis out} /aes_engine_top_tb/dut/o_t_last
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axis out} -radix hexadecimal /aes_engine_top_tb/dut/o_t_keep
add wave -noupdate -expand -group {AES Engine} -group IO -expand -group {axis out} /aes_engine_top_tb/dut/o_t_ready
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/lo_spd_cnt_enc
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/expanded_key_lo_q
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal -childformat {{/aes_engine_top_tb/dut/encrypt(0) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(1) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(2) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(3) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(4) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(5) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(6) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(7) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(8) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(9) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(10) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(11) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(12) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(13) -radix hexadecimal} {/aes_engine_top_tb/dut/encrypt(14) -radix hexadecimal}} -expand -subitemconfig {/aes_engine_top_tb/dut/encrypt(0) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(1) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(2) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(3) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(4) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(5) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(6) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(7) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(8) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(9) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(10) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(11) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(12) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(13) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/encrypt(14) {-height 15 -radix hexadecimal}} /aes_engine_top_tb/dut/encrypt
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal -childformat {{/aes_engine_top_tb/dut/decrypt(0) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(1) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(2) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(3) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(4) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(5) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(6) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(7) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(8) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(9) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(10) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(11) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(12) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(13) -radix hexadecimal} {/aes_engine_top_tb/dut/decrypt(14) -radix hexadecimal}} -subitemconfig {/aes_engine_top_tb/dut/decrypt(0) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(1) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(2) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(3) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(4) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(5) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(6) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(7) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(8) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(9) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(10) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(11) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(12) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(13) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/decrypt(14) {-height 15 -radix hexadecimal}} /aes_engine_top_tb/dut/decrypt
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal -childformat {{/aes_engine_top_tb/dut/expanded_key_q(0) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(1) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(2) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(3) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(4) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(5) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(6) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(7) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(8) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(9) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(10) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(11) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(12) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(13) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(14) -radix hexadecimal} {/aes_engine_top_tb/dut/expanded_key_q(15) -radix hexadecimal}} -subitemconfig {/aes_engine_top_tb/dut/expanded_key_q(0) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(1) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(2) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(3) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(4) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(5) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(6) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(7) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(8) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(9) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(10) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(11) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(12) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(13) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(14) {-height 15 -radix hexadecimal} /aes_engine_top_tb/dut/expanded_key_q(15) {-height 15 -radix hexadecimal}} /aes_engine_top_tb/dut/expanded_key_q
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/t_data_q
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/t_data
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/nonce_cnt
add wave -noupdate -expand -group {AES Engine} -group {internal values} /aes_engine_top_tb/dut/last_flag
add wave -noupdate -expand -group {AES Engine} -group {internal values} -radix hexadecimal /aes_engine_top_tb/dut/encrypt_input_data
add wave -noupdate -expand -group {AES Engine} -group {control and status} /aes_engine_top_tb/dut/speed_en
add wave -noupdate -expand -group {AES Engine} -group {control and status} -radix unsigned /aes_engine_top_tb/dut/duty_cycle_cnt
add wave -noupdate -expand -group {AES Engine} -group {control and status} -radix unsigned /aes_engine_top_tb/dut/en_cnt
add wave -noupdate -expand -group {AES Engine} -group {control and status} /aes_engine_top_tb/dut/new_key
add wave -noupdate -expand -group {AES Engine} -group {control and status} -radix unsigned /aes_engine_top_tb/dut/flushout_cnt
add wave -noupdate -expand -group {AES Engine} -group {control and status} /aes_engine_top_tb/dut/state
add wave -noupdate -expand -group {AES Engine} -group {control and status} -radix hexadecimal /aes_engine_top_tb/dut/key_handle_q
add wave -noupdate -expand -group {AES Engine} -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/mode
add wave -noupdate -expand -group {AES Engine} -group {control and status} -expand -group configuration -radix hexadecimal /aes_engine_top_tb/dut/iv
add wave -noupdate -expand -group {AES Engine} -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/aes_mode
add wave -noupdate -expand -group {AES Engine} -group {control and status} -expand -group configuration /aes_engine_top_tb/dut/en_decr
add wave -noupdate -expand -group {AES Engine} -group {control and status} /aes_engine_top_tb/dut/o_done
add wave -noupdate -expand -group {AES Engine} -group BRAM /aes_engine_top_tb/dut/u_bram_keys/clka
add wave -noupdate -expand -group {AES Engine} -group BRAM /aes_engine_top_tb/dut/u_bram_keys/ena
add wave -noupdate -expand -group {AES Engine} -group BRAM -radix unsigned /aes_engine_top_tb/dut/u_bram_keys/addra
add wave -noupdate -expand -group {AES Engine} -group BRAM /aes_engine_top_tb/dut/u_bram_keys/douta
add wave -noupdate -expand -group {AES Engine} -group BRAM -radix unsigned /aes_engine_top_tb/dut/i_key_handle
add wave -noupdate -expand -group {AES Engine} -expand -group GCM /aes_engine_top_tb/dut/aad_done
add wave -noupdate -expand -group {AES Engine} -expand -group GCM /aes_engine_top_tb/dut/done_0_enc
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/gf_out
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/ek0_ghash
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/aad_ct_xor
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/pt_length
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/add_length
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/tag
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/pre_tag_xor
add wave -noupdate -expand -group {AES Engine} -expand -group GCM -radix hexadecimal /aes_engine_top_tb/dut/auth_gf
add wave -noupdate -group {FIFO IN} -expand -group slave -color Gold -itemcolor Gold /aes_engine_top_tb/u_fifo_in/s_axis_tvalid
add wave -noupdate -group {FIFO IN} -expand -group slave -color Gold -itemcolor Gold /aes_engine_top_tb/u_fifo_in/s_axis_tready
add wave -noupdate -group {FIFO IN} -expand -group slave -color Gold -itemcolor Gold -radix hexadecimal /aes_engine_top_tb/u_fifo_in/s_axis_tdata
add wave -noupdate -group {FIFO IN} -expand -group slave -color Gold -itemcolor Gold -radix hexadecimal /aes_engine_top_tb/u_fifo_in/s_axis_tkeep
add wave -noupdate -group {FIFO IN} -expand -group slave -color Gold -itemcolor Gold /aes_engine_top_tb/u_fifo_in/s_axis_tlast
add wave -noupdate -group {FIFO IN} -expand -group master -color Gold -itemcolor Gold /aes_engine_top_tb/u_fifo_in/m_axis_tvalid
add wave -noupdate -group {FIFO IN} -expand -group master -color Gold -itemcolor Gold /aes_engine_top_tb/u_fifo_in/m_axis_tready
add wave -noupdate -group {FIFO IN} -expand -group master -color Gold -itemcolor Gold -radix hexadecimal /aes_engine_top_tb/u_fifo_in/m_axis_tdata
add wave -noupdate -group {FIFO IN} -expand -group master -color Gold -itemcolor Gold -radix hexadecimal /aes_engine_top_tb/u_fifo_in/m_axis_tkeep
add wave -noupdate -group {FIFO IN} -expand -group master -color Gold -itemcolor Gold /aes_engine_top_tb/u_fifo_in/m_axis_tlast
add wave -noupdate -group {FIFO OUT} -expand -group slave -color {Medium Blue} -itemcolor {Medium Blue} /aes_engine_top_tb/u_fifo_out/s_axis_tvalid
add wave -noupdate -group {FIFO OUT} -expand -group slave -color {Medium Blue} -itemcolor {Medium Blue} /aes_engine_top_tb/u_fifo_out/s_axis_tready
add wave -noupdate -group {FIFO OUT} -expand -group slave -color {Medium Blue} -itemcolor {Medium Blue} -radix hexadecimal /aes_engine_top_tb/u_fifo_out/s_axis_tdata
add wave -noupdate -group {FIFO OUT} -expand -group slave -color {Medium Blue} -itemcolor {Medium Blue} -radix hexadecimal /aes_engine_top_tb/u_fifo_out/s_axis_tkeep
add wave -noupdate -group {FIFO OUT} -expand -group slave -color {Medium Blue} -itemcolor {Medium Blue} /aes_engine_top_tb/u_fifo_out/s_axis_tlast
add wave -noupdate -group {FIFO OUT} -expand -group master -color {Medium Blue} -itemcolor {Medium Blue} /aes_engine_top_tb/u_fifo_out/m_axis_tvalid
add wave -noupdate -group {FIFO OUT} -expand -group master -color {Medium Blue} -itemcolor {Medium Blue} /aes_engine_top_tb/u_fifo_out/m_axis_tready
add wave -noupdate -group {FIFO OUT} -expand -group master -color {Medium Blue} -itemcolor {Medium Blue} -radix hexadecimal /aes_engine_top_tb/u_fifo_out/m_axis_tdata
add wave -noupdate -group {FIFO OUT} -expand -group master -color {Medium Blue} -itemcolor {Medium Blue} -radix hexadecimal /aes_engine_top_tb/u_fifo_out/m_axis_tkeep
add wave -noupdate -group {FIFO OUT} -expand -group master -color {Medium Blue} -itemcolor {Medium Blue} /aes_engine_top_tb/u_fifo_out/m_axis_tlast
add wave -noupdate /aes_engine_top_tb/dut/config_cnt
add wave -noupdate -radix hexadecimal /aes_engine_top_tb/dut/auth_b4_gf
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19519355133 fs} 0} {{Cursor 2} {93917752 fs} 0} {{Cursor 3} {2482083333 fs} 0} {{Cursor 4} {354420938 fs} 0} {{Cursor 5} {1093458333 fs} 0} {{Cursor 6} {32126601446 fs} 0}
quietly wave cursor active 3
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
WaveRestoreZoom {0 fs} {6037500 ps}
