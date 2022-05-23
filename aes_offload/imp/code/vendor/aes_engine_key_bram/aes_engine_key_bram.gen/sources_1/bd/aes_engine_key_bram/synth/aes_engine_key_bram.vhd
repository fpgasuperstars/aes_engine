--Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
--Date        : Mon May 23 10:07:50 2022
--Host        : EUL10-797V3J3 running 64-bit major release  (build 9200)
--Command     : generate_target aes_engine_key_bram.bd
--Design      : aes_engine_key_bram
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity aes_engine_key_bram is
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of aes_engine_key_bram : entity is "aes_engine_key_bram,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=aes_engine_key_bram,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of aes_engine_key_bram : entity is "aes_engine_key_bram.hwdef";
end aes_engine_key_bram;

architecture STRUCTURE of aes_engine_key_bram is
  component aes_engine_key_bram_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 255 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 255 downto 0 )
  );
  end component aes_engine_key_bram_blk_mem_gen_0_0;
  signal NLW_blk_mem_gen_0_douta_UNCONNECTED : STD_LOGIC_VECTOR ( 255 downto 0 );
begin
blk_mem_gen_0: component aes_engine_key_bram_blk_mem_gen_0_0
     port map (
      addra(9 downto 0) => B"0000000000",
      clka => '0',
      dina(255 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000",
      douta(255 downto 0) => NLW_blk_mem_gen_0_douta_UNCONNECTED(255 downto 0),
      ena => '0',
      wea(0) => '0'
    );
end STRUCTURE;
