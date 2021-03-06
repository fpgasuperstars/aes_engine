onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib aes_engine_key_bram_blk_mem_gen_0_0_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {aes_engine_key_bram_blk_mem_gen_0_0.udo}

run -all

quit -force
