onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib aes_engine_key_bram_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {aes_engine_key_bram.udo}

run -all

quit -force
