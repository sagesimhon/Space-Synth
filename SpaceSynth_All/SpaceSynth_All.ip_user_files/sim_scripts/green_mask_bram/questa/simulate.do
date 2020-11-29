onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib green_mask_bram_opt

do {wave.do}

view wave
view structure
view signals

do {green_mask_bram.udo}

run -all

quit -force
