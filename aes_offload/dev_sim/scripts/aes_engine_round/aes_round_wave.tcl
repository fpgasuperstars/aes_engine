onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aes_engine_tb/dut/i_plain_txt
add wave -noupdate /aes_engine_tb/dut/o_rndn_cipher_txt
add wave -noupdate /aes_engine_tb/test_msg
add wave -noupdate /aes_engine_tb/rst
add wave -noupdate /aes_engine_tb/clk
add wave -noupdate /aes_engine_tb/last_rnd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7192 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 709
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {2214 ps} {527570 ps}
