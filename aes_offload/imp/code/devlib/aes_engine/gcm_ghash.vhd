--------------------------------------------------------------------------------
--! @File name:     gcm_ghash
--! @Date:          29/04/2019
--! @Description:   The module performs GHASH TAG calculation
--! @Reference:     FIPS PUB 197, November 26, 2001
--! @Source:        https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;
library aes_engine;
use aes_engine.aes_pkg.NB_STAGE_C;
use aes_engine.gcm_pkg.all;

--------------------------------------------------------------------------------
entity gcm_ghash is
    port(
        rst_i                       : in  std_logic;
        clk_i                       : in  std_logic;
        ghash_pkt_val_i             : in  std_logic;
        ghash_text_i                : in  std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
        j0_i                        : in  std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
        h_i                         : in  std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
        tag_done_i                  : in std_logic;
        ghash_tag_o                 : out std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0));
end entity;

--------------------------------------------------------------------------------
architecture arch_gcm_ghash of gcm_ghash is

    --! Signals
    signal x_c                  : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
    signal y_c                  : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
    signal y_s                  : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
    signal x_data_c             : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
    signal y_prev_c             : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
    signal ghash_tag_c          : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);
    signal ghash_tag_s          : std_logic_vector(GCM_DATA_WIDTH_C-1 downto 0);


begin


    --------------------------------------------------------------------------------
    --! Ghash next packet
    --------------------------------------------------------------------------------
    ghash_next_pkt_p : process
    begin
       wait until rising_edge(clk_i);
        if rst_i = '1' then
            y_s <= (others => '0');
        else
            --! Save Y to xor with the next incoming X value
            y_s <= y_c;
        end if;
    end process;

    --! Select X input
    x_data_c    <= ghash_text_i;

    --! Output from the previous gfmul
    y_prev_c    <=  y_s;

    --! gfmul: X input
    x_c         <= x_data_c xor y_prev_c;

    --! TAG update result
    ghash_tag_c <= y_s xor j0_i;



    --------------------------------------------------------------------------------
    --! Sample the ghash tag
    --------------------------------------------------------------------------------
    sample_tag_p : process
    begin
       wait until rising_edge(clk_i);
        if(rst_i = '1') then
            ghash_tag_s <= (others => '0');
        elsif tag_done_i = '1' then
            ghash_tag_s <= ghash_tag_c;
        end if;
    end process;

    --------------------------------------------------------------------------------
    --! Component instantiation
    --------------------------------------------------------------------------------
    u_ghash_gfmul: entity aes_engine.ghash_gfmul
        port map(
            gf_mult_x_i => x_c,
            gf_mult_h_i => h_i,
            gf_mult_y_o => y_c);

    --------------------------------------------------------------------------------
    ghash_tag_o         <= ghash_tag_s;

end architecture;
