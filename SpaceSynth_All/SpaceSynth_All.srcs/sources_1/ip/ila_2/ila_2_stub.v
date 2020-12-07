// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Sun Dec  6 21:15:11 2020
// Host        : ubuntu running 64-bit Ubuntu 20.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/sage/Space-Synth/SpaceSynth_All/SpaceSynth_All.srcs/sources_1/ip/ila_2/ila_2_stub.v
// Design      : ila_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2019.2" *)
module ila_2(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[16:0],probe1[16:0],probe2[16:0],probe3[16:0],probe4[16:0],probe5[0:0],probe6[10:0]" */;
  input clk;
  input [16:0]probe0;
  input [16:0]probe1;
  input [16:0]probe2;
  input [16:0]probe3;
  input [16:0]probe4;
  input [0:0]probe5;
  input [10:0]probe6;
endmodule
