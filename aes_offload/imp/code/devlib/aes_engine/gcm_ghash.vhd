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
   generic(
      g_speed_sel : std_logic
   );
   port(
      i_rst                    : in  std_logic;
      i_clk                    : in  std_logic;
      i_ghash_text             : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_j0                     : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_h                      : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_tag_done               : in  std_logic;
      i_speed_en               : in  std_logic;
      i_t_valid                : in  std_logic;
      i_t_ready                : in  std_logic;
      i_t_last                 : in  std_logic;
      i_aad_done               : in  std_logic;
      i_aad_data_present       : in  std_logic;
      o_ghash_tag              : out std_logic_vector(AXI_T_DATA-1 downto 0));
end entity;

architecture arch_gcm_ghash of gcm_ghash is

   -- Signals
   signal x                    : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal y                    : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal y_q                  : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal ghash_tag            : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal tag_done_q           : std_logic;

begin

   --------------------------------------------------------------------------------
   -- Ghash next packet
   --------------------------------------------------------------------------------
   ghash_next_pkt_p : process
   begin
      wait until rising_edge(i_clk);
      tag_done_q  <= i_tag_done;
       if i_rst = '1' then
           y_q <= (others => '0');
       elsif g_speed_sel = '0' and (i_t_ready = '1' or i_t_last = '1') and i_aad_done = '0' then
           -- Save Y to xor with the next incoming X value
           y_q <= y;
       elsif i_tag_done = '1' or (g_speed_sel = '1' and i_speed_en = '1' and (i_t_ready = '1' and (i_aad_data_present = '1' or i_t_valid = '1'))) then
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
       elsif g_speed_sel = '0' and i_tag_done = '1' then
          o_ghash_tag <= ghash_tag;
       elsif g_speed_sel = '1' and tag_done_q = '1' then
           o_ghash_tag <= ghash_tag;
       end if;
   end process;
   -- GF multiply
   y  <= gf_mul_2128(x, i_h);

end architecture;
