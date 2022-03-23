--Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
--Date        : Wed Mar 23 16:34:13 2022
--Host        : EUL10-797V3J3 running 64-bit major release  (build 9200)
--Command     : generate_target aes_engine_clk_wrapper.bd
--Design      : aes_engine_clk_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity aes_engine_clk_wrapper is
  port (
    CLK_IN1_D_0_clk_n : in STD_LOGIC;
    CLK_IN1_D_0_clk_p : in STD_LOGIC;
    clk_out1_0 : out STD_LOGIC;
    locked_0 : out STD_LOGIC;
    reset_0 : in STD_LOGIC
  );
end aes_engine_clk_wrapper;

architecture STRUCTURE of aes_engine_clk_wrapper is
  component aes_engine_clk is
  port (
    clk_out1_0 : out STD_LOGIC;
    locked_0 : out STD_LOGIC;
    reset_0 : in STD_LOGIC;
    CLK_IN1_D_0_clk_n : in STD_LOGIC;
    CLK_IN1_D_0_clk_p : in STD_LOGIC
  );
  end component aes_engine_clk;
begin
aes_engine_clk_i: component aes_engine_clk
     port map (
      CLK_IN1_D_0_clk_n => CLK_IN1_D_0_clk_n,
      CLK_IN1_D_0_clk_p => CLK_IN1_D_0_clk_p,
      clk_out1_0 => clk_out1_0,
      locked_0 => locked_0,
      reset_0 => reset_0
    );
end STRUCTURE;
