-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
-- Date        : Sun Dec  6 21:15:11 2020
-- Host        : ubuntu running 64-bit Ubuntu 20.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/sage/Space-Synth/SpaceSynth_All/SpaceSynth_All.srcs/sources_1/ip/ila_2/ila_2_stub.vhdl
-- Design      : ila_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_2 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 16 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 16 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 16 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 16 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 16 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe6 : in STD_LOGIC_VECTOR ( 10 downto 0 )
  );

end ila_2;

architecture stub of ila_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[16:0],probe1[16:0],probe2[16:0],probe3[16:0],probe4[16:0],probe5[0:0],probe6[10:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2019.2";
begin
end;
