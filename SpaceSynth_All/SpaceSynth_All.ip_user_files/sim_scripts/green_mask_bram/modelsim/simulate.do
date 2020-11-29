onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.green_mask_bram xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {green_mask_bram.udo}

run -all

quit -force
