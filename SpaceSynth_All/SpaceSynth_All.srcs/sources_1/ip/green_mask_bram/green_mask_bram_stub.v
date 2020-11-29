// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Fri Nov 27 12:38:26 2020
// Host        : DESKTOP-RLIVKHG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top green_mask_bram -prefix
//               green_mask_bram_ red_mask_bram_stub.v
// Design      : red_mask_bram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module green_mask_bram(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[16:0],dina[0:0],clkb,addrb[16:0],doutb[0:0]" */;
  input clka;
  input [0:0]wea;
  input [16:0]addra;
  input [0:0]dina;
  input clkb;
  input [16:0]addrb;
  output [0:0]doutb;
endmodule
