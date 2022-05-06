---------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_decrypt.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This code contains the AES engine code for a round of decryption
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library aes_engine;
use     aes_engine.aes_engine_pkg.all;

entity aes_engine_decrypt is
   port(
      -- clock and reset
      i_clk             : in  std_logic;
      i_rst             : in  std_logic;
      -- round signals
      i_last_rnd        : in  std_logic;
      i_expanded_key    : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_cipher_txt      : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      o_rndn_plain_txt  : out std_logic_vector(AXI_T_DATA-1 downto 0)    
   );
end entity;

architecture rtl of aes_engine_decrypt is
   signal rnd_out, sub_vec, rndn_plain_txt, rndn_key, mix_column_vect : std_logic_vector(AXI_T_DATA-1 downto 0) := (others => '0');
   signal sbox_out, column_mult_9, column_mult_11, column_mult_13, column_mult_14, mix_column_out, shift_row_out : T_STATE_ARRAY;
begin

   gen_sbox : for i in 0 to BYTE_WIDTH*2-1 generate
      sbox_out(i)    <= SBOX_INV(to_integer(unsigned(shift_row_out(i))));
   end generate;
   
   p_shift_rows : process(all)
   begin
      -- row3
      shift_row_out(15)<= i_cipher_txt((3  + 1)*BYTE_WIDTH-1 downto 3 *BYTE_WIDTH) ;
      shift_row_out(11)<= i_cipher_txt((15 + 1)*BYTE_WIDTH-1 downto 15*BYTE_WIDTH);
      shift_row_out(7) <= i_cipher_txt((11 + 1)*BYTE_WIDTH-1 downto 11*BYTE_WIDTH);
      shift_row_out(3) <= i_cipher_txt((7  + 1)*BYTE_WIDTH-1 downto 7 *BYTE_WIDTH) ;
      -- row2                         
      shift_row_out(14)<= i_cipher_txt((6 + 1)*BYTE_WIDTH-1 downto  6 *BYTE_WIDTH) ;
      shift_row_out(10)<= i_cipher_txt((2 + 1)*BYTE_WIDTH-1 downto  2 *BYTE_WIDTH) ;
      shift_row_out(6) <= i_cipher_txt((14 + 1)*BYTE_WIDTH-1 downto 14*BYTE_WIDTH);
      shift_row_out(2) <= i_cipher_txt((10 + 1)*BYTE_WIDTH-1 downto 10*BYTE_WIDTH);
      -- row1                         
      shift_row_out(13)<= i_cipher_txt((9 + 1)*BYTE_WIDTH-1 downto  9 *BYTE_WIDTH) ;
      shift_row_out(9) <= i_cipher_txt((5 + 1)*BYTE_WIDTH-1 downto  5 *BYTE_WIDTH) ;
      shift_row_out(5) <= i_cipher_txt((1 + 1)*BYTE_WIDTH-1 downto  1 *BYTE_WIDTH) ;
      shift_row_out(1) <= i_cipher_txt((13 + 1)*BYTE_WIDTH-1 downto 13*BYTE_WIDTH);
      -- row0                         
      shift_row_out(12)<= i_cipher_txt((12 + 1)*BYTE_WIDTH-1 downto 12*BYTE_WIDTH);
      shift_row_out(8) <= i_cipher_txt((8 + 1)*BYTE_WIDTH-1 downto  8 *BYTE_WIDTH) ;
      shift_row_out(4) <= i_cipher_txt((4 + 1)*BYTE_WIDTH-1 downto  4 *BYTE_WIDTH) ;
      shift_row_out(0) <= i_cipher_txt((0 + 1)*BYTE_WIDTH-1 downto  0 *BYTE_WIDTH) ;
   end process;
   
   -- Generate vectors of column bytes multiplied by 2 and 3
   gen_mix_column : for i in 0 to BYTE_WIDTH*2-1 generate
      column_mult_9(i)    <= (MULT_9(to_integer(unsigned(rndn_key((i + 1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH)))));
      column_mult_11(i)   <= (MULT_11(to_integer(unsigned(rndn_key((i + 1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH))))); 
      column_mult_13(i)   <= (MULT_13(to_integer(unsigned(rndn_key((i + 1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH))))); 
      column_mult_14(i)   <= (MULT_14(to_integer(unsigned(rndn_key((i + 1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH))))); 
   end generate;
   
   -- Bitwise add matrix products                                                                                                    
   gen_mix_column_out : for i in 0 to 3 generate                                                                                                                                              
      mix_column_out(j(i))   <= column_mult_14(j(i))   xor column_mult_11(j(i)+1) xor column_mult_13(j(i)+2) xor column_mult_9(j(i)+3);      
      mix_column_out(j(i)+1) <= column_mult_9(j(i))    xor column_mult_14(j(i)+1) xor column_mult_11(j(i)+2) xor column_mult_13(j(i)+3);      
      mix_column_out(j(i)+2) <= column_mult_13(j(i))   xor column_mult_9(j(i)+1)  xor column_mult_14(j(i)+2) xor column_mult_11(j(i)+3);   
      mix_column_out(j(i)+3) <= column_mult_11(j(i))   xor column_mult_13(j(i)+1) xor column_mult_9(j(i)+2)  xor column_mult_14(j(i)+3);                                                                                                             
   end generate;                                                                                                                     
   
   -- Concatenate the array bytes to a std_logic_vector so it can be used for Xor function
   gen_concat : for i in 0 to BYTE_WIDTH*2-1 generate
      sub_vec((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH)         <= sbox_out(i); 
      mix_column_vect((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= mix_column_out(i); 
   end generate;
   
   rnd_out <= mix_column_vect when i_last_rnd = '0' else rndn_key; -- on last round skip the mixcolumn
   
   -- Bitwise Xor expanded key with sbox
   rndn_key <= i_expanded_key xor sub_vec; 
   
   p_reg_out : process
   begin
      wait until rising_edge(i_clk);
         if i_rst then
            o_rndn_plain_txt  <= (others => '0');
         else
            o_rndn_plain_txt  <= rnd_out;
         end if;
   end process;
   
   
end rtl;