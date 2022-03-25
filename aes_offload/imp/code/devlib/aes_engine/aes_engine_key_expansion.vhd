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
   generic(
     g_Mode : integer -- Set to desired mode AES128/AES192/AES256 this will have an effect on the number of rounds generated
   );
   port(
      i_clk             : in  std_logic;
      i_rst             : in  std_logic;
      i_key             : in  std_logic_vector(AES256_KEY-1 downto 0);
      o_expanded_key    : out T_EXPANDED_KEYS := (others => (others => '0'))   
   );
end entity;

architecture rtl of aes_engine_key_expansion is
   signal expanded_key_192                                                      : T_EXP_KEYS_192:= (others => (others => '0')); 
   signal expanded_key                                                          : T_EXPANDED_KEYS:= (others => (others => '0'));
   signal left_shift,g_function_input, h_function_input, g_func_out, h_func_out : T_G_FUNC:= (others => (others => '0'));
   signal sbox_out_h, sbox_out_g, sbox_out                                      : T_G_SBOX_ARRAY;
   signal temp_192_assign                                                       : T_TEMP_192:= (others => (others => '0'));
begin

   ------------------------------------------------------------------------
   -- AES128 Key expansion
   ------------------------------------------------------------------------
   gen_128 : for i in 1 to g_Mode generate
      gen_128_keys : if g_Mode = AES128 generate
         o_expanded_key(0)                                     <= i_key(AXI_T_DATA-1 downto 0);
         
         p_reg : process
         begin
            wait until rising_edge(i_clk);
            if i_rst then
               g_function_input(i-1)  <= (others  => '0');
            else
               g_function_input(i-1)  <= o_expanded_key(i-1)(AXI_T_DATA-1  downto expanded_key(i)'length-(BYTE_WIDTH*4));
            end if;
         end process;
                  
         left_shift(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3)   <= g_function_input(i-1)(BYTE_WIDTH-1   downto 0);
         left_shift(i-1)(BYTE_WIDTH-1   downto 0)              <= g_function_input(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH);
         left_shift(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH)     <= g_function_input(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2);
         left_shift(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2)   <= g_function_input(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3);
         
         gen_sbox : for k in 0 to (BYTE_WIDTH/2)-1 generate
            sbox_out(i-1)(k) <= SBOX(to_integer(unsigned(left_shift(i-1)((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH))));
         end generate;
         
         g_func_out(i-1) <= (sbox_out(i-1)(3) & sbox_out(i-1)(2) & sbox_out(i-1)(1) & sbox_out(i-1)(0)) xor ROUND_CONSTS(i-1);   -- output the g function xor with Rcj values 
         
         o_expanded_key(i)(BYTE_WIDTH*4-1  downto 0)             <= g_func_out(i-1)                                        xor o_expanded_key(i-1)(BYTE_WIDTH*4-1  downto 0);
         o_expanded_key(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= o_expanded_key(i)(BYTE_WIDTH*4-1  downto 0)            xor o_expanded_key(i-1)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
         o_expanded_key(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= o_expanded_key(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4) xor o_expanded_key(i-1)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
         o_expanded_key(i)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= o_expanded_key(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8) xor o_expanded_key(i-1)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
      end generate;   
   end generate;
   
   ------------------------------------------------------------------------
   -- AES192 Key expansion
   ------------------------------------------------------------------------
   gen_192 : for i in 1 to g_Mode generate   
      gen_192_keys : if g_Mode = AES192 generate
         expanded_key_192(0)                                   <= i_key(AES192_KEY-1 downto 0);
         
         p_reg : process
         begin
            wait until rising_edge(i_clk);
            if i_rst then
               g_function_input(i-1)  <= (others  => '0');
            else
               g_function_input(i-1)  <= expanded_key_192(i-1)(AES192_KEY-1  downto AES192_KEY-(BYTE_WIDTH*4)); -- Take the last 32 bits of the key
            end if;
         end process;
         
         
         left_shift(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3)   <= g_function_input(i-1)(BYTE_WIDTH-1   downto 0);
         left_shift(i-1)(BYTE_WIDTH-1   downto 0)              <= g_function_input(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH);
         left_shift(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH)     <= g_function_input(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2);
         left_shift(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2)   <= g_function_input(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3);
         
         gen_sbox : for k in 0 to (BYTE_WIDTH/2)-1 generate
            sbox_out(i-1)(k) <= SBOX(to_integer(unsigned(left_shift(i-1)((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH))));
         end generate;
         
         g_func_out(i-1) <= (sbox_out(i-1)(3) & sbox_out(i-1)(2) & sbox_out(i-1)(1) & sbox_out(i-1)(0)) xor ROUND_CONSTS(i-1);   -- output the g function xor with Rcj values 
         
         -- Xor i with i-1
         expanded_key_192(i)(BYTE_WIDTH*4-1  downto 0)             <= g_func_out(i-1)                                           xor expanded_key_192(i-1)(BYTE_WIDTH*4-1  downto 0);
         expanded_key_192(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= expanded_key_192(i)(BYTE_WIDTH*4-1  downto 0)             xor expanded_key_192(i-1)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
         expanded_key_192(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= expanded_key_192(i)(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  xor expanded_key_192(i-1)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
         expanded_key_192(i)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= expanded_key_192(i)(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  xor expanded_key_192(i-1)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
         expanded_key_192(i)(BYTE_WIDTH*20-1 downto BYTE_WIDTH*16) <= expanded_key_192(i)(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) xor expanded_key_192(i-1)(BYTE_WIDTH*20-1 downto BYTE_WIDTH*16);
         expanded_key_192(i)(BYTE_WIDTH*24-1 downto BYTE_WIDTH*20) <= expanded_key_192(i)(BYTE_WIDTH*20-1 downto BYTE_WIDTH*16) xor expanded_key_192(i-1)(BYTE_WIDTH*24-1 downto BYTE_WIDTH*20);
         
         gen_exp_key : for j in 0 to 4 generate
         -- assign 192 bit keys to the usable 128 expanded keys
               o_expanded_key(l(j))   <= expanded_key_192(r(j))(AXI_T_DATA-1 downto 0);
               o_expanded_key(l(j)+1) <= expanded_key_192(r(j)+1)(63 downto 0) & expanded_key_192(r(j))(AES192_KEY-1 downto AXI_T_DATA);
               o_expanded_key(l(j)+2) <= expanded_key_192(r(j)+1)(AES192_KEY-1 downto BYTE_WIDTH*8);
         end generate;
      end generate;
   end generate;
   
   ------------------------------------------------------------------------
   -- AES256 Key expansion
   ------------------------------------------------------------------------
   gen_256 : for i in 1 to g_Mode-7 generate
      gen_256_keys : if g_Mode = AES256 generate
         o_expanded_key(0)     <= i_key(AXI_T_DATA-1 downto 0);
         o_expanded_key(1)     <= i_key(AES256_KEY-1 downto AXI_T_DATA);
         -- take last 32 bits
         --h_function_input(i-1) <= o_expanded_key(h(i))(AXI_T_DATA-1  downto expanded_key(i)'length-(BYTE_WIDTH*4));
         --g_function_input(i-1) <= o_expanded_key(g(i-1))(AXI_T_DATA-1  downto expanded_key(i)'length-(BYTE_WIDTH*4));
         
         p_reg : process
         begin
            wait until rising_edge(i_clk);
            if i_rst then
               h_function_input(i-1)  <= (others  => '0');
               g_function_input(i-1)  <= (others  => '0');
            else
               h_function_input(i-1) <= o_expanded_key(h(i))(AXI_T_DATA-1  downto expanded_key(i)'length-(BYTE_WIDTH*4));
               g_function_input(i-1) <= o_expanded_key(g(i-1))(AXI_T_DATA-1  downto expanded_key(i)'length-(BYTE_WIDTH*4));
            end if;
            end process;
         
         -----------
         -- use g function
         left_shift(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3)   <= g_function_input(i-1)(BYTE_WIDTH-1   downto 0);
         left_shift(i-1)(BYTE_WIDTH-1   downto 0)              <= g_function_input(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH);
         left_shift(i-1)(BYTE_WIDTH*2-1 downto BYTE_WIDTH)     <= g_function_input(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2);
         left_shift(i-1)(BYTE_WIDTH*3-1 downto BYTE_WIDTH*2)   <= g_function_input(i-1)(BYTE_WIDTH*4-1 downto BYTE_WIDTH*3);
         gen_sbox_g : for n in 0 to (BYTE_WIDTH/2)-1 generate
            sbox_out_g(i-1)(n) <= SBOX(to_integer(unsigned(left_shift(i-1)((n + 1)*BYTE_WIDTH-1 downto n*BYTE_WIDTH))));
         end generate;
         -----------
         -- use h function 
         gen_sbox_h : for k in 0 to (BYTE_WIDTH/2)-1 generate
            sbox_out_h(i-1)(k) <= SBOX(to_integer(unsigned(h_function_input(i-1)((k + 1)*BYTE_WIDTH-1 downto k*BYTE_WIDTH))));
         end generate;
         -----------
         g_func_out(i-1) <= (sbox_out_g(i-1)(3) & sbox_out_g(i-1)(2) & sbox_out_g(i-1)(1) & sbox_out_g(i-1)(0)) xor ROUND_CONSTS(i-1);   -- output the g xor with Rcj values every 256 bits.
         -- Xor i with i-1
         o_expanded_key(h(i))(BYTE_WIDTH*4-1  downto 0)             <= g_func_out(i-1)                                           xor o_expanded_key(h(i-1))(BYTE_WIDTH*4-1  downto 0);
         o_expanded_key(h(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= o_expanded_key(h(i))(BYTE_WIDTH*4-1  downto 0)            xor o_expanded_key(h(i-1))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
         o_expanded_key(h(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= o_expanded_key(h(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4) xor o_expanded_key(h(i-1))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
         o_expanded_key(h(i))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= o_expanded_key(h(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8) xor o_expanded_key(h(i-1))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
         -----------
         h_func_out(i-1) <= sbox_out_h(i-1)(3) & sbox_out_h(i-1)(2) & sbox_out_h(i-1)(1) & sbox_out_h(i-1)(0);
         -- Xor i with i-1
         o_expanded_key(g(i))(BYTE_WIDTH*4-1  downto 0)             <= h_func_out(i-1)                                           xor o_expanded_key(g(i-1))(BYTE_WIDTH*4-1  downto 0);
         o_expanded_key(g(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4)  <= o_expanded_key(g(i))(BYTE_WIDTH*4-1  downto 0)            xor o_expanded_key(g(i-1))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4);
         o_expanded_key(g(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8)  <= o_expanded_key(g(i))(BYTE_WIDTH*8-1  downto BYTE_WIDTH*4) xor o_expanded_key(g(i-1))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8);
         o_expanded_key(g(i))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12) <= o_expanded_key(g(i))(BYTE_WIDTH*12-1 downto BYTE_WIDTH*8) xor o_expanded_key(g(i-1))(BYTE_WIDTH*16-1 downto BYTE_WIDTH*12);
         
      end generate;
   end generate;
    
end rtl;
