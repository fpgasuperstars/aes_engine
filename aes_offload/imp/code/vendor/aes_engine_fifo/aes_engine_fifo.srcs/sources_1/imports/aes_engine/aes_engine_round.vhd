---------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_round.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This code contains the AES engine code for a round of encryption
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library aes_engine;
use     aes_engine.aes_engine_pkg.all;

entity aes_engine_round is
   port(
      -- clock and reset
      i_clk             : in  std_logic;
      i_rst             : in  std_logic;
      -- AXI signals
      i_t_valid         : in  std_logic;
      i_t_last          : in  std_logic;
      i_t_keep          : in  std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
      o_t_valid         : out std_logic;
      o_t_last          : out std_logic;
      o_t_keep          : out std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
      -- round signals
      i_last_rnd        : in  std_logic;
      i_expanded_key    : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_plain_txt       : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      o_rndn_cipher_txt : out std_logic_vector(AXI_T_DATA-1 downto 0)    
   );
end entity;

architecture rtl of aes_engine_round is
   signal xor_input, rndn_cipher_txt    : std_logic_vector(AXI_T_DATA-1 downto 0) := (others => '0');
   signal sbox_out, column_mult_by_2, column_mult_by_3, mix_column_out, shift_row_out : T_STATE_ARRAY;
begin

   gen_sbox : for i in 0 to BYTE_WIDTH*2-1 generate
      sbox_out(i)    <= SBOX(to_integer(unsigned(i_plain_txt((i + 1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH))));
   end generate;
   
   p_shift_rows : process(all)
   begin
      -- row3
      shift_row_out(3)  <= sbox_out(15);
      shift_row_out(15) <= sbox_out(11);
      shift_row_out(11) <= sbox_out(7);
      shift_row_out(7)  <= sbox_out(3);
      -- row2            
      shift_row_out(6)  <= sbox_out(14);
      shift_row_out(2)  <= sbox_out(10);
      shift_row_out(14) <= sbox_out(6);
      shift_row_out(10) <= sbox_out(2); 
      -- row1            
      shift_row_out(9)  <= sbox_out(13);
      shift_row_out(5)  <= sbox_out(9);
      shift_row_out(1)  <= sbox_out(5);
      shift_row_out(13) <= sbox_out(1); 
      -- row0           
      shift_row_out(12) <= sbox_out(12);
      shift_row_out(8)  <= sbox_out(8);
      shift_row_out(4)  <= sbox_out(4);
      shift_row_out(0)  <= sbox_out(0);
   end process;
   
   -- Generate vectors of column bytes multiplied by 2 and 3
   gen_mix_column : for i in 0 to BYTE_WIDTH*2-1 generate
      column_mult_by_2(i) <= ((shift_row_out(i)(BYTE_WIDTH-2 downto 0) & '0') xor x"1B") when shift_row_out(i)(7) = '1' else (shift_row_out(i)(BYTE_WIDTH-2 downto 0) & '0');
      column_mult_by_3(i) <= column_mult_by_2(i) xor shift_row_out(i);
   end generate;
   
   -- Bitwise add matrix products                                                                                                    
   gen_mix_column_out : for i in 0 to 3 generate                                                                                                                                              
         mix_column_out(j(i))   <= column_mult_by_2(j(i)) xor column_mult_by_3(j(i)+1) xor shift_row_out(j(i)+2)    xor shift_row_out(j(i)+3);      
         mix_column_out(j(i)+1) <= shift_row_out(j(i))    xor column_mult_by_2(j(i)+1) xor column_mult_by_3(j(i)+2) xor shift_row_out(j(i)+3);      
         mix_column_out(j(i)+2) <= shift_row_out(j(i))    xor shift_row_out(j(i)+1)    xor column_mult_by_2(j(i)+2) xor column_mult_by_3(j(i)+3);   
         mix_column_out(j(i)+3) <= column_mult_by_3(j(i)) xor shift_row_out(j(i)+1)    xor shift_row_out(j(i)+2)    xor column_mult_by_2(j(i)+3);                                                                                                             
   end generate;                                                                                                                     
   
   -- Concatenate the array bytes to a std_logic_vector so it can be used for Xor function
   gen_concat : for i in 0 to BYTE_WIDTH*2-1 generate
      xor_input((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= mix_column_out(i) when i_last_rnd = '0' else shift_row_out(i); -- on last round skip the mixcolumn
   end generate;
   
   -- Bitwise Xor expanded key and mix columns or left shift on last round
   rndn_cipher_txt <= i_expanded_key xor xor_input; -- i_expanded_key and xor_input_q are signals on the same syncronous clock
   
   p_reg_out : process
   begin
      wait until rising_edge(i_clk);
         if i_rst then
            o_t_valid         <= '0';
            o_t_last          <= '0';
            o_t_keep          <= (others => '0');
            o_rndn_cipher_txt <= (others => '0');
         else
            o_t_valid         <= i_t_valid;  
            o_t_last          <= i_t_last;    
            o_t_keep          <= i_t_keep;    
            o_rndn_cipher_txt <= rndn_cipher_txt;
         end if;
   end process;
   
   
end rtl;