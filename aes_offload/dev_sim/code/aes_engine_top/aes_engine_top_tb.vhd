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
      g_test_cases : std_ulogic_vector(31 downto 0) := x"00000111" -- select 1 test at a time,128/192/256, 2/2/2 = lo speed tests, 1/1/1 hi speed, 0/4/0 = asyncronous test, 8/8/8 = decryption. 1/0/0/0 = gcm mode test
   );
end entity;

architecture sim of aes_engine_top_tb is
   -- Constants
   constant KEY               : std_logic_vector(DATA_WIDTH_128-1 downto 0) := (others => '0'); 
   constant clk_period        : time := 5 ns; 
   constant clk_period_100    : time := 10 ns;
   
   -- Signals
   signal out_word, in_word, fifo_to_engine_data   : std_logic_vector(DATA_WIDTH_128-1 downto 0) := (others => '0');
   signal test_msg            : string(1 to STRING_LENGTH);
   signal rst, clk, clk_100, engine_clk   : std_logic := '0';
   signal test_id             : string(1 to 4);                        
   signal pt                  : std_logic_vector(DATA_WIDTH_128-1 downto 0):= (others => '0');
   signal key_handle          : std_logic_vector(9 downto 0):= (others => '0');
   signal exp_ct              : std_logic_vector(DATA_WIDTH_128-1 downto 0):= (others => '0');
   signal test_done, t_valid, o_t_valid, t_last, fifo_to_engine_t_last, o_t_ready : std_logic := '0';
   signal t_keep, fifo_to_engine_keep              : std_logic_vector((WIDTH_BYTE*2)-1 downto 0):= (others => '1');
   signal t_ready             : std_logic := '0';
   signal mode,leng_pt        : integer;
   signal en_cnt              : unsigned(4 downto 0);
   signal iv                  : std_logic_vector(95 downto 0):= (others => '0');
   
   type ct_array is array (0 to MODE256) of std_logic_vector(DATA_WIDTH_128-1 downto 0);
   signal ct_del : ct_array;
   
   -- BRAM
   signal keys_128            : std_logic_vector(DATA_WIDTH_128-1 downto 0);
   signal keys_192            : std_logic_vector(DATA_WIDTH_192-1 downto 0);
   signal keys_256            : std_logic_vector(DATA_WIDTH_256-1 downto 0);
   
begin
   dut : entity aes_engine.aes_engine_top
      generic map(
         g_speed_sel       => '0', -- 1 = Lo speed
         g_decryption_sel  => '0'
      )
      port map(
         i_key_handle   => key_handle,
         i_t_valid      => o_t_valid,
         i_t_last       => fifo_to_engine_t_last,
         i_t_keep       => fifo_to_engine_keep,
         i_clk          => engine_clk,
         i_rst          => rst,
         i_t_data       => fifo_to_engine_data, 
         o_t_data       => out_word,
         o_t_ready      => o_t_ready,
         o_done         => open
      );
      
   u_fifo : entity xil_defaultlib.axis_data_fifo_0
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
      
   p_clk : process
   begin
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
   
   engine_clk <= clk when g_test_cases /= x"00000040" else clk_100;

   -- reverse keys for initialisation file of BRAM due to key format being wrong way round MSB and LSB 
   p_rev_keys : process
      variable v_oline : line;
      variable status               : file_open_status;
   begin
      if g_test_cases(31) = '1' then
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
      wait;
   end process;
   
   p_delay_ct : process -- used to align the expected data with the output data for testing values are the same
   begin
      wait for 0 ns;
      loop
         wait until rising_edge(clk);
         for i in 1 to MODE256-1 loop
            ct_del(0)   <= exp_ct;
            ct_del(i)   <= ct_del(i-1);
         end loop;
      end loop;
   end process;

   p_main_tests : process
      variable status               : file_open_status;
   begin
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   -- AES 128
   --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
      ------------------------------------------------------------------------------------
      ---- Test case 1
      ------------------------------------------------------------------------------------
      if g_test_cases(0) = '1' then                                                                                                                                                                                                                                                     
         file_open(status, f_128_vectors  , CMD_128_FILE);                                                                                                                                                                                                                              
         file_open(status, f_ct_vectors   , CT_128_FILE);                                                                                                                                                                                                                               
         key_handle  <= (others  =>  '0');                                                                                                                                                                                                                                              
         test_msg <= pad_string(" Test case 1 : AES128 HI speed ", ' ', STRING_LENGTH);                                                                                                                                                                                                 
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                        
         rst       <= '1';
         t_last    <= '0';
         t_valid   <= '0';                                                                                                                                                                                                                                                              
         wait for RESET_DURATION;                                                                                                                                                                                                                                                       
         rst       <= '0';                                                                                                                                                                                                                                                              
         key_handle  <= std_logic_vector(to_unsigned(0,10)); -- load key                                                                                                                                                                                                                
         wait until rising_edge(clk);                                                                                                                                                                                                                                                  
         wait until t_ready = '1';                                                                                                                                                                                                                                                  
         if t_ready = '1' then                                                                                                                                                                                                                                                          
            t_valid   <= '1';                                                                                                                                                                                                                                                         
            get_inputs(f_128_vectors, in_word, key_handle); -- load key                                                                                                                                                                                                                 
            wait until rising_edge(clk);  
                                                                                                                                                                                                                                                         
            while not endfile(f_128_vectors) loop -- run at full speed                                                                                                                                                                                                                  
               if t_ready = '1' then                                                                                                                                                                                                                                                    
                  get_inputs(f_128_vectors, in_word, key_handle); -- get data from test vectors            
                  wait until rising_edge(clk);                                                                                                                                                                                                                                                                                                                                                                                                                      
                  get_ct(f_ct_vectors, exp_ct); -- get data from test vectors
                  wait for 1 ns;                                                                                                                                                                                                          
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE128-1), out_word);                                                                                                                                                                            
               else                                                                                                                                                                                                                                                                     
                  wait until rising_edge(clk);                                                                                                                                                                                                                                          
               end if;                                                                                                                                                                                                                                                                  
            end loop;                                                                                                                                                                                                                                                                   
         end if;                                                                                                                                                                                                                                                                        
         if t_ready = '1' then                                                                                                                                                                                                                                                          
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                    
            t_last  <= '1';                                                                                                                                                                                                                                                             
            wait until rising_edge(clk);                                                                                                                                                                                                                                                
            t_valid  <= '0';                                                                                                                                                                                                                                                            
            wait for clk_period*50;
            file_close(f_128_vectors);
            file_close(f_ct_vectors);
         end if;
      end if;
      
      ------------------------------------------------------------------------------------
      ---- Test case 2
      ------------------------------------------------------------------------------------
      if g_test_cases(1) = '1' then
         file_open(status, f_128_vectors, CMD_128_FILE);
         file_open(status, f_ct_vectors   , CT_128_FILE);
         key_handle  <= (others  =>  '0');
         test_msg <= pad_string(" Test case 2 : AES128 LO speed ", ' ', STRING_LENGTH);
         wait for 0 ns;
         report lf & lf & test_msg & lf;

         rst       <= '1';       
         exp_ct    <= (others => '0'); 
         t_last    <= '0';
         t_valid   <= '0';     
         wait for RESET_DURATION;
         rst      <= '0';  
         key_handle  <= std_logic_vector(to_unsigned(0,10)); -- load key
         wait until rising_edge(clk);
         wait until t_ready = '1';
         if t_ready = '1' then
            t_valid   <= '1'; 
            get_inputs(f_128_vectors, in_word, key_handle); -- load key
            wait until rising_edge(clk);
            t_valid   <= '0'; 
            for i in 0 to AES128 loop -- input next plain text inline with Lo speed 
               wait until rising_edge(clk);
            end loop;
            
            while not endfile(f_128_vectors) loop 
            if t_ready = '1' then
               t_valid   <= '1';
                  get_inputs(f_128_vectors, in_word, key_handle); -- get data from test vectors
                  wait for 0 ns;
                  get_ct(f_ct_vectors, exp_ct); -- get data from test vectors
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", exp_ct, out_word);
                  wait until rising_edge(clk);
                  t_valid   <= '0'; 
                  for i in 0 to AES128 loop -- input next plain text inline with Lo speed 
                     wait until rising_edge(clk);
                  end loop;
               else
                  
                  wait until rising_edge(clk);
               end if;
            end loop;
         end if;
         if t_ready = '1' then
            t_valid  <= '1'; 
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                    
            t_last  <= '1';                                                                                                                                                                                                                                                              
            wait until rising_edge(clk);  
            t_valid  <= '0';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
            wait for clk_period*600;
            file_close(f_128_vectors);
            file_close(f_ct_vectors);
         end if;
      end if;
      
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      -- TKEEP tests
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
      if g_test_cases(2) = '1' then
         file_open(status, f_128_vectors  , CMD_128_FILE);                                                                                                                                                                                                                              
         file_open(status, f_ct_vectors   , CT_128_FILE);                                                                                                                                                                                                                               
         key_handle  <= (others  =>  '0');                                                                                                                                                                                                                                              
         test_msg <= pad_string(" Test case 3 : TKEEP ", ' ', STRING_LENGTH);                                                                                                                                                                                                 
         wait for 0 ns;                                                                                                                                                                                                                                                                 
         report lf & lf & test_msg & lf;                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                        
         rst       <= '1';
         t_last    <= '0';
         t_valid   <= '0';                                                                                                                                                                                                                                                              
         wait for RESET_DURATION;                                                                                                                                                                                                                                                       
         rst       <= '0';                                                                                                                                                                                                                                                              
         key_handle  <= std_logic_vector(to_unsigned(0,10)); -- load key                                                                                                                                                                                                                
         wait until rising_edge(clk);
         wait until t_ready = '1';                                                                                                                                                                                                                                                 
         if t_ready = '1' then                                                                                                                                                                                                                                                          
            t_valid   <= '1'; 
            t_keep   <= std_logic_vector(to_unsigned(1, 16));                                                                                                                                                                                                                                                        
            get_inputs(f_128_vectors, in_word, key_handle); -- load key                                                                                                                                                                                                                 
            wait until rising_edge(clk);  
                                                                                                                                                                                                                                                         
            while not endfile(f_128_vectors) loop -- run at full speed                                                                                                                                                                                                                  
               if t_ready = '1' then                                                                                                                                                                                                                                                    
                  get_inputs(f_128_vectors, in_word, key_handle); -- get data from test vectors            
                  wait until rising_edge(clk);                                                                                                                                                                                                                                                                                                                                                                                                                      
                  get_ct(f_ct_vectors, exp_ct); -- get data from test vectors
                  wait for 1 ns;                                                                                                                                                                                                          
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE128-1), out_word);                                                                                                                                                                            
               else                                                                                                                                                                                                                                                                     
                  wait until rising_edge(clk);                                                                                                                                                                                                                                          
               end if;                                                                                                                                                                                                                                                                  
            end loop;                                                                                                                                                                                                                                                                   
         end if;                                                                                                                                                                                                                                                                        
         if t_ready = '1' then                                                                                                                                                                                                                                                          
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                    
            t_last  <= '1';                                                                                                                                                                                                                                                             
            wait until rising_edge(clk);                                                                                                                                                                                                                                                
            t_valid  <= '0';                                                                                                                                                                                                                                                            
            wait for clk_period*50;
            file_close(f_128_vectors);
            file_close(f_ct_vectors);
         end if;
      end if;
      
      ------------------------------------------------------------------------------------
      ---- Test case 4
      ------------------------------------------------------------------------------------
      if g_test_cases(3) = '1' then                                                                                                                                
         file_open(status, f_128_vectors  , CMD_128_FILE);                                                                                                         
         file_open(status, f_ct_vectors   , CT_128_FILE);                                                                                                          
         key_handle  <= (others  =>  '0');                                                                                                                         
         test_msg <= pad_string(" Test case 4 : AES128 decryption HI speed ", ' ', STRING_LENGTH);                                                                 
         wait for 0 ns;                                                                                                                                            
         report lf & lf & test_msg & lf;                                                                                                                           
                                                                                                                                                                   
         rst       <= '1';                                                                                                                                         
         t_last    <= '0';                                                                                                                                         
         t_valid   <= '0';                                                                                                                                         
         wait for RESET_DURATION;                                                                                                                                  
         rst       <= '0';
         key_handle  <= std_logic_vector(to_unsigned(0,10)); -- load key                                                                                                                                             
         wait until rising_edge(clk); 
         wait until t_ready = '1';                                                                                                                             
         if t_ready = '1' then                                                                                                                                     
            t_valid   <= '1';                                                                                                                                      
            get_inputs(f_ct_vectors, in_word, key_handle); -- load key                                                                                             
            wait until rising_edge(clk);                                                                                                                           
            while not endfile(f_ct_vectors) loop -- run at full speed                                                                                              
               if t_ready = '1' then                                                                                                                               
                  get_inputs(f_ct_vectors, in_word, key_handle); -- get data from test vectors                                                                     
                  wait until rising_edge(clk);                                                                                                                     
                  get_ct(f_128_vectors, exp_ct); -- get data from test vectors                                                                                     
                  wait for 1 ns;                                                                                                                                   
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE128-1), out_word);                                            
               else                                                                                                                                                
                  wait until rising_edge(clk);                                                                                                                     
               end if;                                                                                                                                             
            end loop;                                                                                                                                              
         end if;                                                                                                                                                   
         if t_ready = '1' then                                                                                                                                                                                                                                                                                 
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                                           
            t_last  <= '1';                                                                                                                                                                                                                                                                                    
            wait until rising_edge(clk);                                                                                                                                                                                                                                                                       
            t_valid  <= '0';                                                                                                                                                                                                                                                                                   
            wait for clk_period*50;                                                                                                                                
            file_close(f_128_vectors);                                                                                                                             
            file_close(f_ct_vectors);                                                                                                                              
         end if;                                                                                                                                                   
      end if;                                                                                                                                                      
                                                                                                                                                                   
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                  
      -- AES 192                                                                                                                                                                                                                                                                             
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ------------------------------------------------------------------------------------
      ---- Test case 4
      ------------------------------------------------------------------------------------
      if g_test_cases(4) = '1' then                                                                                                              
         file_open(status, f_192_vectors      , CMD_192_FILE);                                                                         
         file_open(status, f_192_ct_vectors   , CT_192_FILE );                                                                         
         key_handle  <= (others  =>  '0');                                                                                             
         test_msg <= pad_string(" Test case 5 : AES192 HI speed ", ' ', STRING_LENGTH);                                                
         wait for 0 ns;                                                                                                                
         report lf & lf & test_msg & lf;                                                                                               
                                                                                                                      
         rst       <= '1';
         t_last    <= '0';
         t_valid   <= '0';                                                                                                             
         wait for RESET_DURATION;                                                                                                      
         rst       <= '0';                                                                                                             
         key_handle  <= std_logic_vector(to_unsigned(150,10)); -- load key
         wait until rising_edge(clk); 
         wait until t_ready = '1';                                                                                                                                                                                                                                                                 
         if t_ready = '1' then                                                                                                         
            t_valid   <= '1';                                                                                                          
            get_inputs(f_192_vectors, in_word, key_handle); -- load key                                                                                                                                              
            wait until rising_edge(clk);                                                                                               
            while not endfile(f_192_vectors) loop -- run at full speed                                                                 
               if t_ready = '1' then                                                                                                   
                  get_inputs(f_192_vectors, in_word, key_handle); -- get data from test vectors                                        
                  wait until rising_edge(clk);                                                                                         
                  get_ct(f_192_ct_vectors, exp_ct); -- get data from test vectors  
                  wait for 1 ns;                                                                                                                           
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE192-1), out_word);                           
               else                                                                                                                    
                  wait until rising_edge(clk);                                                                                         
               end if;                                                                                                                 
            end loop;                                                                                                                  
         end if;
         if t_ready = '1' then                                                             
            in_word  <= (AES128-1 => '1', others => '0');                                  
            t_last  <= '1';  
            wait until rising_edge(clk);                             
            t_valid   <= '0';                                                                                                
            wait for clk_period*50;                                                        
            file_close(f_192_vectors);                                                     
            file_close(f_192_ct_vectors);                                                                                                          
         end if;                                                                                                                                                                          
      end if;                                                                                                                          
                                                                                                                                       
      ------------------------------------------------------------------------------------                                             
      ---- Test case 5                                                                                                                 
      ------------------------------------------------------------------------------------                                    
      if g_test_cases(5) = '1' then                                                                                                             
         file_open(status, f_192_vectors      , CMD_192_FILE);                                                                                  
         file_open(status, f_192_ct_vectors   , CT_192_FILE );                                                                                  
         key_handle  <= (others  =>  '0');                                                                                                      
         test_msg <= pad_string(" Test case 6 : AES192 LO speed ", ' ', STRING_LENGTH);                                                         
         wait for 0 ns;                                                                                                                         
         report lf & lf & test_msg & lf;                                                                                                        
                                                                                                                                                
         rst       <= '1';                                                                                                                      
         t_last    <= '0';                                                                                                                      
         t_valid   <= '0';                                                                                                                      
         exp_ct    <= (others => '0');                                                                                                          
         wait for RESET_DURATION;                                                                                                               
         rst      <= '0';                                                                                                                       
         key_handle  <= std_logic_vector(to_unsigned(150,10)); -- load key 
         wait until rising_edge(clk); 
         wait until t_ready = '1';                                                                                                                                                                                                                                                                                                                 
         if t_ready = '1' then                                                                                                                  
            t_valid   <= '1';                                                                                                                    
            get_inputs(f_192_vectors, in_word, key_handle); -- load key                                                                          
            wait until rising_edge(clk);                                                                                                        
            t_valid   <= '0';                                                                                                                                                  
            for i in 0 to AES192 loop -- input next plain text inline with Lo speed                                                            
               wait until rising_edge(clk);                                                                                                      
            end loop;                                                                                                                            
                                                                                                                                                                                          
            while not endfile(f_192_vectors) loop                                                                                                
               if t_ready = '1' then                                                                                                            
                  t_valid   <= '1';                                                                                                             
                  get_inputs(f_192_vectors, in_word, key_handle); -- get data from test vectors                                                 
                  wait for 0 ns;                                                                                                                
                  get_ct(f_192_ct_vectors, exp_ct); -- get data from test vectors                                                                
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", exp_ct, out_word);
                  wait until rising_edge(clk);       
                  t_valid   <= '0';                                                                    
                  for i in 0 to AES192 loop -- input next plain text inline with Lo speed                                                      
                     wait until rising_edge(clk);                                                                                                
                  end loop;                                                                                                                                             
               else                                                                                                                              
                  wait until rising_edge(clk);                                                                                                   
               end if;                                                                                                                           
            end loop;                                                                                                                           
         end if;                                                                                                                                                                                                                                                          
         if t_ready = '1' then                                                                                                                  
            t_valid  <= '1';
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                                 
            t_last  <= '1';                                                                                                                                                                                                                                                                           
            wait until rising_edge(clk);                                                                                                        
            t_valid  <= '0';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            wait for clk_period*600;                                                                                                            
            file_close(f_192_vectors);                                                                                                          
            file_close(f_192_ct_vectors);                                                                                                                        
         end if;                                                                                                                                
      end if;                                                                                                                                   
                                                                                                                                                
      ------------------------------------------------------------------------------------                                                      
      ---- Test case 6                                                                                                           
      ------------------------------------------------------------------------------------                                       
      if g_test_cases(6) = '1' then
         file_open(status, f_192_vectors      , CMD_192_FILE);
         file_open(status, f_192_ct_vectors   , CT_192_FILE );
         key_handle  <= (others  =>  '0');
         test_msg <= pad_string(" Test case 7 : AES192 asyncronous clocks", ' ', STRING_LENGTH);
         wait for 0 ns;                                                                                                                         
         report lf & lf & test_msg & lf;                                                                                                        
                                                                                                                                    
         rst       <= '1';                                                                                                                      
         t_last    <= '0';                                                                                                                      
         t_valid   <= '0';                                                                                                                      
         exp_ct    <= (others => '0');                                                                                                          
         wait for RESET_DURATION;                                                                                                               
         rst      <= '0';                                                                                                                       
         key_handle  <= std_logic_vector(to_unsigned(150,10)); -- load key                                                                      
         wait until rising_edge(clk); 
         wait until t_ready = '1';                                                                                                                                                                                                                                            
         if t_ready = '1' then                                                                                                                  
            t_valid   <= '1';                                                                                                                    
            get_inputs(f_192_vectors, in_word, key_handle); -- load key                                                                          
            wait until rising_edge(clk);                                                                                                        
            t_valid   <= '0';                                                                                                                                                  
            for i in 0 to AES192+4 loop -- input next plain text inline with Lo speed                                                            
               wait until rising_edge(clk);                                                                                                      
            end loop;                                                                                                                            
                                                                                                                                                                                          
            while not endfile(f_192_vectors) loop                                                                                                
               if t_ready = '1' then                                                                                                            
                  t_valid   <= '1';                                                                                                             
                  get_inputs(f_192_vectors, in_word, key_handle); -- get data from test vectors                                                 
                  wait for 0 ns;                                                                                                                
                  get_ct(f_192_ct_vectors, exp_ct); -- get data from test vectors                                                                
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", exp_ct, out_word);
                  wait until rising_edge(clk);       
                  t_valid   <= '0';                                                                    
                  for i in 0 to AES192+4 loop -- input next plain text inline with Lo speed                                                      
                     wait until rising_edge(clk);                                                                                                
                  end loop;                                                                                                                                             
               else                                                                                                                              
                  wait until rising_edge(clk);                                                                                                   
               end if;                                                                                                                           
            end loop;                                                                                                                           
         end if;                                                                                                                                                                                                                                                          
         if t_ready = '1' then                                                                                                                  
            t_valid  <= '1';
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                                 
            t_last  <= '1';                                                                                                                                                                                                                                                                           
            wait until rising_edge(clk);                                                                                                        
            t_valid  <= '0';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            wait for clk_period*600;                                                                                                            
            file_close(f_192_vectors);                                                                                                          
            file_close(f_192_ct_vectors);                                                                                                                        
         end if;                                                                                                                                
      end if; 
      
      ------------------------------------------------------------------------------------
      ---- Test case 8
      ------------------------------------------------------------------------------------
      if g_test_cases(7) = '1' then                                                                                                       
         file_open(status, f_192_vectors  , CMD_192_FILE);                                                                                
         file_open(status, f_192_ct_vectors   , CT_192_FILE);                                                                             
         key_handle  <= (others  =>  '0');                                                                                                
         test_msg <= pad_string(" Test case 8 : AES192 decryption HI speed ", ' ', STRING_LENGTH);                                        
         wait for 0 ns;                                                                                                                   
         report lf & lf & test_msg & lf;                                                                                                  
                                                                                                                                          
         rst       <= '1';                                                                                                                
         t_last    <= '0';                                                                                                                
         t_valid   <= '0';                                                                                                                
         wait for RESET_DURATION;                                                                                                         
         rst       <= '0';                                                                                                                
         key_handle  <= std_logic_vector(to_unsigned(150,10)); -- load key                                                                                                            
         wait until rising_edge(clk);
         wait until t_ready = '1';                                                                                                      
         if t_ready = '1' then                                                                                                            
            t_valid   <= '1';                                                                                                             
            get_inputs(f_192_ct_vectors, in_word, key_handle); -- load key                                                                
            wait until rising_edge(clk);                                                                                                  
            while not endfile(f_192_ct_vectors) loop -- run at full speed                                                                 
               if t_ready = '1' then                                                                                                      
                  get_inputs(f_192_ct_vectors, in_word, key_handle); -- get data from test vectors                                        
                  wait until rising_edge(clk);                                                                                            
                  get_ct(f_192_vectors, exp_ct); -- get data from test vectors                                                            
                  wait for 2 ns;                                                                                                          
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE192-1), out_word);                       
               else                                                                                                                       
                  wait until rising_edge(clk);                                                                                            
               end if;                                                                                                                    
            end loop;                                                                                                                     
         end if;                                                                                                                          
         if t_ready = '1' then                                                                                                            
            in_word  <= (AES128-1 => '1', others => '0');                                                                                 
            t_last  <= '1';                                                                                                               
            wait until rising_edge(clk);                                                                                                  
            t_valid   <= '0';                                                                                                                            
            wait for clk_period*50;                                                                                                       
            file_close(f_192_vectors);                                                                                                    
            file_close(f_192_ct_vectors);                                                                                                           
         end if;                                                                                                                                                                                                              
      end if;                                                                                                                             
      
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      -- AES 256
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
      ------------------------------------------------------------------------------------
      ---- Test case 9
      ------------------------------------------------------------------------------------
      if g_test_cases(8) = '1' then                                                                                                            
         file_open(status, f_256_vectors      , CMD_256_FILE);                                                                                 
         file_open(status, f_256_ct_vectors   , CT_256_FILE );                                                                                 
         key_handle  <= (others  =>  '0');                                                                                                     
         test_msg <= pad_string(" Test case 9 : AES256 key HI speed ", ' ', STRING_LENGTH);                                                    
         wait for 0 ns;                                                                                                                        
         report lf & lf & test_msg & lf;                                                                                                       
                                                                                                                                               
         rst       <= '1';                                                                                                                     
         t_last    <= '0';                                                                                                                     
         t_valid   <= '0';                                                                                                                     
         wait for RESET_DURATION;                                                                                                              
         rst       <= '0';                                                                                                                     
         key_handle  <= std_logic_vector(to_unsigned(367,10)); -- load key                                                                     
         wait until rising_edge(clk);
         wait until t_ready = '1';                                                                                                                                                                                                                                                                       
         if t_ready = '1' then                                                                                                                 
            t_valid   <= '1';                                                                                                                  
            get_inputs(f_256_vectors, in_word, key_handle); -- load key                                                                        
            wait until rising_edge(clk);                                                                                                       
            while not endfile(f_256_vectors) loop -- run at full speed                                                                         
               if t_ready = '1' then                                                                                                           
                  get_inputs(f_256_vectors, in_word, key_handle); -- get data from test vectors                                                
                  wait until rising_edge(clk);                                                                                                 
                  get_ct(f_256_ct_vectors, exp_ct); -- get data from test vectors                                                              
                  wait for 1 ns;                                                                                                               
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE256-1), out_word);                        
               else                                                                                                                            
                  wait until rising_edge(clk);                                                                                                 
               end if;                                                                                                                         
            end loop;                                                                                                                          
         end if;                                                                                                                               
         if t_ready = '1' then                                                                                                                 
            in_word  <= (AES128-1 => '1', others => '0');                                                                                        
            t_last  <= '1';                                                                                                                    
            wait until rising_edge(clk);                                                                                                       
            t_valid  <= '0';                                                                                                                                                                      
            wait for clk_period*50;                                                                                                            
            file_close(f_256_vectors);                                                                                                         
            file_close(f_256_ct_vectors);                                                                                                                                           
         end if;                                                                                                                               
      end if;                                                                                                                        
                                                                                                                                     
      ------------------------------------------------------------------------------------                                           
      ---- Test case 10                                                                                                               
      ------------------------------------------------------------------------------------                                           
      if g_test_cases(9) = '1' then                                                                                                                                            
         file_open(status, f_256_vectors      , CMD_256_FILE);                                                                                                                 
         file_open(status, f_256_ct_vectors   , CT_256_FILE );                                                                                                                 
         key_handle  <= (others  =>  '0');                                                                                                                                     
         test_msg <= pad_string(" Test case 10 : AES256 key LO speed ", ' ', STRING_LENGTH);                                                                                   
         wait for 0 ns;                                                                                                                                                        
         report lf & lf & test_msg & lf;                                                                                                                                       
                                                                                                                                                                               
         rst       <= '1';                                                                                                                                                     
         t_last    <= '0';                                                                                                                                                     
         t_valid   <= '0';                                                                                                                                                     
         exp_ct    <= (others => '0');                                                                                                                                         
         wait for RESET_DURATION;                                                                                                                                              
         rst      <= '0';                                                                                                                                                      
         key_handle  <= std_logic_vector(to_unsigned(367,10)); -- load key                                                                                                     
         wait until rising_edge(clk);
         wait until t_ready = '1';                                                                                                                                          
         if t_ready = '1' then                                                                                                                                                 
            t_valid   <= '1';  -- now send valid and data                                                                                                                         
            get_inputs(f_256_vectors, in_word, key_handle); -- load key                                                                                                           
            wait until rising_edge(clk);                                                                                                                                          
         t_valid   <= '0'; 
         for i in 0 to AES256 loop -- input next plain text inline with Lo speed                                                                                             
            wait until rising_edge(clk);                                                                                                                                       
         end loop;                                                                                                                                                             
                                                                                                                                                                               
         while not endfile(f_256_vectors) loop                                                                                                                                 
            if t_ready = '1' then                                                                                                                                              
               t_valid   <= '1';                                                                                                                                               
               get_inputs(f_256_vectors, in_word, key_handle); -- get data from test vectors                                                                                   
               wait for 0 ns;                                                                                                                                                  
               get_ct(f_256_ct_vectors, exp_ct); -- get data from test vectors                                                                                                 
               assertion(test_msg, "compare output cipher with text file FIPS cipher", exp_ct, out_word);                                                                      
               wait until rising_edge(clk); 
               t_valid   <= '0';
               for i in 0 to AES256 loop -- input next plain text inline with Lo speed                                                                                       
                  wait until rising_edge(clk);                                                                                                                                 
               end loop;                                                                                                                                                       
            else                                                                                                                                                               
               wait until rising_edge(clk);                                                                                                                                    
            end if;                                                                                                                                                            
         end loop;
         end if;                                                                                                                                                             
                                                                                                                                          
         if t_ready = '1' then                                                                                                                                                 
            t_valid  <= '1';   
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                                                                                                                                                                                            
            t_last  <= '1';                                                                                                                                                                                                                                                                                                      
            wait until rising_edge(clk);                                                                                                                                       
            t_valid  <= '0';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            wait for clk_period*600;                                                                                                                                           
            file_close(f_256_vectors);                                                                                                                                         
            file_close(f_256_ct_vectors);                                                                                                                                                                                      
         end if;                                                                                                                                                               
      end if;                                                                                                                                                                  
                                                                                                                                                                               
      ------------------------------------------------------------------------------------                                                                                     
      ---- Test case 11                                                                                                                                                        
      ------------------------------------------------------------------------------------                                                                                     
      if g_test_cases(11) = '1' then                                                                                                                                                               
         file_open(status, f_256_vectors  , CMD_256_FILE);                                                                                                     
         file_open(status, f_256_ct_vectors   , CT_256_FILE);                                                                                                  
         key_handle  <= (others  =>  '0');                                                                                                                     
         test_msg <= pad_string(" Test case 11 : AES256 decryption HI speed ", ' ', STRING_LENGTH);                                                            
         wait for 0 ns;                                                                                                                                        
         report lf & lf & test_msg & lf;                                                                                                                       
                                                                                                                                           
         rst       <= '1';                                                                                                                                     
         t_last    <= '0';                                                                                                                                     
         t_valid   <= '0';                                                                                                                                     
         wait for RESET_DURATION;                                                                                                                              
         rst       <= '0';                                                                                                                                     
         key_handle <= std_logic_vector(to_unsigned(367,10)); -- load key                                                                                      
         wait until rising_edge(clk);
         wait until t_ready = '1';                                                                                                                          
         if t_ready = '1' then                                                                                                                                 
            t_valid   <= '1';                                                                                                                                  
            get_inputs(f_256_ct_vectors, in_word, key_handle); -- load key                                                                                     
            wait until rising_edge(clk);                                                                                                                       
            while not endfile(f_256_ct_vectors) loop -- run at full speed                                                                                      
               if t_ready = '1' then                                                                                                                           
                  get_inputs(f_256_ct_vectors, in_word, key_handle); -- get data from test vectors                                                             
                  wait until rising_edge(clk);                                                                                                                 
                  get_ct(f_256_vectors, exp_ct); -- get data from test vectors                                                                                 
                  wait for 1 ns;                                                                                                                               
                  assertion(test_msg, "compare output cipher with text file FIPS cipher", ct_del(MODE256-1), out_word);                                        
               else                                                                                                                                            
                  wait until rising_edge(clk);                                                                                                                 
               end if;                                                                                                                                         
            end loop;                                                                                                                                          
         end if;                                                                                                                                               
         if t_ready = '1' then                                                                                                                                 
            in_word  <= (AES128-1 => '1', others => '0');                                                                                                               
            t_last  <= '1';                                                                                                                                    
            wait until rising_edge(clk);                                                                                                                       
            t_valid  <= '0';                                                                                                                                                                                             
            wait for clk_period*50;                                                                                                                            
            file_close(f_256_vectors);                                                                                                                         
            file_close(f_256_ct_vectors);                                                                                                                                                                  
         end if;                                                                                                                                               
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
         wait until rising_edge(clk);                                                                                              
         rst       <= '1';             
         wait for RESET_DURATION;
         rst       <= '0';           
         wait until rising_edge(clk);
         wait until t_ready = '1';
         wait until rising_edge(clk);
         t_valid <= '1'; 
         get_gcm_inputs(f_gcm_vectors, leng_pt, clk, t_ready, in_word, key_handle);
         wait for clk_period*20;
         t_valid  <= '0';
         file_close(f_gcm_vectors);
         file_close(f_gcm_ct_vectors);
      end if;
      -- stop simulation
      assert false report "END OF SIMULATION!" severity failure;
      wait;
      
   end process;
   
   
end sim;
