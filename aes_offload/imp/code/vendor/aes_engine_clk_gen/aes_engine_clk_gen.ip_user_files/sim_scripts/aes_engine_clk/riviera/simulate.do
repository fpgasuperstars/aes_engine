onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+aes_engine_clk -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.aes_engine_clk xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {aes_engine_clk.udo}

run -all

endsim

quit -force
