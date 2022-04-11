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
      i_clk_n : in std_logic
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

  signal rst           : std_logic;
  signal clk_s,clk_lvcmos         : std_logic;

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
   ------ Clock generation
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
    
   u_top : entity aes_engine.aes_engine_top
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
         o_done            => open 
      );

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