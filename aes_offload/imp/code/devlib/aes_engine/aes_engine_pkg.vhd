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
   constant MODE_C          : natural := 8;            -- length of mode field in the configuration data 
   constant IV_C            : natural := 96;           -- length of the iv in the configuration data
   constant AES_MODE_C      : natural := 2;            -- length of aes mode in the configuration data
   constant GCM_MODE_C      : std_logic_vector(BYTE_WIDTH-1 downto 0) := x"01";            -- GCM mode value
   constant AAD_DONE_C      : std_logic_vector(AXI_T_DATA-1 downto 0) := x"EFBEEFBEEFBEEFBEEFBEEFBEEFBEEFBE"; -- Value to signify end of authentication data
   constant GHASH_ZEROS     : std_logic_vector(AXI_T_DATA-1 downto 0) := x"00000000000000000000000000000000"; -- this value gets encrypted for use in the gcm GHASH function
   
   type T_jindex is array (natural range<>) of integer;
   constant j : T_jindex := (0,4,8,12);           -- used for generation of the mixed column logic
   constant l : T_jindex := (0,3,6,9,12);         -- used for generation of the mixed column logic
   constant g : T_jindex := (1,3,5,7,9,11,13,15); -- used for generation of the 256 key expansion g function
   constant h : T_jindex := (0,2,4,6,8,10,12,14); -- used for generation of the 256 key expansion h function
   constant r : T_jindex := (0,2,4,6,8);          -- used for converting 192 to 128
   -- types
   type     T_EXPANDED_KEYS is array (0 to AES256+1)          of std_logic_vector(AXI_T_DATA-1 downto 0);   -- array containing the expanded keys for 128/256
   type     T_DEC_EXPANDED_KEYS is array (AES256+1 downto 0)  of std_logic_vector(AXI_T_DATA-1 downto 0);   -- array containing the expanded keys for 128/256
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
   type     T_AXI_STREAM    is array(0 to 16)           of std_logic;
   type     T_AXI_TKEEP     is array(0 to AES256)             of std_logic_vector((BYTE_WIDTH*2)-1 downto 0);
      
   function mult(v1, v2 : in std_logic_vector) return std_logic_vector;
   function reverse_byte_order(a : std_logic_vector) return std_logic_vector;
   
   -- Encrpytion
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
   -- Decryption
   -- Sbox used for decryption
   constant SBOX_INV                  : T_SBOX_ARRAY     := (x"52",x"09",x"6a",x"d5",x"30",x"36",x"a5",x"38",x"bf",x"40",x"a3",x"9e",x"81",x"f3",x"d7",x"fb",
                                                             x"7c",x"e3",x"39",x"82",x"9b",x"2f",x"ff",x"87",x"34",x"8e",x"43",x"44",x"c4",x"de",x"e9",x"cb",
                                                             x"54",x"7b",x"94",x"32",x"a6",x"c2",x"23",x"3d",x"ee",x"4c",x"95",x"0b",x"42",x"fa",x"c3",x"4e",
                                                             x"08",x"2e",x"a1",x"66",x"28",x"d9",x"24",x"b2",x"76",x"5b",x"a2",x"49",x"6d",x"8b",x"d1",x"25",
                                                             x"72",x"f8",x"f6",x"64",x"86",x"68",x"98",x"16",x"d4",x"a4",x"5c",x"cc",x"5d",x"65",x"b6",x"92",
                                                             x"6c",x"70",x"48",x"50",x"fd",x"ed",x"b9",x"da",x"5e",x"15",x"46",x"57",x"a7",x"8d",x"9d",x"84",
                                                             x"90",x"d8",x"ab",x"00",x"8c",x"bc",x"d3",x"0a",x"f7",x"e4",x"58",x"05",x"b8",x"b3",x"45",x"06",
                                                             x"d0",x"2c",x"1e",x"8f",x"ca",x"3f",x"0f",x"02",x"c1",x"af",x"bd",x"03",x"01",x"13",x"8a",x"6b",
                                                             x"3a",x"91",x"11",x"41",x"4f",x"67",x"dc",x"ea",x"97",x"f2",x"cf",x"ce",x"f0",x"b4",x"e6",x"73",
                                                             x"96",x"ac",x"74",x"22",x"e7",x"ad",x"35",x"85",x"e2",x"f9",x"37",x"e8",x"1c",x"75",x"df",x"6e",
                                                             x"47",x"f1",x"1a",x"71",x"1d",x"29",x"c5",x"89",x"6f",x"b7",x"62",x"0e",x"aa",x"18",x"be",x"1b",
                                                             x"fc",x"56",x"3e",x"4b",x"c6",x"d2",x"79",x"20",x"9a",x"db",x"c0",x"fe",x"78",x"cd",x"5a",x"f4",
                                                             x"1f",x"dd",x"a8",x"33",x"88",x"07",x"c7",x"31",x"b1",x"12",x"10",x"59",x"27",x"80",x"ec",x"5f",
                                                             x"60",x"51",x"7f",x"a9",x"19",x"b5",x"4a",x"0d",x"2d",x"e5",x"7a",x"9f",x"93",x"c9",x"9c",x"ef",
                                                             x"a0",x"e0",x"3b",x"4d",x"ae",x"2a",x"f5",x"b0",x"c8",x"eb",x"bb",x"3c",x"83",x"53",x"99",x"61",
                                                             x"17",x"2b",x"04",x"7e",x"ba",x"77",x"d6",x"26",x"e1",x"69",x"14",x"63",x"55",x"21",x"0c",x"7d");
   -- Mix column matrix for decryption                                                      
   constant MULT_9                   : T_SBOX_ARRAY      := (x"00",x"09",x"12",x"1b",x"24",x"2d",x"36",x"3f",x"48",x"41",x"5a",x"53",x"6c",x"65",x"7e",x"77",
                                                             x"90",x"99",x"82",x"8b",x"b4",x"bd",x"a6",x"af",x"d8",x"d1",x"ca",x"c3",x"fc",x"f5",x"ee",x"e7",
                                                             x"3b",x"32",x"29",x"20",x"1f",x"16",x"0d",x"04",x"73",x"7a",x"61",x"68",x"57",x"5e",x"45",x"4c",
                                                             x"ab",x"a2",x"b9",x"b0",x"8f",x"86",x"9d",x"94",x"e3",x"ea",x"f1",x"f8",x"c7",x"ce",x"d5",x"dc",
                                                             x"76",x"7f",x"64",x"6d",x"52",x"5b",x"40",x"49",x"3e",x"37",x"2c",x"25",x"1a",x"13",x"08",x"01",
                                                             x"e6",x"ef",x"f4",x"fd",x"c2",x"cb",x"d0",x"d9",x"ae",x"a7",x"bc",x"b5",x"8a",x"83",x"98",x"91",
                                                             x"4d",x"44",x"5f",x"56",x"69",x"60",x"7b",x"72",x"05",x"0c",x"17",x"1e",x"21",x"28",x"33",x"3a",
                                                             x"dd",x"d4",x"cf",x"c6",x"f9",x"f0",x"eb",x"e2",x"95",x"9c",x"87",x"8e",x"b1",x"b8",x"a3",x"aa",	
                                                             x"ec",x"e5",x"fe",x"f7",x"c8",x"c1",x"da",x"d3",x"a4",x"ad",x"b6",x"bf",x"80",x"89",x"92",x"9b",	
                                                             x"7c",x"75",x"6e",x"67",x"58",x"51",x"4a",x"43",x"34",x"3d",x"26",x"2f",x"10",x"19",x"02",x"0b",
                                                             x"d7",x"de",x"c5",x"cc",x"f3",x"fa",x"e1",x"e8",x"9f",x"96",x"8d",x"84",x"bb",x"b2",x"a9",x"a0",
                                                             x"47",x"4e",x"55",x"5c",x"63",x"6a",x"71",x"78",x"0f",x"06",x"1d",x"14",x"2b",x"22",x"39",x"30",
                                                             x"9a",x"93",x"88",x"81",x"be",x"b7",x"ac",x"a5",x"d2",x"db",x"c0",x"c9",x"f6",x"ff",x"e4",x"ed",
                                                             x"0a",x"03",x"18",x"11",x"2e",x"27",x"3c",x"35",x"42",x"4b",x"50",x"59",x"66",x"6f",x"74",x"7d",	
                                                             x"a1",x"a8",x"b3",x"ba",x"85",x"8c",x"97",x"9e",x"e9",x"e0",x"fb",x"f2",x"cd",x"c4",x"df",x"d6",
                                                             x"31",x"38",x"23",x"2a",x"15",x"1c",x"07",x"0e",x"79",x"70",x"6b",x"62",x"5d",x"54",x"4f",x"46");
   -- Mix column matrix for decryption                                                      
   constant MULT_11                   : T_SBOX_ARRAY     := (x"00",x"0b",x"16",x"1d",x"2c",x"27",x"3a",x"31",x"58",x"53",x"4e",x"45",x"74",x"7f",x"62",x"69",
                                                             x"b0",x"bb",x"a6",x"ad",x"9c",x"97",x"8a",x"81",x"e8",x"e3",x"fe",x"f5",x"c4",x"cf",x"d2",x"d9",
                                                             x"7b",x"70",x"6d",x"66",x"57",x"5c",x"41",x"4a",x"23",x"28",x"35",x"3e",x"0f",x"04",x"19",x"12",
                                                             x"cb",x"c0",x"dd",x"d6",x"e7",x"ec",x"f1",x"fa",x"93",x"98",x"85",x"8e",x"bf",x"b4",x"a9",x"a2",
                                                             x"f6",x"fd",x"e0",x"eb",x"da",x"d1",x"cc",x"c7",x"ae",x"a5",x"b8",x"b3",x"82",x"89",x"94",x"9f",
                                                             x"46",x"4d",x"50",x"5b",x"6a",x"61",x"7c",x"77",x"1e",x"15",x"08",x"03",x"32",x"39",x"24",x"2f",
                                                             x"8d",x"86",x"9b",x"90",x"a1",x"aa",x"b7",x"bc",x"d5",x"de",x"c3",x"c8",x"f9",x"f2",x"ef",x"e4",
                                                             x"3d",x"36",x"2b",x"20",x"11",x"1a",x"07",x"0c",x"65",x"6e",x"73",x"78",x"49",x"42",x"5f",x"54", 
                                                             x"f7",x"fc",x"e1",x"ea",x"db",x"d0",x"cd",x"c6",x"af",x"a4",x"b9",x"b2",x"83",x"88",x"95",x"9e", 
                                                             x"47",x"4c",x"51",x"5a",x"6b",x"60",x"7d",x"76",x"1f",x"14",x"09",x"02",x"33",x"38",x"25",x"2e",
                                                             x"8c",x"87",x"9a",x"91",x"a0",x"ab",x"b6",x"bd",x"d4",x"df",x"c2",x"c9",x"f8",x"f3",x"ee",x"e5",
                                                             x"3c",x"37",x"2a",x"21",x"10",x"1b",x"06",x"0d",x"64",x"6f",x"72",x"79",x"48",x"43",x"5e",x"55",
                                                             x"01",x"0a",x"17",x"1c",x"2d",x"26",x"3b",x"30",x"59",x"52",x"4f",x"44",x"75",x"7e",x"63",x"68",
                                                             x"b1",x"ba",x"a7",x"ac",x"9d",x"96",x"8b",x"80",x"e9",x"e2",x"ff",x"f4",x"c5",x"ce",x"d3",x"d8", 
                                                             x"7a",x"71",x"6c",x"67",x"56",x"5d",x"40",x"4b",x"22",x"29",x"34",x"3f",x"0e",x"05",x"18",x"13",
                                                             x"ca",x"c1",x"dc",x"d7",x"e6",x"ed",x"f0",x"fb",x"92",x"99",x"84",x"8f",x"be",x"b5",x"a8",x"a3");   

   -- Mix column matrix for decryption                                                      
   constant MULT_13                   : T_SBOX_ARRAY     := (x"00",x"0d",x"1a",x"17",x"34",x"39",x"2e",x"23",x"68",x"65",x"72",x"7f",x"5c",x"51",x"46",x"4b",
                                                             x"d0",x"dd",x"ca",x"c7",x"e4",x"e9",x"fe",x"f3",x"b8",x"b5",x"a2",x"af",x"8c",x"81",x"96",x"9b",
                                                             x"bb",x"b6",x"a1",x"ac",x"8f",x"82",x"95",x"98",x"d3",x"de",x"c9",x"c4",x"e7",x"ea",x"fd",x"f0",
                                                             x"6b",x"66",x"71",x"7c",x"5f",x"52",x"45",x"48",x"03",x"0e",x"19",x"14",x"37",x"3a",x"2d",x"20",
                                                             x"6d",x"60",x"77",x"7a",x"59",x"54",x"43",x"4e",x"05",x"08",x"1f",x"12",x"31",x"3c",x"2b",x"26",
                                                             x"bd",x"b0",x"a7",x"aa",x"89",x"84",x"93",x"9e",x"d5",x"d8",x"cf",x"c2",x"e1",x"ec",x"fb",x"f6",
                                                             x"d6",x"db",x"cc",x"c1",x"e2",x"ef",x"f8",x"f5",x"be",x"b3",x"a4",x"a9",x"8a",x"87",x"90",x"9d",
                                                             x"06",x"0b",x"1c",x"11",x"32",x"3f",x"28",x"25",x"6e",x"63",x"74",x"79",x"5a",x"57",x"40",x"4d", 
                                                             x"da",x"d7",x"c0",x"cd",x"ee",x"e3",x"f4",x"f9",x"b2",x"bf",x"a8",x"a5",x"86",x"8b",x"9c",x"91", 
                                                             x"0a",x"07",x"10",x"1d",x"3e",x"33",x"24",x"29",x"62",x"6f",x"78",x"75",x"56",x"5b",x"4c",x"41",
                                                             x"61",x"6c",x"7b",x"76",x"55",x"58",x"4f",x"42",x"09",x"04",x"13",x"1e",x"3d",x"30",x"27",x"2a",
                                                             x"b1",x"bc",x"ab",x"a6",x"85",x"88",x"9f",x"92",x"d9",x"d4",x"c3",x"ce",x"ed",x"e0",x"f7",x"fa",
                                                             x"b7",x"ba",x"ad",x"a0",x"83",x"8e",x"99",x"94",x"df",x"d2",x"c5",x"c8",x"eb",x"e6",x"f1",x"fc",
                                                             x"67",x"6a",x"7d",x"70",x"53",x"5e",x"49",x"44",x"0f",x"02",x"15",x"18",x"3b",x"36",x"21",x"2c", 
                                                             x"0c",x"01",x"16",x"1b",x"38",x"35",x"22",x"2f",x"64",x"69",x"7e",x"73",x"50",x"5d",x"4a",x"47",
                                                             x"dc",x"d1",x"c6",x"cb",x"e8",x"e5",x"f2",x"ff",x"b4",x"b9",x"ae",x"a3",x"80",x"8d",x"9a",x"97");  
   -- Mix column matrix for decryption                                                      
   constant MULT_14                   : T_SBOX_ARRAY     := (x"00",x"0e",x"1c",x"12",x"38",x"36",x"24",x"2a",x"70",x"7e",x"6c",x"62",x"48",x"46",x"54",x"5a",
                                                             x"e0",x"ee",x"fc",x"f2",x"d8",x"d6",x"c4",x"ca",x"90",x"9e",x"8c",x"82",x"a8",x"a6",x"b4",x"ba",
                                                             x"db",x"d5",x"c7",x"c9",x"e3",x"ed",x"ff",x"f1",x"ab",x"a5",x"b7",x"b9",x"93",x"9d",x"8f",x"81",
                                                             x"3b",x"35",x"27",x"29",x"03",x"0d",x"1f",x"11",x"4b",x"45",x"57",x"59",x"73",x"7d",x"6f",x"61",
                                                             x"ad",x"a3",x"b1",x"bf",x"95",x"9b",x"89",x"87",x"dd",x"d3",x"c1",x"cf",x"e5",x"eb",x"f9",x"f7",
                                                             x"4d",x"43",x"51",x"5f",x"75",x"7b",x"69",x"67",x"3d",x"33",x"21",x"2f",x"05",x"0b",x"19",x"17",
                                                             x"76",x"78",x"6a",x"64",x"4e",x"40",x"52",x"5c",x"06",x"08",x"1a",x"14",x"3e",x"30",x"22",x"2c",
                                                             x"96",x"98",x"8a",x"84",x"ae",x"a0",x"b2",x"bc",x"e6",x"e8",x"fa",x"f4",x"de",x"d0",x"c2",x"cc", 
                                                             x"41",x"4f",x"5d",x"53",x"79",x"77",x"65",x"6b",x"31",x"3f",x"2d",x"23",x"09",x"07",x"15",x"1b", 
                                                             x"a1",x"af",x"bd",x"b3",x"99",x"97",x"85",x"8b",x"d1",x"df",x"cd",x"c3",x"e9",x"e7",x"f5",x"fb",
                                                             x"9a",x"94",x"86",x"88",x"a2",x"ac",x"be",x"b0",x"ea",x"e4",x"f6",x"f8",x"d2",x"dc",x"ce",x"c0",
                                                             x"7a",x"74",x"66",x"68",x"42",x"4c",x"5e",x"50",x"0a",x"04",x"16",x"18",x"32",x"3c",x"2e",x"20",
                                                             x"ec",x"e2",x"f0",x"fe",x"d4",x"da",x"c8",x"c6",x"9c",x"92",x"80",x"8e",x"a4",x"aa",x"b8",x"b6",
                                                             x"0c",x"02",x"10",x"1e",x"34",x"3a",x"28",x"26",x"7c",x"72",x"60",x"6e",x"44",x"4a",x"58",x"56", 
                                                             x"37",x"39",x"2b",x"25",x"0f",x"01",x"13",x"1d",x"47",x"49",x"5b",x"55",x"7f",x"71",x"63",x"6d",
                                                             x"d7",x"d9",x"cb",x"c5",x"ef",x"e1",x"f3",x"fd",x"a7",x"a9",x"bb",x"b5",x"9f",x"91",x"83",x"8d");                                             
                           
   -- G function Rj constants                                                      
   constant ROUND_CONSTS              : T_RND_CONST     :=  (x"00000001",x"00000002",x"00000004",x"00000008",x"00000010",x"00000020",x"00000040",x"00000080",x"0000001B",x"00000036",x"0000006C", x"000000D8", x"000000AB", x"0000004D");
   
end package aes_engine_pkg; 

package body aes_engine_pkg is                                            
                                                                
  -- Galois Multiplier (GF(2^128) poly = x^128 + x^7 + x^2 + x + 1
  function mult(v1, v2 : in std_logic_vector) return std_logic_vector is
     constant m              : integer := 128;  
     variable dummy          : std_logic;
     variable v_temp         : std_logic_vector(m-1 downto 0);
     variable ret            : std_logic_vector(m-1 downto 0);
  begin
     -- x^128 + x^7 + x^2 + x + 1
     v_temp   := (others=>'0');                                                                                  
     for i in 0 to m-1 loop                                                                                                                                                                                
        dummy        := v_temp(127);
        gen_gf : for a in 127 downto 8 loop                                                                         
           v_temp(a ) := v_temp(a-1);                                                                                
        end loop;
        v_temp(7 )   := v_temp(6  ) xor dummy;                                                                         
        v_temp(6 )   := v_temp(5  );                                                                                   
        v_temp(5 )   := v_temp(4  );                                                                                   
        v_temp(4 )   := v_temp(3  );                                                                                   
        v_temp(3 )   := v_temp(2  );                                                                                   
        v_temp(2 )   := v_temp(1  ) xor dummy;                                                                         
        v_temp(1 )   := v_temp(0  ) xor dummy;                                                                         
        v_temp(0 )   := dummy;    
                                                                                            
        for j in 0 to m-1 loop                                                                                                                                                                                                                                                                                    
           v_temp(j) := v_temp(j) xor (v1(j) and v2(m-i-1));                  
        end loop;                                                             
     end loop;                                                                
  
     ret := v_temp;
     return ret;
  end mult;      
  
   function reverse_byte_order(a : std_logic_vector) return std_logic_vector is
      variable in_word : std_logic_vector(a'length-1 downto 0);
   begin
         for i in 0 to (a'length/BYTE_WIDTH)-1 loop
            in_word((i + 1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH) := a(((a'length/BYTE_WIDTH)-i)*BYTE_WIDTH-1 downto ((a'length/BYTE_WIDTH-1)-i)*BYTE_WIDTH);
         end loop;
      return in_word;
   end function;
  
                                                            
end package body aes_engine_pkg;