---------------------------------------------------------------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_top.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This code contains the top level code for the aes engine, it instantiates the number of rounds needed according to the mode thats been set
---------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library aes_engine;
use     aes_engine.aes_engine_pkg.all;

library blk_mem_gen_v8_4_5;
library xil_defaultlib;
library xpm;

entity aes_engine_top IS
   generic(
     g_speed_sel : std_logic := '0'     -- 1 = LO speed, 0 = HI speed
   );
   port(
      i_clk               : in  std_logic;
      i_rst             : in  std_logic;
      -- AXI stream M2S
      i_t_data          : in  std_logic_vector(AXI_T_DATA-1 downto 0);
      i_t_valid         : in  std_logic;
      i_t_last          : in  std_logic;
      i_t_keep          : in  std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
      o_t_ready         : out std_logic;
      -- AXI stream S2M
      o_t_valid         : out std_logic;
      o_t_last          : out std_logic;
      o_t_keep          : out std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
      o_t_data          : out std_logic_vector(AXI_T_DATA-1 downto 0);
      -- Keys
      i_key_handle      : in  std_logic_vector(9 downto 0);
      -- status
      o_done            : out std_logic
   );
end entity;

architecture mixed of aes_engine_top is

   -- constants
   constant DUTY_EN        : integer := 2; -- enable duty cycle counter to start so that when the speed_en signal is a 1 the initial pipeline delay is accounted for
   
   -- Types
   type  T_CIPHER_TXT    is array (0 to AES256) of std_logic_vector(AXI_T_DATA-1 downto 0); -- array containing the cipher text output from each round
   type  T_STATES        is (newkey, normal, config, last);
      
   -- Signals
   signal state                                               : T_STATES;
   signal encrypt, decrypt                                    : T_CIPHER_TXT;
   signal expanded_key_q, expanded_key, expanded_key_decrypt  : T_EXPANDED_KEYS;
   signal dec_expanded_key_q                                  : T_EXPANDED_KEYS;
   signal t_data_q, config_data, t_data_last                  : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal duty_cycle_cnt, flushout_cnt, en_cnt, lo_spd_en_cnt : unsigned(4 downto 0);
   signal ini_key_cnt                                         : unsigned(5 downto 0);
   signal speed_en, t_valid_q, t_last_q, new_key, en_decr, en_cnt_rst, last_flag     : std_logic;
   signal t_keep_q                                            : std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
   signal t_valid, t_last                                     : T_AXI_STREAM;
   signal t_keep                                              : T_AXI_TKEEP;
   signal last_rnd                                            : std_logic_vector(AES256-1 downto 0);
   signal last_rnd_dec                                        : std_logic_vector(0 to AES256-1);
   signal gen_mode                                            : integer:= AES256;
   
   -- Configuration
   signal mode                                                : std_logic_vector(MODE_C-1 downto 0);
   signal iv                                                  : std_logic_vector(IV_C-1 downto 0);
   signal aes_mode                                            : std_logic_vector(AES_MODE_C-1 downto 0):= (others  => '0');
                                                              
   -- BRAM                                                    
   signal addra, key_handle_q                                 : std_logic_vector(9 downto 0);
   signal outdata, dina                                       : std_logic_vector(AES256_KEY-1 downto 0);
   
begin
   
   -- logic used to flag when the last round is encrypt
   last_rnd  <= (AES128-1 => '1', others => '0') when aes_mode = "00" else
                (AES192-1 => '1', others => '0') when aes_mode = "01" else
                (AES256-1 => '1', others => '0') when aes_mode = "10" else
                (others => '0');
   
   -- logic used to flag when the last round is encrypt
   last_rnd_dec <= (4 => '1', others => '0') when aes_mode = "00" else
                   (2 => '1', others => '0') when aes_mode = "01" else
                   (0 => '1', others => '0') when aes_mode = "10" else
                   (others => '0');
                
   -- logic to pass the mode selected that can be used for the state control                
   gen_mode  <= AES128 when aes_mode = "00" else
                AES192 when aes_mode = "01" else
                AES256 when aes_mode = "10" else
                0;         
                      
   ---------------------------------------------------------------------------------------
   -- Engine control state machine
   ---------------------------------------------------------------------------------------
   p_control : process
   begin
      wait until rising_edge(i_clk);
         if i_rst  then
            state  <=  config;
            expanded_key_q <= (others  => (others  => '0'));
            t_data_q     <= (others  => '0');
            t_data_last  <= (others  => '0');
            last_flag    <= '0';
            o_done       <= '0';
         else
            en_cnt_rst  <= '0';
         case state is
            when config =>
               if i_t_valid then
                  mode        <= i_t_data(MODE_C-1 downto 0);
                  iv          <= i_t_data((IV_C+MODE_C)-1 downto MODE_C);
                  aes_mode    <= i_t_data((AES_MODE_C+IV_C+MODE_C)-1 downto IV_C+MODE_C);
                  en_decr     <= i_t_data(AES_MODE_C+IV_C+MODE_C);
                  o_done      <= '0';
                  state       <= newkey;
               end if;
               
            when normal =>
               en_cnt_rst  <= '0';
               if i_t_last and new_key then
                  last_flag  <= '1';
                  state <= newkey;
                  for i in 0 to i_t_keep'length-1 loop -- when the t_keep is true allow those selected bytes to enter the engine otherwise set to 0's
                     t_data_last((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= i_t_data((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) when t_keep_q(i) = '1' else (others  => '0'); -- pass valid bytes using the t_keep_q signal, using the delayed signal allows for configuration data to always be read as 128bit
                  end loop;
               elsif i_t_last then
                  last_flag  <= '1';
                  for i in 0 to i_t_keep'length-1 loop -- when the t_keep is true allow those selected bytes to enter the engine otherwise set to 0's
                     t_data_last((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= i_t_data((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) when t_keep_q(i) = '1' else (others  => '0');
                  end loop;
               elsif new_key then
                  state <= newkey;
               elsif o_t_ready and i_t_valid then
                  for i in 0 to i_t_keep'length-1 loop -- when the t_keep is true allow those selected bytes to enter the engine otherwise set to 0's
                     t_data_q((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= i_t_data((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) when t_keep_q(i) = '1' else (others  => '0');
                  end loop; 
                  state <= normal;
               elsif last_flag = '1' and en_cnt >= gen_mode then
                  en_cnt_rst  <= '1';
                  state  <= last;
                  t_data_q <= t_data_last;
               end if;
               
            when newkey =>
               if i_t_last then
                  last_flag  <= '1';
                  for i in 0 to i_t_keep'length-1 loop -- when the t_keep is true allow those selected bytes to enter the engine otherwise set to 0's
                     t_data_last((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= i_t_data((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) when t_keep_q(i) = '1' else (others  => '0'); 
                  end loop;
                  state  <= newkey;
               elsif last_flag then
                  if flushout_cnt = (gen_mode *2)+1 then
                     expanded_key_q <= expanded_key; -- register the expanded keys 
                     state  <=  last;
                     t_data_q <= t_data_last;
                     en_cnt_rst  <= '1';
                  else
                     state  <= newkey;
                  end if;
               else
                  if flushout_cnt = (gen_mode *2)+1 then
                     expanded_key_q <= expanded_key; -- register the expanded keys 
                     state  <=  normal;
                     en_cnt_rst  <= '1';
                  else
                     state  <= newkey;
                  end if;
               end if;
            
            when last =>
               t_data_q <= t_data_last;
               if en_cnt = gen_mode then
                  state  <= config;
                  last_flag  <= '0';
                  o_done  <= '1';
               end if;

            when others  =>
               null;
         end case;
         end if;
   end process;
   
   -- new key detection logic
   new_key     <= '1'      when key_handle_q /= i_key_handle else '0';
   
   --  engine ready logic
   o_t_ready   <= '0'      when state = newkey or new_key = '1' or (g_speed_sel = '1' and speed_en = '0') or state = last else '1';

   ---------------------------------------------------------------------------------------
   -- Speed selection control
   ---------------------------------------------------------------------------------------
   -- Duty cycle counter used for speed selection
   p_speed_select : process
   begin
      wait until rising_edge(i_clk);
      if i_rst = '1'  then
         duty_cycle_cnt <= (others => '0');
      elsif duty_cycle_cnt = gen_mode+1 then
         duty_cycle_cnt <= (others => '0');
      else
         duty_cycle_cnt <= duty_cycle_cnt + 1;
      end if;
   end process;
   
   -- run at LO or Hi speed depending on speed selection generic  
   speed_en <= '1' when g_speed_sel = '1' and duty_cycle_cnt = gen_mode else
               '1' when g_speed_sel = '0' else
               '0';
   p_lo_speed : process
   begin
      wait until rising_edge(i_clk);
      if i_rst then
         lo_spd_en_cnt  <= (others  => '0');
      elsif speed_en = '1' and lo_spd_en_cnt < lo_spd_en_cnt'high then -- when in lo speed ensure the first output is discarded as it contains config data only
         lo_spd_en_cnt  <= lo_spd_en_cnt + 1;
      end if;
   end process;
   
   p_inital_key : process
   begin
      wait until rising_edge(i_clk);
      if i_rst then
         ini_key_cnt  <= (others  => '0');
      elsif ini_key_cnt < gen_mode*3 then
         ini_key_cnt  <= ini_key_cnt + 1;
      end if;
   end process;
   
      
   ---------------------------------------------------------------------------------------
   -- flush out when new key detected
   ---------------------------------------------------------------------------------------
   p_flush_out : process
   begin
      wait until rising_edge(i_clk);
      if i_rst then
         flushout_cnt <= (others  => '0');
      elsif state /= newkey  then -- count to allow enough time for old encryption to output correctly before new input comes in
         flushout_cnt <= (others  => '0');
      elsif state = newkey then -- check for change in key
         flushout_cnt <= flushout_cnt + 1;
      end if;
   end process;
   
   ---------------------------------------------------------------------------------------
   -- Output registers at selected speed
   ---------------------------------------------------------------------------------------
   p_outputs : process
   begin
      wait until rising_edge(i_clk);
         key_handle_q <= i_key_handle;
         t_valid_q  <= i_t_valid;
         t_last_q   <= i_t_last; 
         t_keep_q   <= i_t_keep;
      if i_rst = '1' then
         o_t_data  <= (others => '0');
         o_t_valid <= '0';
         o_t_last  <= '0';
         o_t_keep  <= (others => '0');
         key_handle_q <= (others => '0');
         t_valid_q <= '0';  
         t_last_q  <= '0'; 
         t_keep_q  <= (others => '0');
      elsif en_decr = '0' and speed_en = '1' and en_cnt >= gen_mode and lo_spd_en_cnt > 2 and ini_key_cnt >= gen_mode*3 then
         o_t_data  <= encrypt(gen_mode);
         o_t_valid <= t_valid(gen_mode);
         o_t_last  <= t_last(gen_mode);
         o_t_keep  <= t_keep(gen_mode);  
      elsif en_decr = '1' and speed_en = '1' and en_cnt >= gen_mode and lo_spd_en_cnt > 2 and ini_key_cnt >= gen_mode*3 then
         o_t_data  <= decrypt((AES256-gen_mode)-1);
         o_t_valid <= t_valid(gen_mode);
         o_t_last  <= t_last(gen_mode);
         o_t_keep  <= t_keep(gen_mode); 
      end if;
   end process;
   
   -- Enable counter to tell when to output data after the initial pipeline delay
   p_en_out : process -- counter to determine first valid output after pipeline delays
   begin
      wait until rising_edge(i_clk);
      if i_rst = '1' or state = config or en_cnt_rst = '1' then
         en_cnt  <= (others  => '0');
      elsif state /= config and en_cnt <= gen_mode  then
         en_cnt  <=  en_cnt + 1;
      end if;
   end process;
   
   ---------------------------------------------------------------------------------------
   -- Key Expansion
   ---------------------------------------------------------------------------------------
   u_key_expansion : entity aes_engine.aes_engine_key_expansion
         port map(
            i_clk          => i_clk,
            i_rst          => i_rst,
            i_key          => outdata,
            i_mode         => gen_mode,
            o_expanded_key => expanded_key
         );

   ---------------------------------------------------------------------------------------
   -- Encryption or decryption Rounds
   ---------------------------------------------------------------------------------------
   -- AXI auxillary signals pipeline  
   t_valid(0) <= t_valid_q;  
   t_last (0) <= t_last_q;   
   t_keep (0) <= t_keep_q;
   
   -- initial round key step for both encryption and decryption
   encrypt(0) <= t_data_q xor expanded_key_q(0);
   decrypt(AES256) <= t_data_q xor dec_expanded_key_q(AES256+1);

   gen_encryption_rounds : for i in 1 to AES256 generate
      u_enc_rnds : entity aes_engine.aes_engine_round
         port map(
            i_clk             => i_clk,
            i_rst             => i_rst,
            i_t_valid         => t_valid(i-1), 
            i_t_last          => t_last (i-1), 
            i_t_keep          => t_keep (i-1), 
            o_t_valid         => t_valid(i), 
            o_t_last          => t_last (i), 
            o_t_keep          => t_keep (i), 
            i_expanded_key    => expanded_key_q(i),
            i_last_rnd        => last_rnd(i-1),
            i_plain_txt       => encrypt(i-1),
            o_rndn_cipher_txt => encrypt(i)
         );
   end generate;
   
   -- reverse key order for decryption
   p_dec_keys : process(all)
   begin
      case gen_mode is
         when AES128 =>
            for i in AES128 downto 0 loop
               dec_expanded_key_q(i+5)  <= expanded_key_q(i);
            end loop;
         when AES192 =>
            for i in AES192 downto 0 loop
               dec_expanded_key_q(i+3)  <= expanded_key_q(i);
            end loop;
         when AES256 =>
            for i in AES256 downto 0 loop
               dec_expanded_key_q(i+1)  <= expanded_key_q(i);
            end loop;
         when others  =>
               null;
      end case;
   end process;
   
   
   gen_decryption_rounds : for i in AES256-1 downto 0 generate
      u_dec_rnds : entity aes_engine.aes_engine_decrypt
         port map(
            i_clk             => i_clk,
            i_rst             => i_rst,
            i_expanded_key    => dec_expanded_key_q(i+1),
            i_last_rnd        => last_rnd_dec(i),
            i_cipher_txt      => decrypt(i+1),
            o_rndn_plain_txt  => decrypt(i)
         );
   end generate;
      
   -----------------------------------------------------------------------------------------
   -- BRAM containing the keys
   -----------------------------------------------------------------------------------------
   p_key_select : process
   begin
      wait until rising_edge(i_clk);
      if  en_cnt = 0 or en_cnt >= gen_mode-1 or state = newkey then -- only allow a new key when engine is not flushing or filling pipeline or when initial load key after reset. 
         addra  <=  key_handle_q;
      end if;
   end process;
   
   u_bram_keys : entity xil_defaultlib.aes_engine_key_bram_blk_mem_gen_0_0
      port map(
          addra  => addra,
          clka   => i_clk,
          dina   => dina,
          douta  => outdata,
          ena    => '1', -- always enabled
          wea(0) => '0'   
      );
   
end mixed;
