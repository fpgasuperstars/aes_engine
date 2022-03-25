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
     g_Mode      : integer   := AES128; -- Set to desired mode AES128/AES192/AES256 this will have an effect on the number of rounds generated
     g_speed_sel : std_logic := '0'     -- 1 = LO speed, 0 = HI speed
   );
   port(
      --i_clk_p         : in  std_logic; -- used for the clk wizard
      --i_clk_n         : in  std_logic; -- used for the clk wizard
      i_clk             : in  std_logic;
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
      --LED
      locked_led        : out std_logic
   );
end entity;

architecture mixed of aes_engine_top is
   -- constants
   constant last_rnd       : std_logic_vector(g_Mode-1 downto 0) := (g_mode-1 => '1', others => '0');
   constant DUTY_EN        : integer := 2; -- enable duty cycle counter to start so that when the speed_en signal is a 1 the initial pipeline delay is accounted for
   
   -- Types
   type  T_CIPHER_TXT    is array (0 to g_Mode) of std_logic_vector(AXI_T_DATA-1 downto 0); -- array containing the cipher text output from each round
   type  T_STATES        is (newkey, normal, config, start, load_key);
      
   -- Signals
   signal state                                               : T_STATES;
   signal rnd_cipher_txt                                      : T_CIPHER_TXT;
   signal expanded_key_q, expanded_key                        : T_EXPANDED_KEYS;                             
   signal t_data_q, config_data                               : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal duty_cycle_cnt, flushout_cnt, en_cnt, lo_spd_en_cnt : unsigned(4 downto 0);
   signal speed_en, t_valid_q, t_last_q, new_key, clk         : std_logic;
   signal t_keep_q                                            : std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
   signal t_valid, t_last                                     : T_AXI_STREAM;
   signal t_keep                                              : T_AXI_TKEEP;
                                                              
   -- BRAM                                                    
   signal addra, key_handle_q                                 : std_logic_vector(9 downto 0);
   signal outdata, dina                                       : std_logic_vector(AES256_KEY-1 downto 0);
   
begin
   -----------------------------------------------------------------------------------------
   ---- Clock generation
   -----------------------------------------------------------------------------------------
   --u_clk_gen : entity xil_defaultlib.aes_engine_clk
   --port map (
   --   CLK_IN1_D_0_clk_n => i_clk_n,
   --   CLK_IN1_D_0_clk_p => i_clk_p,
   --   clk_out1_0        => clk,
   --   locked_0          => locked_led,
   --   reset_0           => i_rst
   -- );
   locked_led  <= '1'; -- remove this and uncomment above coe to add clk wizard for implementation
   ---------------------------------------------------------------------------------------
   -- Engine  control state machine
   ---------------------------------------------------------------------------------------
   p_control : process
   begin
      wait until rising_edge(i_clk);
         if i_rst then
            state  <=  start;
            expanded_key_q <= (others  => (others  => '0'));
            t_data_q  <= (others  => '0');
         else
         case state is
            when start  =>
               state  <= load_key;
            when load_key  => -- allow time for key to load ready for first encryption
               if duty_cycle_cnt <= g_mode then
                  state <= load_key;
               else
                  expanded_key_q <= expanded_key; -- register the expanded keys
                  config_data <= i_t_data;
                  state          <= config;
               end if;
            when config =>
               if new_key = '1' then
                  state <= newkey;
               elsif i_t_valid then
                  config_data <= i_t_data;
                  state       <= normal;
               end if;
               
            when normal =>
               if new_key = '1' then
                  state <= newkey;
               elsif o_t_ready then
                  for i in 0 to i_t_keep'length-1 loop -- when the t_keep is true allow those selected bytes to enter the engine otherwise set to 0's
                     t_data_q((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= i_t_data((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) when t_keep_q(i) = '1' else (others  => '0'); -- pass valid bytes using the t_keep_q signal, using the delayed signal allows for configuration data to always be read as 128bit
                  end loop; 
                  state <= normal;
               end if;
               
            when newkey =>
               if flushout_cnt = g_Mode *2+1 then
                  expanded_key_q <= expanded_key; -- register the expanded keys
                  for i in 0 to i_t_keep'length-1 loop -- when the t_keep is true allow those selected bytes to enter the engine otherwise set to 0's
                     t_data_q((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) <= i_t_data((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) when t_keep_q(i) = '1' else (others  => '0'); -- pass valid bytes using the t_keep_q signal, using the delayed signal allows for configuration data to always be read as 128bit
                  end loop; 
                  state  <=  config;
               else
                  state  <= newkey;
               end if;
               
            when others  =>
               null;
         end case;
         end if;
   end process;
   
   new_key     <= '1'      when key_handle_q /= i_key_handle else '0';
   o_t_ready   <= '0'      when state = newkey or new_key = '1' or state = start or (g_speed_sel = '1' and speed_en = '0') or state = load_key  else '1';

   ---------------------------------------------------------------------------------------
   -- Speed selection control
   ---------------------------------------------------------------------------------------
   -- Duty cycle counter used for speed selection
   p_speed_select : process
   begin
      wait until rising_edge(i_clk);
      if i_rst = '1'  then
         duty_cycle_cnt <= (others => '0');
      elsif duty_cycle_cnt = g_mode+1 then
         duty_cycle_cnt <= (others => '0');
      else
         duty_cycle_cnt <= duty_cycle_cnt + 1;
      end if;
   end process;
   
   -- run at LO or Hi speed depending on speed selection input  
   speed_en <= '1' when g_speed_sel = '1' and duty_cycle_cnt = g_mode+1 else
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
   
      
   ---------------------------------------------------------------------------------------
   -- flush out when new key
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
   -- Engine control and output registers at selected speed
   ---------------------------------------------------------------------------------------
   -- Enable counter to tell when to output data after the initial pipeline delay
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
      elsif speed_en = '1' and en_cnt > g_Mode and lo_spd_en_cnt > 2 then
         o_t_data  <= rnd_cipher_txt(g_Mode);
         o_t_valid <= t_valid(g_Mode);
         o_t_last  <= t_last(g_Mode);
         o_t_keep  <= t_keep(g_Mode);  
      end if;
   end process;
   
   p_en_out : process -- counter to determine first valid output after pipeline delays
   begin
      wait until rising_edge(i_clk);
      if i_rst = '1' or state = config then
         en_cnt  <= (others  => '0');
      elsif (state = normal or state = newkey) and en_cnt < g_Mode +1  then
         en_cnt  <=  en_cnt + 1;
      end if;
   end process;
   
   ---------------------------------------------------------------------------------------
   -- Key Expansion
   ---------------------------------------------------------------------------------------
   u_key_expansion : entity aes_engine.aes_engine_key_expansion
      generic map(
         g_Mode => g_Mode
      )
         port map(
            i_clk          => i_clk,
            i_rst          => i_rst,
            i_key          => outdata,
            o_expanded_key => expanded_key
         );
         
   ---------------------------------------------------------------------------------------
   -- Encryption Rounds
   ---------------------------------------------------------------------------------------
   t_valid(0) <= t_valid_q;  
   t_last (0) <= t_last_q;   
   t_keep (0) <= t_keep_q;
   --   
   rnd_cipher_txt(0) <= t_data_q xor expanded_key_q(0); -- first round key XOR
   gen_encryption_rounds : for i in 1 to g_Mode generate
      u_enc_rnd1 : entity aes_engine.aes_engine_round
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
            i_plain_txt       => rnd_cipher_txt(i-1),
            o_rndn_cipher_txt => rnd_cipher_txt(i)
         );
      end generate;
      
   -----------------------------------------------------------------------------------------
   -- BRAM containing the keys
   -----------------------------------------------------------------------------------------
   p_key_select : process
   begin
      wait until rising_edge(i_clk);
      if i_rst then
         addra  <=  (others  => '0');
      elsif  en_cnt = 0 or en_cnt >= g_mode or state = load_key then -- only allow a new key when engine is not filling pipeline or when initial load key after reset. 
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
