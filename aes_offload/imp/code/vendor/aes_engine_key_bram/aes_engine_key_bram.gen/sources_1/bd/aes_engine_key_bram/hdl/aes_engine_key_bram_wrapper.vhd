--Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
--Date        : Tue May 24 11:59:49 2022
--Host        : EUL10-797V3J3 running 64-bit major release  (build 9200)
--Command     : generate_target aes_engine_key_bram_wrapper.bd
--Design      : aes_engine_key_bram_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity aes_engine_key_bram_wrapper is
end aes_engine_key_bram_wrapper;

architecture STRUCTURE of aes_engine_key_bram_wrapper is
  component aes_engine_key_bram is
  end component aes_engine_key_bram;
begin
aes_engine_key_bram_i: component aes_engine_key_bram
 ;
end STRUCTURE;
