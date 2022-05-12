----------------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_key_expansion.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This code contains configurable code for expanding the key used in each round of encryption
----------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library aes_engine;
use     aes_engine.aes_engine_pkg.all;

entity aes_engine_key_expansion is
   port(
      i_clk             : in  std_logic;
      i_rst             : in  std_logic;
      i_key             : in  std_logic_vector(AES256_KEY-1 downto 0);
      i_mode            : in  std_logic_vector(AES_MODE_C-1 downto 0);
      o_expanded_key    : out T_EXPANDED_KEYS := (others => (others => '0'))   
   );
end entity;

architecture rtl of aes_engine_key_expansion is
   signal expanded_key_192                                                      : T_EXP_KEYS_192:= (others => (others => '0')); 
   signal expanded_key_128, expanded_key_19, expanded_key_256, expanded_key     : T_EXPANDED_KEYS:= (others => (others => '0')); 
   signal left_shift_256, left_shift_128, left_shift_192, g_function_input_256, h_function_input_256, g_func_out_256, g_func_out_256_q, h_func_out_256, h_func_out_256_q, g_function_input_192, g_func_out_192, g_func_out_192_q, g_function_input_128, g_func_out_128, g_func_out_128_q, h_func_out_128 : T_G_FUNC;
   signal sbox_out_h_256, sbox_out_g_256, sbox_out, sbox_out_192, sbox_out_128  : T_G_SBOX_ARRAY;
   signal temp_192_assign                                                       : T_TEMP_192:= (others => (others => '0'));
   signal key_128, key_192,key_256, key_q                                       : std_logic_vector(AES256_KEY-1 downto 0);
begin

   p_key_selection : process
   begin
      wait until rising_edge(i_clk);
      key_q <= i_key;
      if i_mode    = "00" then
         o_expanded_key  <= expanded_key_128;
      elsif i_mode = "01" then
         o_expanded_key  <= expanded_key_19; 
      elsif i_mode = "10" then
         o_expanded_key  <= expanded_key_256;
      else
         o_expanded_key  <= (others  => (others  => '0'));
      end if;
   end process;

   
   ------------------------------------------------------------------------
   -- AES128 Key expansion
   ------------------------------------------------------------------------
   gen_128 : for i in 1 to AES128 generate
      expanded_key_128(0)        <= key_q(AXI_T_DATA-1 downto 0);
      
      g_function_input_128(i-1)  <= expanded_key_128(i-1)(AXI_T_DATA-1  downto expanded_key_128(i)'length-(BYTE_WIDTH*4));
               
      left_shift_128(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3)   <= g_function_input_128(i-1)(BYTE_WIDTH-1   downto 0);
      left_shift_128(i-1)(BYTE_WIDTH-1   downto 0)              <= g_function_input_128(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH);
      left_shift_128(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH)     <= g_function_input_128(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2);
      left_shift_128(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2)   <= g_function_input_128(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3);
      
      gen_sbox : for k in 0 to (BYTE_WIDTH/2)-1 generate
         sbox_out_128(i-1)(k) <= SBOX(to_integer(unsigned(left_shift_128(i-1)((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH))));
      end generate;
      
      g_func_out_128(i-1)     <= (sbox_out_128(i-1)(3) & sbox_out_128(i-1)(2) & sbox_out_128(i-1)(1) & sbox_out_128(i-1)(0)) xor ROUND_CONSTS(i-1);   -- output the g function xor with Rcj values 
      
      p_reg : process
      begin
         wait until rising_edge(i_clk);
         g_func_out_128_q(i-1) <= g_func_out_128(i-1);
      end process;
      
      expanded_key_128(i)(BYTE_WIDTH*4-1  downto 0)             <= g_func_out_128_q(i-1)                                    xor expanded_key_128(i-1)(BYTE_WIDTH*4-1  downto 0);
      expanded_key_128(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= expanded_key_128(i)(BYTE_WIDTH*4-1  downto 0)            xor expanded_key_128(i-1)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
      expanded_key_128(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= expanded_key_128(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4) xor expanded_key_128(i-1)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
      expanded_key_128(i)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= expanded_key_128(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8) xor expanded_key_128(i-1)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
         
   end generate;   
      
   ----------------------------------------------------------------------
   --AES192 Key expansion
   ----------------------------------------------------------------------
   gen_192 : for i in 1 to AES192 generate   
      expanded_key_192(0)        <= key_q(AES192_KEY-1 downto 0);
      
      g_function_input_192(i-1)  <= expanded_key_192(i-1)(AES192_KEY-1  downto AES192_KEY-(BYTE_WIDTH*4)); -- Take the last 32 bits of the key
      
      left_shift_192(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3)   <= g_function_input_192(i-1)(BYTE_WIDTH-1   downto 0);
      left_shift_192(i-1)(BYTE_WIDTH-1   downto 0)              <= g_function_input_192(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH);
      left_shift_192(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH)     <= g_function_input_192(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2);
      left_shift_192(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2)   <= g_function_input_192(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3);
      
      gen_sbox : for k in 0 to (BYTE_WIDTH/2)-1 generate
         sbox_out_192(i-1)(k) <= SBOX(to_integer(unsigned(left_shift_192(i-1)((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH))));
      end generate;
      
      g_func_out_192(i-1) <= (sbox_out_192(i-1)(3) & sbox_out_192(i-1)(2) & sbox_out_192(i-1)(1) & sbox_out_192(i-1)(0)) xor ROUND_CONSTS(i-1);   -- output the g function xor with Rcj values 
      
      
      p_reg : process
      begin
         wait until rising_edge(i_clk);
         g_func_out_192_q(i-1) <= g_func_out_192(i-1);
      end process;
      
      -- Xor i with i-1
      expanded_key_192(i)(BYTE_WIDTH*4-1  downto 0)             <= g_func_out_192_q(i-1)                                     xor expanded_key_192(i-1)(BYTE_WIDTH*4-1  downto 0);
      expanded_key_192(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= expanded_key_192(i)(BYTE_WIDTH*4-1  downto 0)             xor expanded_key_192(i-1)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
      expanded_key_192(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= expanded_key_192(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  xor expanded_key_192(i-1)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
      expanded_key_192(i)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= expanded_key_192(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  xor expanded_key_192(i-1)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
      expanded_key_192(i)(BYTE_WIDTH*20-1 downto BYTE_WIDTH*16) <= expanded_key_192(i)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) xor expanded_key_192(i-1)(BYTE_WIDTH*20-1 downto BYTE_WIDTH*16);
      expanded_key_192(i)(BYTE_WIDTH*24-1 downto BYTE_WIDTH*20) <= expanded_key_192(i)(BYTE_WIDTH*20-1 downto BYTE_WIDTH*16) xor expanded_key_192(i-1)(BYTE_WIDTH*24-1 downto BYTE_WIDTH*20);
      
      gen_exp_key : for j in 0 to 4 generate
      -- assign 192 bit keys to the usable 128 expanded keys
            expanded_key_19(l(j))   <= expanded_key_192(r(j))(AXI_T_DATA-1 downto 0);
            expanded_key_19(l(j)+1) <= expanded_key_192(r(j)+1)(63 downto 0) & expanded_key_192(r(j))(AES192_KEY-1 downto AXI_T_DATA);
            expanded_key_19(l(j)+2) <= expanded_key_192(r(j)+1)(AES192_KEY-1 downto BYTE_WIDTH*8);
      end generate;
   end generate;
   
   ------------------------------------------------------------------------
   -- AES256 Key expansion
   ------------------------------------------------------------------------
   gen_256 : for i in 1 to AES256-7 generate
      expanded_key_256(0)     <= key_q(AXI_T_DATA-1 downto 0);
      expanded_key_256(1)     <= key_q(AES256_KEY-1 downto AXI_T_DATA);
      -- take last 32 bits
      
      h_function_input_256(i-1) <= expanded_key_256(h(i))(AXI_T_DATA-1  downto expanded_key_256(i)'length-(BYTE_WIDTH*4));
      g_function_input_256(i-1) <= expanded_key_256(g(i-1))(AXI_T_DATA-1  downto expanded_key_256(i)'length-(BYTE_WIDTH*4));
      
      -----------
      -- use g function
      left_shift_256(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3)   <= g_function_input_256(i-1)(BYTE_WIDTH-1   downto 0);
      left_shift_256(i-1)(BYTE_WIDTH-1   downto 0)              <= g_function_input_256(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH);
      left_shift_256(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH)     <= g_function_input_256(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2);
      left_shift_256(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2)   <= g_function_input_256(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3);
      gen_sbox_g : for n in 0 to (BYTE_WIDTH/2)-1 generate
         sbox_out_g_256(i-1)(n) <= SBOX(to_integer(unsigned(left_shift_256(i-1)((n + 1)*BYTE_WIDTH-1 downto n*BYTE_WIDTH))));
      end generate;
      -----------
      -- use h function 
      gen_sbox_h : for k in 0 to (BYTE_WIDTH/2)-1 generate
         sbox_out_h_256(i-1)(k) <= SBOX(to_integer(unsigned(h_function_input_256(i-1)((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH))));
      end generate;
      
      p_reg : process
      begin
         wait until rising_edge(i_clk);
         g_func_out_256_q(i-1) <= g_func_out_256(i-1);
         h_func_out_256_q(i-1) <= h_func_out_256(i-1);
      end process;
      
      -----------
      g_func_out_256(i-1) <= (sbox_out_g_256(i-1)(3) & sbox_out_g_256(i-1)(2) & sbox_out_g_256(i-1)(1) & sbox_out_g_256(i-1)(0)) xor ROUND_CONSTS(i-1);   -- output the g xor with Rcj values every 256 bits.
      -- Xor i with i-1
      expanded_key_256(h(i))(BYTE_WIDTH*4-1  downto 0)             <= g_func_out_256_q(i-1)                                       xor expanded_key_256(h(i-1))(BYTE_WIDTH*4-1  downto 0);
      expanded_key_256(h(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= expanded_key_256(h(i))(BYTE_WIDTH*4-1  downto 0)            xor expanded_key_256(h(i-1))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
      expanded_key_256(h(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= expanded_key_256(h(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4) xor expanded_key_256(h(i-1))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
      expanded_key_256(h(i))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= expanded_key_256(h(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8) xor expanded_key_256(h(i-1))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
      -----------
      h_func_out_256(i-1) <= sbox_out_h_256(i-1)(3) & sbox_out_h_256(i-1)(2) & sbox_out_h_256(i-1)(1) & sbox_out_h_256(i-1)(0);
      -- Xor i with i-1
      expanded_key_256(g(i))(BYTE_WIDTH*4-1  downto 0)             <= h_func_out_256_q(i-1)                                       xor expanded_key_256(g(i-1))(BYTE_WIDTH*4-1  downto 0);
      expanded_key_256(g(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= expanded_key_256(g(i))(BYTE_WIDTH*4-1  downto 0)            xor expanded_key_256(g(i-1))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
      expanded_key_256(g(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= expanded_key_256(g(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4) xor expanded_key_256(g(i-1))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
      expanded_key_256(g(i))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= expanded_key_256(g(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8) xor expanded_key_256(g(i-1))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
         
   end generate;
   
end rtl;