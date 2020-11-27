# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param tcl.collectionResultDisplayLimit 0
set_param xicom.use_bs_reader 1
set_msg_config -id {Common 17-41} -limit 10000000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/sage/camera/camera.cache/wt [current_project]
set_property parent.project_path /home/sage/camera/camera.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
set_property ip_output_repo /home/sage/camera/camera.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib -sv {
  /home/sage/camera/camera.srcs/sources_1/imports/Downloads/camera_read.sv
  /home/sage/camera/camera.srcs/sources_1/new/camera_to_mask.sv
  /home/sage/camera/camera.srcs/sources_1/imports/Downloads/rgb_to_hsv.sv
  /home/sage/camera/camera.srcs/sources_1/imports/Downloads/top_level_cam.sv
  /home/sage/camera/camera.srcs/sources_1/new/clean_top_level.sv
}
read_verilog -library xil_defaultlib /home/sage/camera/camera.srcs/sources_1/imports/Downloads/clk_wiz_lab3.v
read_ip -quiet /home/sage/camera/camera.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci
set_property used_in_implementation false [get_files -all /home/sage/camera/camera.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_ooc.xdc]

read_ip -quiet /home/sage/camera/camera.srcs/sources_1/ip/div_gen_0/div_gen_0.xci
set_property used_in_implementation false [get_files -all /home/sage/camera/camera.srcs/sources_1/ip/div_gen_0/div_gen_0_ooc.xdc]

read_ip -quiet /home/sage/camera/camera.srcs/sources_1/ip/ila_0/ila_0.xci
set_property used_in_synthesis false [get_files -all /home/sage/camera/camera.srcs/sources_1/ip/ila_0/ila_v6_2/constraints/ila_impl.xdc]
set_property used_in_implementation false [get_files -all /home/sage/camera/camera.srcs/sources_1/ip/ila_0/ila_v6_2/constraints/ila_impl.xdc]
set_property used_in_implementation false [get_files -all /home/sage/camera/camera.srcs/sources_1/ip/ila_0/ila_v6_2/constraints/ila.xdc]
set_property used_in_implementation false [get_files -all /home/sage/camera/camera.srcs/sources_1/ip/ila_0/ila_0_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/sage/camera/camera.srcs/constrs_1/imports/Downloads/nexys4ddr.xdc
set_property used_in_implementation false [get_files /home/sage/camera/camera.srcs/constrs_1/imports/Downloads/nexys4ddr.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top clean_top_level -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef clean_top_level.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file clean_top_level_utilization_synth.rpt -pb clean_top_level_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
