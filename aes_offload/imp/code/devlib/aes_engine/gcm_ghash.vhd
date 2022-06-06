---------------------------------------------------------------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : gcm_ghash.vhd
-- Creation date : 2022-05-20
-- Author(s) : okeefej
-- Description :
-- This code contains the ghash path calculation for AES-GCM
---------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;
library aes_engine;
use aes_engine.aes_engine_pkg.all;

entity gcm_ghash is
   port(
      i_rst                    : in  std_logic;
      i_clk                    : in  std_logic;
      i_ghash_text             : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_j0                     : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_h                      : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_tag_done               : in  std_logic;
      o_ghash_tag              : out std_logic_vector(AXI_T_DATA-1 downto 0));
end entity;

architecture arch_gcm_ghash of gcm_ghash is

   -- Signals
   signal x                    : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal y                    : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal y_q                  : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal ghash_tag            : std_logic_vector(AXI_T_DATA-1 downto 0);

begin

   --------------------------------------------------------------------------------
   -- Ghash next packet
   --------------------------------------------------------------------------------
   ghash_next_pkt_p : process
   begin
      wait until rising_edge(i_clk);
       if i_rst = '1' then
           y_q <= (others => '0');
       else
           -- Save Y to xor with the next incoming X value
           y_q <= y;
       end if;
   end process;

   -- gfmul: X input
   x         <= i_ghash_text xor y_q;

   -- TAG update result
   ghash_tag <= y_q xor i_j0;

   --------------------------------------------------------------------------------
   -- Sample the ghash tag when aad and cipher text has been processed
   --------------------------------------------------------------------------------
   sample_tag_p : process
   begin
      wait until rising_edge(i_clk);
       if(i_rst = '1') then
           o_ghash_tag <= (others => '0');
       elsif i_tag_done = '1' then
           o_ghash_tag <= ghash_tag;
       end if;
   end process;
   -- GF multiply
   y  <= gf_mul_2128(x, i_h);

end architecture;
