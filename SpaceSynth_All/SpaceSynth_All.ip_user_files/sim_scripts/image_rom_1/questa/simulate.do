onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib image_rom_1_opt

do {wave.do}

view wave
view structure
view signals

do {image_rom_1.udo}

run -all

quit -force
