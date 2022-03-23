--Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
--Date        : Wed Mar 23 16:34:13 2022
--Host        : EUL10-797V3J3 running 64-bit major release  (build 9200)
--Command     : generate_target aes_engine_clk.bd
--Design      : aes_engine_clk
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity aes_engine_clk is
  port (
    CLK_IN1_D_0_clk_n : in STD_LOGIC;
    CLK_IN1_D_0_clk_p : in STD_LOGIC;
    clk_out1_0 : out STD_LOGIC;
    locked_0 : out STD_LOGIC;
    reset_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of aes_engine_clk : entity is "aes_engine_clk,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=aes_engine_clk,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of aes_engine_clk : entity is "aes_engine_clk.hwdef";
end aes_engine_clk;

architecture STRUCTURE of aes_engine_clk is
  component aes_engine_clk_clk_wiz_0_0 is
  port (
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC;
    reset : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component aes_engine_clk_clk_wiz_0_0;
  signal CLK_IN1_D_0_1_CLK_N : STD_LOGIC;
  signal CLK_IN1_D_0_1_CLK_P : STD_LOGIC;
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal clk_wiz_0_locked : STD_LOGIC;
  signal reset_0_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of CLK_IN1_D_0_clk_n : signal is "xilinx.com:interface:diff_clock:1.0 CLK_IN1_D_0 CLK_N";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of CLK_IN1_D_0_clk_n : signal is "XIL_INTERFACENAME CLK_IN1_D_0, CAN_DEBUG false, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of CLK_IN1_D_0_clk_p : signal is "xilinx.com:interface:diff_clock:1.0 CLK_IN1_D_0 CLK_P";
  attribute X_INTERFACE_INFO of clk_out1_0 : signal is "xilinx.com:signal:clock:1.0 CLK.CLK_OUT1_0 CLK";
  attribute X_INTERFACE_PARAMETER of clk_out1_0 : signal is "XIL_INTERFACENAME CLK.CLK_OUT1_0, CLK_DOMAIN aes_engine_clk_clk_wiz_0_0_clk_out1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of reset_0 : signal is "xilinx.com:signal:reset:1.0 RST.RESET_0 RST";
  attribute X_INTERFACE_PARAMETER of reset_0 : signal is "XIL_INTERFACENAME RST.RESET_0, INSERT_VIP 0, POLARITY ACTIVE_HIGH";
begin
  CLK_IN1_D_0_1_CLK_N <= CLK_IN1_D_0_clk_n;
  CLK_IN1_D_0_1_CLK_P <= CLK_IN1_D_0_clk_p;
  clk_out1_0 <= clk_wiz_0_clk_out1;
  locked_0 <= clk_wiz_0_locked;
  reset_0_1 <= reset_0;
clk_wiz_0: component aes_engine_clk_clk_wiz_0_0
     port map (
      clk_in1_n => CLK_IN1_D_0_1_CLK_N,
      clk_in1_p => CLK_IN1_D_0_1_CLK_P,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => clk_wiz_0_locked,
      reset => reset_0_1
    );
end STRUCTURE;
