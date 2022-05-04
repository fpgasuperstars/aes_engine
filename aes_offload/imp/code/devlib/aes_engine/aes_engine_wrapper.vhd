---------------------------------------------------------------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_wrapper.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
---------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
library aes_engine;
use aes_engine.aes_engine_pkg.all;

entity aes_engine_wrapper is
   port(
      i_clk_p : in std_logic;
      i_clk_n : in std_logic;
      -- Led
      o_done  : out std_logic
      
   );
end entity;

architecture structural of aes_engine_wrapper is

--component clk_wiz_0
--port
-- (-- Clock in ports
--  -- Clock out ports
--  clk_out1          : out    std_logic;
--  -- Status and control signals
--  reset             : in     std_logic;
--  clk_in1_p         : in     std_logic;
--  clk_in1_n         : in     std_logic
-- );
--end component;

COMPONENT axis_data_fifo_0
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    s_axis_tkeep : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_tlast : IN STD_LOGIC;
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    m_axis_tkeep : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_tlast : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    probe_in1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_in2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out4 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out5 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

   -- Signals
   signal rst             : std_logic;
   signal clk_s,clk_lvcmos: std_logic;
   signal tdata_input     : std_logic_vector(AXI_T_DATA-1 downto 0);
   signal cnt             : unsigned(2 downto 0);
   -- AXI stream M2S                                                    
   signal tdatai          : std_logic_vector(AXI_T_DATA-1 downto 0);     
   signal tvalidi         : std_logic;                                   
   signal tlasti          : std_logic;                                   
   signal tkeepi          : std_logic_vector((BYTE_WIDTH*2)-1 downto 0); 
   signal treadyo         : std_logic;                                   
    -- AXI stream S2M                                                
   signal t_valido        : std_logic;                                   
   signal t_lasto         : std_logic;                                   
   signal t_keepo         : std_logic_vector((BYTE_WIDTH*2)-1 downto 0); 
   signal t_datao         : std_logic_vector(AXI_T_DATA-1 downto 0);     
   -- Keys                                                          
   signal key_handle      : std_logic_vector(9 downto 0);                 
   
begin
   
   -- DIFF_SSTL12 input to internal single
   CLK_IBUFGDS : IBUFGDS
   generic map(
     IOSTANDARD => "DIFF_SSTL12"
      )
   port map(
      I  => i_clk_p,
      IB => i_clk_n,
      O  => clk_s
   );
 
   -----------------------------------------------------------------------------------------
   -- Clock generation
   -----------------------------------------------------------------------------------------
  -- CLK : clk_wiz_0
  --    port map ( 
  --    -- Clock out ports  
  --       clk_out1 => clk_s,
  --    -- Status and control signals                
  --       reset => rst,
  --    -- Clock in ports
  --       clk_in1_p => i_clk_p,
  --       clk_in1_n => i_clk_n
  --       );
  
  fifo : axis_data_fifo_0
  PORT MAP (
    s_axis_aresetn => rst,
    s_axis_aclk => clk_s,
    s_axis_tvalid => t_valido,
    s_axis_tready => open,
    s_axis_tdata => t_datao,
    s_axis_tkeep => t_keepo,
    s_axis_tlast => t_lasto,
    m_axis_tvalid => tvalidi,
    m_axis_tready => treadyo,
    m_axis_tdata => tdatai,
    m_axis_tkeep => tkeepi,
    m_axis_tlast => tlasti,
    almost_empty => open,
    almost_full => open
  );
    
   u_top : entity aes_engine.aes_engine_top
      generic map(
         g_speed_sel       => '1',
         g_decryption_sel  => '0'
       )
      port map(
         i_clk             => clk_s   ,
         i_rst             => rst ,
         -- AXI stream M2S
         i_t_data          => tdatai  ,
         i_t_valid         => tvalidi ,
         i_t_last          => tlasti  ,
         i_t_keep          => tkeepi  ,
         o_t_ready         => treadyo ,
         -- AXI stream S2M
         o_t_valid         => t_valido ,
         o_t_last          => t_lasto  ,
         o_t_keep          => t_keepo  ,
         o_t_data          => t_datao  ,
         -- Keys
         i_key_handle      => key_handle,
         o_done            => o_done 
       );
      
   -------------------------------------------------------------------------------------------
   ---- Loop back
   -------------------------------------------------------------------------------------------
   --p_loop : process
   --begin
   --   wait until rising_edge(clk_s);
   --   if rst then
   --      cnt  <= (others  =>  '0');
   --   elsif cnt < 2 and treadyo = '1' then
   --      cnt  <= cnt + 1;
   --   end if;
   --end process;
   --
   --tdata_input  <=  tdatai  when cnt < 1 else
   --                 t_datao when cnt >= 1; -- loop output data back to input after first clock cycle

 vio : vio_0
    port map (
       clk => clk_s,
       probe_in0(127 downto 0)   => t_datao,    
       probe_in1(15 downto 0)    => t_keepo,    
       probe_in2(0)              => t_lasto,    
       probe_in3(0)              => t_valido,   
       probe_in4(0)              => treadyo,    
       probe_out0(127 downto 0)  => tdatai,       
       probe_out1(15 downto 0)   => tkeepi,       
       probe_out2(9 downto 0)    => key_handle,   
       probe_out3(0)             => rst,          
       probe_out4(0)             => tlasti,       
       probe_out5(0)             => tvalidi       
    );
    
    
 
end structural;