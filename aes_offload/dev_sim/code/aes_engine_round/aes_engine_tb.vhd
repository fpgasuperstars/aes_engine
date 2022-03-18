---------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_tb.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This testbench tests the functionality of the sbox
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library aes_engine;
use     aes_engine.aes_engine_pkg.all;

library tb_lib;
use     tb_lib.aes_engine_tb_pkg.all;

entity aes_engine_tb is
   generic (
      g_test_cases : std_ulogic_vector(31 downto 0) := x"FFFFFFFF"
   );
end entity;

architecture sim of aes_engine_tb is
   
   signal out_word, in_word, expanded_key  : std_logic_vector(AXI_T_DATA-1 downto 0) := (others => '0');
   signal test_msg                         : string(1 to STRING_LENGTH);
   signal sbox_out_array, shift_row_out    : T_STATE_ARRAY;
   signal rst, clk, last_rnd               : std_logic := '0';
   
  
begin
   
   sbox_out_array <= <<signal dut.sbox_out      : T_STATE_ARRAY>>;
   
   dut : entity aes_engine.aes_engine_round
      port map(
         i_clk             => clk,
         i_rst             => rst,
         i_expanded_key    => expanded_key,
         i_plain_txt       => in_word,
         i_last_rnd        => last_rnd,
         o_rndn_cipher_txt => out_word
      );
      
   p_clk : process
   begin
      clk <= '1';
      wait for 2500 ps;
      clk <= '0';
      wait for 2500 ps;
   end process;
   
   p_rst : process
   begin
      rst <= '1';
      wait for RESET_DURATION;
      rst <= '0';
      wait;
   end process;   
      
   p_main_tests : process
   begin
   ----------------------------------------------------------------------------------
   -- Test case 1
   ----------------------------------------------------------------------------------
      if g_test_cases(0) = '1' then
         test_msg <= pad_string(" Test case 1 : sbox substitution all values", ' ', STRING_LENGTH);
         wait for 0 ns;
         report lf & lf & test_msg & lf;
         in_word <= (others => '0');
         wait for RESET_DURATION;
         for k in 0 to T_DATA_BYTES-1 loop
            for i in 0 to 2**BYTE_WIDTH-2 loop
               wait until rising_edge(clk);
               assertion(test_msg, "full range", SBOX(i), sbox_out_array(k));
               in_word((k+1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH) <= std_logic_vector(unsigned(in_word((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH)) + 1);
            end loop;
         end loop;
         
         wait for 10 ns;
      end if;
      
      ----------------------------------------------------------------------------------
      -- Test case 2
      ----------------------------------------------------------------------------------
      if g_test_cases(1) = '1' then
         test_msg <= pad_string(" Test case 2 : empty", ' ', STRING_LENGTH);
         wait for 0 ns;
         report lf & lf & test_msg & lf;

      end if;
      
      -- stop simulation
      assert false report "END OF SIMULATION!" severity failure;
      wait;
   
   end process;

end sim;
