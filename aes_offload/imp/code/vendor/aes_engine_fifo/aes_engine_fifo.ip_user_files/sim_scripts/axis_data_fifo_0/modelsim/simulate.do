onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_7 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.axis_data_fifo_0 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axis_data_fifo_0.udo}

run -all

quit -force
