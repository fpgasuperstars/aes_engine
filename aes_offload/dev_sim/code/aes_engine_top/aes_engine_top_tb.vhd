--------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_top_tb.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This testbench tests the functionality of the sbox
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

library aes_engine;
use     aes_engine.aes_engine_pkg.all;

library tb_lib;
use     tb_lib.aes_engine_tb_pkg.all;

library blk_mem_gen_v8_4_5;
library xil_defaultlib;
library xpm;

entity aes_engine_top_tb is
   generic (
      g_test_cases   : std_logic_vector(31 downto 0) := x"00000001"; -- select 1 test at a time,128/192/256, 1/1/1 encryp, 8/8/8 = decryption. 1/0/0/0 = gcm mode 256 test
      g_asyncronous  : std_logic := '0';
      g_decryption   : std_logic := '0';
      g_speed_select : std_logic := '1' -- 1 = Lo speed
   );
end entity;

architecture sim of aes_engine_top_tb is
   -- Constants
   constant KEY               : std_logic_vector(DATA_WIDTH_128-1 downto 0) := (others => '0'); 
   constant clk_period        : time := 5 ns; 
   constant clk_period_100    : time := 10 ns;
   constant pad               : string := "                                                                     ";
   
   -- Signals
   signal out_word, out_word_q, out_word_qq, in_word, fifo_to_engine_data: std_logic_vector(DATA_WIDTH_128-1 downto 0) := (others => '0');
   signal test_msg                                                       : string(1 to STRING_LENGTH);
   signal rst, clk, clk_100, engine_clk                                  : std_logic := '0';
   signal test_id                                                        : string(1 to 4);                        
   signal pt                                                             : std_logic_vector(DATA_WIDTH_128-1 downto 0):= (others => '0');
   signal key_handle                                                     : std_logic_vector(9 downto 0):= (others => '0');
   signal exp_ct,exp_ct_128,exp_ct_192,exp_ct_256,gcm_ct_exp             : std_logic_vector(DATA_WIDTH_128-1 downto 0):= (others => '0');
   signal test_done, t_valid, valid_out, valid_out_q, o_t_valid          : std_logic := '0';
   signal t_last, fifo_to_engine_t_last, o_t_ready, i_t_ready, o_t_last  : std_logic := '0';
   signal t_keep, fifo_to_engine_keep                                    : std_logic_vector((WIDTH_BYTE*2)-1 downto 0):= (others => '1');
   signal t_ready                                                        : std_logic := '0';
   signal mode,leng_pt                                                   : integer;
   signal en_cnt                                                         : unsigned(4 downto 0);
   signal iv                                                             : std_logic_vector(95 downto 0):= (others => '0'); 
   signal o_t_keep                                                       : std_logic_vector(15 downto 0) := x"0000";
   
   -- GCM
   signal auth_data                                                      : std_logic_vector(DATA_WIDTH_128-1 downto 0):= (others => '0');
   
   -- assertions/ result
   signal ct_gcm_arr, out_word_arr : T_GCM_EXP;
   
   -- BRAM
   signal keys_128            : std_logic_vector(DATA_WIDTH_128-1 downto 0);
   signal keys_192            : std_logic_vector(DATA_WIDTH_192-1 downto 0);
   signal keys_256            : std_logic_vector(DATA_WIDTH_256-1 downto 0);
   
begin
   
   dut : entity aes_engine.aes_engine_top
      generic map(
         g_speed_sel       => g_speed_select, 
         g_decryption_sel  => g_decryption
      )
      port map(
         i_clk               => engine_clk,
         i_rst               => rst,       
         -- AXI stream M2S 
         i_t_data            => fifo_to_engine_data,
         i_t_valid           => o_t_valid, 
         i_t_last            => fifo_to_engine_t_last, 
         i_t_keep            => fifo_to_engine_keep,
         i_t_ready           => i_t_ready,   
         -- AXI stream S2M 
         o_t_valid           => valid_out, 
         o_t_last            => o_t_last,
         o_t_keep            => o_t_keep, 
         o_t_data            => out_word, 
         o_t_ready           => o_t_ready,  
         -- Keys           
         i_key_handle        => key_handle,  
         -- GCM            
         i_auth_data         => auth_data,   
         -- status         
         o_done              => open   
      );
      
   u_fifo_in : entity xil_defaultlib.axis_data_fifo_0
      PORT MAP (
         s_axis_aresetn => not rst,
         s_axis_aclk    => clk,
         
         s_axis_tvalid  => t_valid,
         s_axis_tready  => t_ready,
         s_axis_tdata   => in_word,
         s_axis_tkeep   => t_keep,
         s_axis_tlast   => t_last,
         
         m_axis_aclk    => engine_clk,
         m_axis_tvalid  => o_t_valid,
         m_axis_tready  => o_t_ready,
         m_axis_tdata   => fifo_to_engine_data,
         m_axis_tkeep   => fifo_to_engine_keep,
         m_axis_tlast   => fifo_to_engine_t_last,
         
         almost_empty   => open,
         almost_full    => open
      );
      
   u_fifo_out : entity xil_defaultlib.axis_data_fifo_0
      PORT MAP (
         s_axis_aresetn => not rst,
         s_axis_aclk    => clk,
         
         s_axis_tvalid  => valid_out,
         s_axis_tready  => i_t_ready,
         s_axis_tdata   => out_word,
         s_axis_tkeep   => o_t_keep,
         s_axis_tlast   => o_t_last,
         
         m_axis_aclk    => engine_clk,
         m_axis_tvalid  => open,
         m_axis_tready  => '1',
         m_axis_tdata   => open,
         m_axis_tkeep   => open,
         m_axis_tlast   => open,
         
         almost_empty   => open,
         almost_full    => open
      );
      
   p_clk : process
   begin
      out_word_q   <= out_word;
      out_word_qq  <= out_word_q;
      valid_out_q  <= valid_out;
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
      wait for clk_period/2;
   end process;
   
   p_clk_slow : process
   begin
      clk_100 <= '1';
      wait for clk_period_100/2;
      clk_100 <= '0';
      wait for clk_period_100/2;
   end process;
   -- change to asyncronous clocks when mode selected
   engine_clk <= clk when g_asyncronous = '0' else clk_100;

   p_assertions : process -- used to align the expected data with the output data for testing values are the same
      variable status : file_open_status;
   begin
      if g_decryption = '0' then
         file_open(status, f_ct_vectors    , CT_128_FILE ); 
         file_open(status, f_192_ct_vectors, CT_192_FILE );   
         file_open(status, f_256_ct_vectors, CT_256_FILE ); 
         while not endfile(f_ct_vectors) loop 
            if valid_out = '1' then
               if test_msg = "Test case 1 : AES128 Encryption" & pad then
                  get_ct(f_ct_vectors, exp_ct_128);
                  wait for 0 ns;
                  if valid_out_q = '1' then
                     assertion(test_msg, "compare output cipher with text file FIPS cipher",  exp_ct_128, out_word_qq);
                  end if;
               elsif test_msg = "Test case 3 : AES192 Encryption" & pad then
                  get_ct(f_192_ct_vectors, exp_ct_192);
                  wait for 0 ns;
                  if valid_out_q = '1' then
                     assertion(test_msg, "compare output cipher with text file FIPS cipher",  exp_ct_192, out_word_qq);
                  end if;
               elsif test_msg = "Test case 5 : AES256 Encryption" & pad then
                  get_ct(f_256_ct_vectors, exp_ct_256);
                  wait for 0 ns;
                  if valid_out_q = '1' then
                     assertion(test_msg, "compare output cipher with text file FIPS cipher",  exp_ct_256, out_word_qq);
                  end if;
               end if;
            end if;
            wait until rising_edge(clk);
         end loop;
         file_close(f_ct_vectors);
         file_close(f_192_ct_vectors);
         file_close(f_256_ct_vectors);
      else
         file_open(status, f_128_vectors, CMD_128_FILE ); 
         file_open(status, f_192_vectors, CMD_192_FILE );   
         file_open(status, f_256_vectors, CMD_256_FILE );
         while not endfile(f_128_vectors) loop 
            if valid_out = '1' then
               if test_msg = "Test case 2 : AES128 Decryption" & pad then
                  get_ct(f_128_vectors, exp_ct_128);
                  wait for 0 ns;
                  if valid_out_q = '1' then
                     assertion(test_msg, "compare output cipher with text file FIPS cipher",  exp_ct_128, out_word_qq);
                  end if;
               elsif test_msg = "Test case 4 : AES192 Decryption" & pad then
                  get_ct(f_192_vectors, exp_ct_192);
                  wait for 0 ns;
                  if valid_out_q = '1' then
                     assertion(test_msg, "compare output cipher with text file FIPS cipher",  exp_ct_192, out_word_qq);
                  end if;
               elsif test_msg = "Test case 6 : AES256 Decryption" & pad then
                  get_ct(f_256_vectors, exp_ct_256);
                  wait for 0 ns;
                  if valid_out_q = '1' then
                     assertion(test_msg, "compare output cipher with text file FIPS cipher",  exp_ct_256, out_word_qq);
                  end if;
               end if;
            end if;
            wait until rising_edge(clk);
         end loop;
         file_close(f_128_vectors);
         file_close(f_192_vectors);
         file_close(f_256_vectors);
      end if;
      wait;
   end process;

   p_form_array_gcm : process
   begin
      for i in 0 to out_word_arr'high loop
         wait until valid_out = '1';
            out_word_arr(i) <= out_word;
      end loop;
   end process;
   
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   -- Test Cases
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
   p_main_tests : process
      variable v_oline : line;
      variable status : file_open_status;
   begin
      
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   -- AES 128
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
      ------------------------------------------------------------------------------------
      ---- Test case 1
      ------------------------------------------------------------------------------------
      if g_test_cases(0) = '1' then                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
         test_msg <= pad_string("Test case 1 : AES128 Encryption", ' ', STRING_LENGTH);                                                                                                                                                                                                 
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;
         test(f_128_vectors, CMD_128_FILE, t_ready, clk, in_word, key_handle,t_last, t_valid, rst, t_keep );
      end if;
      
      ------------------------------------------------------------------------------------
      ---- Test case 2
      ------------------------------------------------------------------------------------
      if g_test_cases(3) = '1' then                                                                                                                                                                                                                                                                                                                                                                                                               
         test_msg <= pad_string("Test case 2 : AES128 Decryption", ' ', STRING_LENGTH);
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;
         test(f_ct_vectors, CT_128_FILE, t_ready, clk, in_word, key_handle,t_last, t_valid, rst, t_keep );                                                                                                                                                          
      end if;                                                                                                                                                      
                                                                                                                                                                   
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                  
   -- AES 192                                                                                                                                                                                                                                                                             
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ------------------------------------------------------------------------------------
      ---- Test case 3
      ------------------------------------------------------------------------------------
      if g_test_cases(4) = '1' then                                                                                                                                                                                                                                                                                                                                                                                                                                         
         test_msg <= pad_string("Test case 3 : AES192 Encryption", ' ', STRING_LENGTH);
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;                                                          
         test(f_192_vectors, CMD_192_FILE, t_ready, clk, in_word, key_handle,t_last, t_valid, rst, t_keep );                                                                                                                                                                  
      end if;                                                                                                                                                                                                                                                                                                                                                                                           
      ------------------------------------------------------------------------------------
      ---- Test case 4
      ------------------------------------------------------------------------------------
      if g_test_cases(7) = '1' then                                                                                                                                                                                                                                                                                                                                                                
         test_msg <= pad_string("Test case 4 : AES192 Decryption", ' ', STRING_LENGTH);
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;                                       
         test(f_192_ct_vectors, CT_192_FILE, t_ready, clk, in_word, key_handle,t_last, t_valid, rst, t_keep );                                                                                                                                                                                                
      end if;                                                                                                                             
      
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   -- AES 256
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
      ------------------------------------------------------------------------------------
      ---- Test case 5
      ------------------------------------------------------------------------------------
      if g_test_cases(8) = '1' then                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
         test_msg <= pad_string("Test case 5 : AES256 Encryption", ' ', STRING_LENGTH);                                                                                                                                                                                                                                                                                                                                                                                                                               
         wait for 0 ns;
         report lf & lf & test_msg & lf;                                                                                                                                                                                                                                                                                                                                                                                                                                                      
         test(f_256_vectors, CMD_256_FILE, t_ready, clk, in_word, key_handle,t_last, t_valid, rst, t_keep );                                                                                                                                                                                                                                                                                                                                                                                              
      end if;                                                                                                                                                                          
      ------------------------------------------------------------------------------------                                                                                     
      ---- Test case 6                                                                                                                                                        
      ------------------------------------------------------------------------------------                                                                                     
      if g_test_cases(11) = '1' then                                                                                                                                                                                                                                                                                                                                        
         test_msg <= pad_string("Test case 6 : AES256 Decryption", ' ', STRING_LENGTH);                                        
         wait for 0 ns;                                                                                             
         report lf & lf & test_msg & lf;
         test(f_256_ct_vectors, CT_256_FILE, t_ready, clk, in_word, key_handle,t_last, t_valid, rst, t_keep );                                                                                                                                                                                                                                                          
      end if;                                                                                                                                              
                                                                                                                                                               
      ------------------------------------------------------------------------------------                                   
      ---- Test case 12 
      ----"tgId"    : 15,               
      ----"direction": "encrypt",  
      ----"keyLen": 256,           
      ----"ivLen": 96,                
      ----"ivGenMode": "8.2.2",    
      ----"payloadLen": 1024,      
      ----"aadLen": 1024,          
      ----"tagLen": 104,                                                                                                                              
      ------------------------------------------------------------------------------------                                   
      if g_test_cases(12) = '1' then                                                                                         
         file_open(status, f_gcm_vectors      , CMD_GCM_FILE);                                                               
         file_open(status, f_gcm_ct_vectors   , CT_GCM_FILE);                                                                
         leng_pt     <= 1024;   --"payloadLen": 1024                                                                                                 
         key_handle  <= (others  =>  '0');                                                                                   
         test_msg    <= pad_string(" Test case 12 : GCM mode AES 256", ' ', STRING_LENGTH);                                  
         wait for 0 ns;                                                                                                      
         report lf & lf & test_msg & lf;                                                                                                                                                                                   
         rst       <= '1';             
         wait for RESET_DURATION;
         rst       <= '0';           
         wait until rising_edge(clk);
         wait until t_ready = '1';
         wait until rising_edge(clk);
         t_valid <= '1'; 
         get_gcm_inputs(f_gcm_vectors, f_gcm_ct_vectors, leng_pt, clk, t_valid, t_ready, out_word, in_word, key_handle, gcm_ct_exp, ct_gcm_arr);  
         in_word  <= (AES128-1 => '1', others => '0');                                                                                                               
         t_last   <= '1';                                                                                                                                    
         wait until rising_edge(clk);                                                                                                                       
         t_valid  <= '0'; 
         t_last   <= '0';                  
         wait for clk_period*1000;
         assertion_array(test_msg, "compare output cipher with text file FIPS cipher", ct_gcm_arr, out_word_arr);
         file_close(f_gcm_vectors);
         file_close(f_gcm_ct_vectors);
      end if;
      
      ------------------------------------------------------------------------------------                                                                                     
      ---- print memory .coe file for keys                                                                                                                                                        
      ------------------------------------------------------------------------------------ 
      if g_test_cases(31) = '1' then
         test_msg <= pad_string(" write coe file ", ' ', STRING_LENGTH);                                                                                                                                                                                                 
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;  
         file_open(status, f_keys_128   , KEYS_128_FILE);
         file_open(status, f_keys_192   , KEYS_192_FILE);
         file_open(status, f_keys_256   , KEYS_256_FILE);
         file_open(status, f_output_keys, KEYS_OUT_FILE, write_mode);
         
         wait until rising_edge(clk);
         
         wait for 2 ns;
         write(v_OLINE, header1);
         writeline(f_output_keys, v_OLINE);
         wait for 2 ns;
         write(v_OLINE, header2);
         writeline(f_output_keys, v_OLINE);
         wait for 2 ns;
         write(v_OLINE, header3);
         writeline(f_output_keys, v_OLINE);
         
         while not endfile(f_keys_128) loop -- run at full speed
            get_ct(f_keys_128,keys_128 ); -- get data from 128 key file and reverse the order
            wait for 2 ns;
            hwrite(v_OLINE, keys_128);
            write(v_OLINE, comma);
            writeline(f_output_keys, v_OLINE);
         end loop;
      
         while not endfile(f_keys_192) loop -- run at full speed
            get_ct(f_keys_192,keys_192 ); -- get data from 192 key file and reverse the order
            wait for 2 ns;
            hwrite(v_OLINE, keys_192);
            write(v_OLINE, comma);
            writeline(f_output_keys, v_OLINE);
         end loop;
         
         while not endfile(f_keys_256) loop -- run at full speed
            get_ct(f_keys_256,keys_256 ); -- get data from 256 key file and reverse the order
            wait for 2 ns;
            hwrite(v_OLINE, keys_256);
            write(v_OLINE, comma);
            writeline(f_output_keys, v_OLINE);
         end loop;
      
         wait until rising_edge(clk);
          
         file_close(f_keys_128);
         file_close(f_keys_192);
         file_close(f_keys_256);
         file_close(f_output_keys);
      end if;
      
      -- stop simulation
      assert false report "END OF SIMULATION!" severity failure;
      wait;
   end process;
   
   
end sim;
