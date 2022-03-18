---------------------------------------------------------------------------------------
-- Copyright nCipher Entrust 2022. All rights reserved.
-- Filename : aes_engine_pkg.vhd
-- Creation date : 2022-01-21
-- Author(s) : okeefej
-- Description :
-- This package contains all necessary data to be used inside the offload engine
---------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package aes_engine_pkg is
   -- constants and types
   constant AES128          : integer := 10;           -- number or rounds depending on setting
   constant AES192          : integer := 12;           -- number or rounds depending on setting
   constant AES256          : integer := 14;           -- number or rounds depending on setting
   constant BYTE_WIDTH      : natural := 8;            -- To be used where a byte is declared
   constant AXI_T_DATA      : natural := 128;          -- T_data bit width
   constant AES192_KEY      : natural := 192;          -- AES 192 KEY bit width
   constant AES256_KEY      : natural := 256;          -- AES 256 KEY bit width
   constant LO              : natural := 10;           -- Low speed mode duty cycle setting. every 10 rounds le tthe next input enter 
   type T_jindex is array (natural range<>) of integer;
   constant j : T_jindex := (0,4,8,12);           -- used for generation of the mixed column logic
   constant l : T_jindex := (0,3,6,9,12);         -- used for generation of the mixed column logic
   constant g : T_jindex := (1,3,5,7,9,11,13,15); -- used for generation of the 256 key expansion g function
   constant h : T_jindex := (0,2,4,6,8,10,12,14); -- used for generation of the 256 key expansion h function
   constant r : T_jindex := (0,2,4,6,8);          -- used for converting 192 to 128
   -- types
   type     T_EXPANDED_KEYS is array (0 to AES256+1)          of std_logic_vector(AXI_T_DATA-1 downto 0);   -- array containing the expanded keys for 128/256
   type     T_EXP_KEYS_192  is array (0 to AES256+1)          of std_logic_vector(AES192_KEY-1 downto 0);   -- array containing the expanded keys for 192
   type     T_TEMP_192      is array (0 to AES256+1)          of std_logic_vector(BYTE_WIDTH*8-1 downto 0); -- array containing the temp signals for the last two words of a 192 bit key
   type     T_RND_CONST     is array (0 to AES256-1)          of std_logic_vector(BYTE_WIDTH*4-1 downto 0); -- array containing the round constans for key expansion
   type     T_STATE_ARRAY   is array (0 to (BYTE_WIDTH*2)-1)  of std_logic_vector(BYTE_WIDTH-1 downto 0);   -- array containig the state array
   type     T_G_FUNC        is array (0 to AES256+1)          of std_logic_vector(BYTE_WIDTH*4-1 downto 0); -- array containing the g function outputs
   type     T_G_SBOX        is array (0 to (BYTE_WIDTH/2)-1)  of std_logic_vector(BYTE_WIDTH-1 downto 0);   -- G function array of an array containing 4 bytes used in the sbox g function
   type     T_G_SBOX_ARRAY  is array (0 to AES256-1)          of T_G_SBOX;
   type     T_SBOX_ARRAY    is array (0 to (2**BYTE_WIDTH)-1) of std_logic_vector(BYTE_WIDTH-1 downto 0);   -- contains the Sbox data
   type     T_COLUMN_32     is array (0 to 3)                 of std_logic_vector(BYTE_WIDTH-1 downto 0);   -- column data for mix column function
   -- axi
   type     T_AXI_STREAM    is array(0 to AES256)           of std_logic;
   type     T_AXI_TKEEP     is array(0 to AES256)           of std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
   
   -- Sbox used for encryption
   constant SBOX                      : T_SBOX_ARRAY     := (x"63",x"7c",x"77",x"7b",x"f2",x"6b",x"6f",x"c5",x"30",x"01",x"67",x"2b",x"fe",x"d7",x"ab",x"76",
                                                             x"ca",x"82",x"c9",x"7d",x"fa",x"59",x"47",x"f0",x"ad",x"d4",x"a2",x"af",x"9c",x"a4",x"72",x"c0",
                                                             x"b7",x"fd",x"93",x"26",x"36",x"3f",x"f7",x"cc",x"34",x"a5",x"e5",x"f1",x"71",x"d8",x"31",x"15",
                                                             x"04",x"c7",x"23",x"c3",x"18",x"96",x"05",x"9a",x"07",x"12",x"80",x"e2",x"eb",x"27",x"b2",x"75",
                                                             x"09",x"83",x"2c",x"1a",x"1b",x"6e",x"5a",x"a0",x"52",x"3b",x"d6",x"b3",x"29",x"e3",x"2f",x"84",
                                                             x"53",x"d1",x"00",x"ed",x"20",x"fc",x"b1",x"5b",x"6a",x"cb",x"be",x"39",x"4a",x"4c",x"58",x"cf",
                                                             x"d0",x"ef",x"aa",x"fb",x"43",x"4d",x"33",x"85",x"45",x"f9",x"02",x"7f",x"50",x"3c",x"9f",x"a8",
                                                             x"51",x"a3",x"40",x"8f",x"92",x"9d",x"38",x"f5",x"bc",x"b6",x"da",x"21",x"10",x"ff",x"f3",x"d2",
                                                             x"cd",x"0c",x"13",x"ec",x"5f",x"97",x"44",x"17",x"c4",x"a7",x"7e",x"3d",x"64",x"5d",x"19",x"73",
                                                             x"60",x"81",x"4f",x"dc",x"22",x"2a",x"90",x"88",x"46",x"ee",x"b8",x"14",x"de",x"5e",x"0b",x"db",
                                                             x"e0",x"32",x"3a",x"0a",x"49",x"06",x"24",x"5c",x"c2",x"d3",x"ac",x"62",x"91",x"95",x"e4",x"79",
                                                             x"e7",x"c8",x"37",x"6d",x"8d",x"d5",x"4e",x"a9",x"6c",x"56",x"f4",x"ea",x"65",x"7a",x"ae",x"08",
                                                             x"ba",x"78",x"25",x"2e",x"1c",x"a6",x"b4",x"c6",x"e8",x"dd",x"74",x"1f",x"4b",x"bd",x"8b",x"8a",
                                                             x"70",x"3e",x"b5",x"66",x"48",x"03",x"f6",x"0e",x"61",x"35",x"57",x"b9",x"86",x"c1",x"1d",x"9e",
                                                             x"e1",x"f8",x"98",x"11",x"69",x"d9",x"8e",x"94",x"9b",x"1e",x"87",x"e9",x"ce",x"55",x"28",x"df",
                                                             x"8c",x"a1",x"89",x"0d",x"bf",x"e6",x"42",x"68",x"41",x"99",x"2d",x"0f",x"b0",x"54",x"bb",x"16");
   -- Mix column matrix for encryption                                                      
   constant ENCRYPT_MIX_COLUMN_MATRIX : T_STATE_ARRAY   :=  (x"02",x"03",x"01",x"01",
                                                             x"01",x"02",x"03",x"01",
                                                             x"01",x"01",x"02",x"03",
                                                             x"03",x"01",x"01",x"02");
                           
   -- G function Rj constants                                                      
   constant ROUND_CONSTS              : T_RND_CONST     :=  (x"00000001",x"00000002",x"00000004",x"00000008",x"00000010",x"00000020",x"00000040",x"00000080",x"0000001B",x"00000036",x"0000006C", x"000000D8", x"000000AB", x"0000004D");
   
end package;