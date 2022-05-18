---------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_tb_pkg.vhd
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
   constant MODE256               : natural := 14;          
   constant MODE192               : natural := 12;          
   constant MODE128               : natural := 10;          
   -- File locations
   -- commands
   constant CMD_128_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128.txt";
   constant CT_128_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128_ct.txt";
   constant CMD_192_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192.txt";
   constant CT_192_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192_ct.txt";
   constant CMD_256_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256.txt";
   constant CT_256_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256_ct.txt";
   constant CMD_GCM_FILE          : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\gcm_mode.txt";
   constant CT_GCM_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\gcm_mode_ct.txt";
   constant AD_GCM_FILE           : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\gcm_mode_aad.txt";
   --Keys
   constant KEYS_128_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\128_keys.txt";
   constant KEYS_192_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\192_keys.txt";
   constant KEYS_256_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\256_keys.txt";
   constant KEYS_OUT_FILE         : string  := "C:\git\aes_engine\aes_offload\dev_sim\code\aes_engine_top\keys_mem_init.coe";
   
   -- Files
   -- AES 128 files
   file f_128_vectors             : text;
   file f_ct_vectors              : text;
   -- AES 192 files
   file f_192_vectors             : text;
   file f_192_ct_vectors          : text;
   -- AES 256 files
   file f_256_vectors             : text;
   file f_256_ct_vectors          : text;
   -- Generate .coe file for BRAM
   file f_keys_128                : text;
   file f_keys_192                : text;
   file f_keys_256                : text;
   file f_output_keys             : text;
   constant header1               : string := " ;The data memory generated is";
   constant header2               : string := " MEMORY_INITIALIZATION_RADIX=16;";
   constant header3               : string := " MEMORY_INITIALIZATION_VECTOR= 00000000000000000000000000000000,";
   constant comma                 : string := ",";
   -- GCM mode test files
   file f_gcm_ct_vectors          : text;
   file f_gcm_vectors             : text;
   file f_gcm_ad                  : text;
   
   type T_GCM_EXP  is array (0 TO T_DATA_BYTES+1) of std_logic_vector(DATA_WIDTH_128-1 downto 0);
   signal ct_gcm_arr : T_GCM_EXP;
   function pad_string(i_s                 : string; pad_char_i : character; i_n : positive) RETURN string;
   function trim(source                    : string) return string;
   function reverse_byte_order( a          : std_logic_vector) return std_logic_vector; 
   procedure assertion(test_msg_i          : string; assertion_msg_i : string; expected_i : std_logic_vector; received_i : std_logic_vector);
   procedure get_inputs(file f_vectors     : text; signal in_word, key: out std_logic_vector;signal last : out std_logic; signal t_keep : out std_logic_vector  );
   procedure get_ct(file f_vectors         : text; signal exp_ct      : out std_logic_vector);
   procedure get_gcm_inputs(file f_vectors, f_ct : text; signal leng_pt : in integer; signal clk, t_valid, t_ready : in std_logic; signal ct_result : in std_logic_vector;  signal in_word, key, exp_ct: out std_logic_vector; signal ct_gcm_arr: out T_GCM_EXP);
   procedure assertion_array(test_msg_i : string; assertion_msg_i : string; expected_i : T_GCM_EXP; received_i : T_GCM_EXP);   
   procedure test(file f_vectors : text; PATH : string; signal t_ready, clk : in std_logic; signal in_word : out std_logic_vector; signal key_handle : out std_logic_vector; signal t_last, t_valid, rst : out std_logic; signal t_keep : out std_logic_vector);
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
   -- test case
   procedure test(file f_vectors : text; PATH : string; signal t_ready, clk : in std_logic; signal in_word : out std_logic_vector; signal key_handle : out std_logic_vector; signal t_last, t_valid, rst : out std_logic; signal t_keep : out std_logic_vector) is
   variable status               : file_open_status;
   constant clk_period           : time := 5 ns; 
   begin
      file_open(status, f_vectors, PATH);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
      rst       <= '1';
      t_last    <= '0';
      t_valid   <= '0';                                                                                                                                                                                                                                                              
      wait for RESET_DURATION;                                                                                                                                                                                                                                                       
      rst       <= '0';                                                                                                                                                                                                                                                              
      key_handle<= std_logic_vector(to_unsigned(0,10)); -- load key                                                                                                                                                                                                                                                                                                                                                                                                                                                             
      wait until t_ready = '1';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
      while not endfile(f_vectors) loop                                                                                                                                                                                                                  
         if t_ready = '1' then
            t_valid   <= '1';
            get_inputs(f_vectors, in_word, key_handle, t_last, t_keep); -- get data from test vectors                                                                                                                                                                                                                                                     
         end if; 
      wait until rising_edge(clk);                                                                                                                                                                                                                                                                 
      end loop;
      wait for clk_period*600; 
      file_close(f_vectors);
   end;
   
   
   
   -- Assertions
   procedure assertion(test_msg_i : string; assertion_msg_i : string; expected_i : std_logic_vector; received_i : std_logic_vector) is
   begin
      assert expected_i = received_i
      report trim(test_msg_i) & " - " & assertion_msg_i & " - Expected value: 0x" & to_hstring(expected_i) & ", received value: 0x" & to_hstring(received_i) & " <=== error!!!" & lf
      severity error;
   end;
   
   procedure assertion_array(test_msg_i : string; assertion_msg_i : string; expected_i : T_GCM_EXP; received_i : T_GCM_EXP) is
   begin
      for i in 1 to WIDTH_BYTE-1 loop
         wait for 0 ns; 
         assert expected_i = received_i
         report trim(test_msg_i) & " - " & assertion_msg_i & " - Expected value: 0x" & to_hstring(expected_i(i-1)) & ", received value: 0x" & to_hstring(received_i(i)) & " <=== error!!!" & lf
         severity error;
      end loop;
   end;
   
   -- extract input data from FIPS test vectors
   procedure get_inputs(file f_vectors : text; signal in_word, key : out std_logic_vector; signal last : out std_logic; signal t_keep : out std_logic_vector ) is
      variable v_iline              : line;
      variable v_test_id            : string(1 to 4);
      variable v_space              : character;
      variable v_pt                 : std_logic_vector(in_word'length-1 downto 0);
      variable v_key                : integer;
      variable v_last               : std_logic;
      variable v_keep               : std_logic_vector((WIDTH_BYTE*2)-1 downto 0);
   begin
      readline(f_vectors, v_iline);
      read(v_iline, v_test_id);
      hread(v_iline, v_pt);
      read(v_iline, v_space);           
      read(v_iline, v_key); 
      read(v_iline, v_space);           
      read(v_iline, v_last);
      read(v_iline, v_space);           
      hread(v_iline, v_keep);    
      in_word   <=  reverse_byte_order(v_pt);  -- reverse order of plain text
      key       <=  std_logic_vector(to_unsigned(v_key,10)); -- get key handle
      last      <=  v_last;
      t_keep    <=  v_keep;
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
   
   -- extract input data from FIPS test vectors
   procedure get_gcm_inputs(file f_vectors, f_ct : text; signal leng_pt : in integer; signal clk, t_valid, t_ready : in std_logic; signal ct_result : in std_logic_vector;  signal in_word, key, exp_ct : out std_logic_vector; signal ct_gcm_arr: out T_GCM_EXP) is
      variable v_iline,v_line_ct       : line;
      variable v_test_id, v_test_id_ct : string(1 to 4);
      variable v_space, v_space_ct     : character;
      variable v_pt, v_ct              : std_logic_vector(in_word'length-1 downto 0);
      variable v_key                   : integer;
      variable v_ct_array              : T_GCM_EXP;
   begin
      readline(f_vectors, v_iline);
      readline(f_ct, v_line_ct);
      read(v_iline,  v_test_id);
      read(v_line_ct,  v_test_id_ct);
      read(v_iline,  v_key);
      read(v_iline,  v_space); 
      read(v_line_ct,  v_space_ct); 
      wait for 0 ns;          
      key       <=  std_logic_vector(to_unsigned(v_key,10)); -- get key handle
      for i in 0 to (leng_pt/128)+1 loop
         if t_valid and t_ready then   
            hread(v_iline, v_pt);
            in_word   <=  reverse_byte_order(v_pt);  -- reverse order of plain text
            wait until rising_edge(clk);
            hread(v_line_ct, v_ct);
            exp_ct   <=  reverse_byte_order(v_ct);
            wait for 0 ns; 
            v_ct_array(i) := exp_ct; 
         else
            wait until rising_edge(clk) and t_ready = '1';
         end if;
      end loop;
      ct_gcm_arr <= v_ct_array;
   end;
end package body aes_engine_tb_pkg;
