onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib average_divider_opt

do {wave.do}

view wave
view structure
view signals

do {average_divider.udo}

run -all

quit -force
