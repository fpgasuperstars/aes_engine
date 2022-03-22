---------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_sbox_tb.vhd
-- Creation date : 2022-01-22
-- Author(s) : okeefej
-- Description :
-- This package contains common functions and procedures used in testbenches
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

package aes_engine_tb_pkg is
   
   constant STRING_LENGTH         : positive:= 100;
   constant T_DATA_BYTES          : INTEGER := 16;
   constant RESET_DURATION        : TIME    := 80 ns;
   constant WIDTH_BYTE            : natural := 8;            -- To be used where a byte is declared
   constant DATA_WIDTH_128        : natural := 128;          -- T_data bit width
   constant DATA_WIDTH_192        : natural := 192;          -- 192 key bit width
   constant DATA_WIDTH_256        : natural := 256;          -- 256 key bit width
   -- File locations
   constant CMD_128_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128.txt";
   constant CT_128_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128_ct.txt";
   constant OUT_CT_128_FILE       : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\out_128_ct.txt";
   constant CMD_128_SAME_KEYFILE  : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128_same_key.txt";
   constant CT_128_SAME_KEYFILE   : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128_same_key_ct.txt";
   constant CMD_192_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192.txt";
   constant CT_192_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192_ct.txt";
   constant CMD_192_SAME_KEYFILE  : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192_same_key.txt";
   constant CT_192_SAME_KEYFILE   : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192_same_key_ct.txt";
   constant CMD_256_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256.txt";
   constant CT_256_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256_ct.txt";
   constant CMD_256_SAME_KEYFILE  : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256_same_key.txt";
   constant CT_256_SAME_KEYFILE   : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256_same_key_ct.txt";
   --Keys
   constant KEYS_128_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128_keys.txt";
   constant KEYS_192_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192_keys.txt";
   constant KEYS_256_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256_keys.txt";
   constant KEYS_OUT_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\keys_mem_init.coe";
   
   function pad_string(i_s        : string; pad_char_i : character; i_n : positive) RETURN string;
   function trim(source           : string) return string;
   function reverse_byte_order( a : std_logic_vector) return std_logic_vector; 
   procedure assertion(test_msg_i : string; assertion_msg_i : string; expected_i : std_logic_vector; received_i : std_logic_vector);
   procedure get_inputs(file f_vectors : text; signal in_word, key: out std_logic_vector );
   procedure get_ct(file f_vectors : text; signal exp_ct : out std_logic_vector);
      
end package aes_engine_tb_pkg;

package body aes_engine_tb_pkg is
   
   ------------------------------------------------
   -- Functions
   ------------------------------------------------
   -- Pad String
   function pad_string(i_s : string; pad_char_i : character; i_n : positive) RETURN string IS
     variable v_ps : string(1 TO i_n) := (others => ' ');
   begin
     if i_s'length >= i_n then
       v_ps := i_s(1 to i_n); -- Truncate the source string
     else
       v_ps(1 TO i_s'length) := i_s;
       for i in i_s'high+1 TO i_n loop
         v_ps(i) := pad_char_i; -- add in CHAR to the rest of the string to the n_i
       end loop;
     end if;
     return v_ps;
   end;
  
   -- Remove space characters from trailing ends of source
   function trim(source : string) return string is
      alias src : string(1 TO source'length) is source;
      variable v_rtrim : natural;
   begin
      v_rtrim := src'right;
      for i in src'reverse_range loop
         if src(i) /= ' ' then --not space
            v_rtrim := i;
         exit;
         end if;
      end loop;
      return src(1 to v_rtrim);
   end function;
   
   function reverse_byte_order(a : std_logic_vector) return std_logic_vector is
      variable in_word : std_logic_vector(a'length-1 downto 0);
   begin
         for i in 0 to (a'length/WIDTH_BYTE)-1 loop
            in_word((i + 1)*WIDTH_BYTE-1 downto i*WIDTH_BYTE) := a(((a'length/WIDTH_BYTE)-i)*WIDTH_BYTE-1 downto ((a'length/WIDTH_BYTE-1)-i)*WIDTH_BYTE);
         end loop;
      return in_word;
   end function;
  
   ------------------------------------------------
   -- Procedures
   ------------------------------------------------
   -- Assertion
   procedure assertion(test_msg_i : string; assertion_msg_i : string; expected_i : std_logic_vector; received_i : std_logic_vector) is
   begin
      assert expected_i = received_i
      report trim(test_msg_i) & " - " & assertion_msg_i & " - Expected value: 0x" & to_hstring(expected_i) & ", received value: 0x" & to_hstring(received_i) & " <=== error!!!" & lf
      severity error;
   end;
   
   -- extract input data from FIPS test vectors
   procedure get_inputs(file f_vectors : text; signal in_word, key : out std_logic_vector ) is
      variable v_iline              : line;
      variable v_test_id            : string(1 to 4);
      variable v_space              : character;
      variable v_pt                 : std_logic_vector(in_word'length-1 downto 0);
      variable v_key                : integer;
   begin
      readline(f_vectors, v_iline);
      read(v_iline, v_test_id);
      hread(v_iline, v_pt);
      read(v_iline, v_space);           
      read(v_iline, v_key);   
      in_word   <=  reverse_byte_order(v_pt);  -- reverse order of plain text
      key       <=  std_logic_vector(to_unsigned(v_key,14)); -- get key handle
   end;

   -- extract cipher text data from FIPS test vectors
   procedure get_ct(file f_vectors : text; signal exp_ct : out std_logic_vector ) is
      variable v_iline              : line;
      variable v_test_id            : string(1 to 4);
      variable v_ct                 : std_logic_vector(exp_ct'length-1 downto 0);
   begin
      readline(f_vectors, v_iline);
      read(v_iline, v_test_id);      
      hread(v_iline, v_ct);
      exp_ct    <=  reverse_byte_order(v_ct);  -- reverse order of expected ct
   end;

end package body aes_engine_tb_pkg;
