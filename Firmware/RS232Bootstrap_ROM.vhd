-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- 
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.zpu_config.all;
use work.zpupkg.all;

entity RS232Bootstrap_ROM is
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end RS232Bootstrap_ROM;

architecture arch of RS232Bootstrap_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"a08085c0",
     1 => x"04000000",
     2 => x"800b810b",
     3 => x"ff8c0c04",
     4 => x"0b0b0ba0",
     5 => x"80809d0b",
     6 => x"810bff8c",
     7 => x"0c700471",
     8 => x"fd060872",
     9 => x"83060981",
    10 => x"05820583",
    11 => x"2b2a83ff",
    12 => x"ff065204",
    13 => x"71fc0608",
    14 => x"72830609",
    15 => x"81058305",
    16 => x"1010102a",
    17 => x"81ff0652",
    18 => x"0471fc06",
    19 => x"080ba080",
    20 => x"85e47383",
    21 => x"06101005",
    22 => x"08067381",
    23 => x"ff067383",
    24 => x"06098105",
    25 => x"83051010",
    26 => x"102b0772",
    27 => x"fc060c51",
    28 => x"51040000",
    29 => x"02f8050d",
    30 => x"028f05a0",
    31 => x"8080b42d",
    32 => x"52ff8408",
    33 => x"70882a70",
    34 => x"81065151",
    35 => x"5170802e",
    36 => x"f03871ff",
    37 => x"840c0288",
    38 => x"050d0402",
    39 => x"f4050d74",
    40 => x"5372a080",
    41 => x"80b42d70",
    42 => x"81ff0652",
    43 => x"5270802e",
    44 => x"a3387181",
    45 => x"ff068114",
    46 => x"5452ff84",
    47 => x"0870882a",
    48 => x"70810651",
    49 => x"51517080",
    50 => x"2ef03871",
    51 => x"ff840ca0",
    52 => x"8081a104",
    53 => x"028c050d",
    54 => x"0402f805",
    55 => x"0dff8408",
    56 => x"70892a70",
    57 => x"81065152",
    58 => x"5270802e",
    59 => x"f0387181",
    60 => x"ff0683ff",
    61 => x"e0800c02",
    62 => x"88050d04",
    63 => x"02fc050d",
    64 => x"7381df06",
    65 => x"c9055170",
    66 => x"80258438",
    67 => x"a7115172",
    68 => x"842b7107",
    69 => x"83ffe080",
    70 => x"0c028405",
    71 => x"0d0402f0",
    72 => x"050d0297",
    73 => x"05a08080",
    74 => x"b42d83ff",
    75 => x"e0a40881",
    76 => x"0583ffe0",
    77 => x"a40c5473",
    78 => x"80d32e09",
    79 => x"8106a238",
    80 => x"800b83ff",
    81 => x"e0a40c80",
    82 => x"0b83ffe0",
    83 => x"940c800b",
    84 => x"83ffe0a8",
    85 => x"0c800b83",
    86 => x"ffe0900c",
    87 => x"a08085bb",
    88 => x"0483ffe0",
    89 => x"a4085271",
    90 => x"812e0981",
    91 => x"0680c138",
    92 => x"83ffe090",
    93 => x"087481df",
    94 => x"06c90552",
    95 => x"52708025",
    96 => x"8438a711",
    97 => x"5171842b",
    98 => x"71077083",
    99 => x"ffe0900c",
   100 => x"70525283",
   101 => x"72258538",
   102 => x"8a723151",
   103 => x"70108205",
   104 => x"83ffe09c",
   105 => x"0c80f40b",
   106 => x"ff840ca0",
   107 => x"8085bb04",
   108 => x"718324a5",
   109 => x"3883ffe0",
   110 => x"a8087481",
   111 => x"df06c905",
   112 => x"52527080",
   113 => x"258438a7",
   114 => x"11517184",
   115 => x"2b710783",
   116 => x"ffe0a80c",
   117 => x"a08085bb",
   118 => x"0483ffe0",
   119 => x"9c088305",
   120 => x"51717124",
   121 => x"a53883ff",
   122 => x"e0940874",
   123 => x"81df06c9",
   124 => x"05525270",
   125 => x"80258438",
   126 => x"a7115171",
   127 => x"842b7107",
   128 => x"83ffe094",
   129 => x"0ca08084",
   130 => x"f80483ff",
   131 => x"e09008ff",
   132 => x"11525370",
   133 => x"82268193",
   134 => x"3883ffe0",
   135 => x"a8081081",
   136 => x"05517171",
   137 => x"2480dd38",
   138 => x"83ffe0a0",
   139 => x"087481df",
   140 => x"06c90552",
   141 => x"52708025",
   142 => x"8438a711",
   143 => x"5171842b",
   144 => x"71077083",
   145 => x"ffe0a00c",
   146 => x"83ffe098",
   147 => x"08ff0583",
   148 => x"ffe0980c",
   149 => x"5283ffe0",
   150 => x"98088025",
   151 => x"80dd3883",
   152 => x"ffe09408",
   153 => x"517171a0",
   154 => x"8080c92d",
   155 => x"83ffe094",
   156 => x"08810583",
   157 => x"ffe0940c",
   158 => x"810b83ff",
   159 => x"e0980ca0",
   160 => x"8085bb04",
   161 => x"83ffe098",
   162 => x"08b13883",
   163 => x"ffe0a008",
   164 => x"842b7083",
   165 => x"ffe0a00c",
   166 => x"83ffe094",
   167 => x"08525271",
   168 => x"71a08080",
   169 => x"c92da080",
   170 => x"85bb0486",
   171 => x"73258c38",
   172 => x"80c20bff",
   173 => x"840ca080",
   174 => x"80882d02",
   175 => x"90050d04",
   176 => x"02fc050d",
   177 => x"88bd0bff",
   178 => x"880ca080",
   179 => x"81d92d83",
   180 => x"ffe08008",
   181 => x"81ff0651",
   182 => x"a080829e",
   183 => x"2da08085",
   184 => x"ca040000",
   185 => x"00ffffff",
   186 => x"ff00ffff",
   187 => x"ffff00ff",
   188 => x"ffffff00",
	others => x"00000000"
);

begin

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memAWriteEnable = '1') and (from_zpu.memBWriteEnable = '1') and (from_zpu.memAAddr=from_zpu.memBAddr) and (from_zpu.memAWrite/=from_zpu.memBWrite) then
			report "write collision" severity failure;
		end if;
	
		if (from_zpu.memAWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memAAddr))) := from_zpu.memAWrite;
			to_zpu.memARead <= from_zpu.memAWrite;
		else
			to_zpu.memARead <= ram(to_integer(unsigned(from_zpu.memAAddr)));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memBWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memBAddr))) := from_zpu.memBWrite;
			to_zpu.memBRead <= from_zpu.memBWrite;
		else
			to_zpu.memBRead <= ram(to_integer(unsigned(from_zpu.memBAddr)));
		end if;
	end if;
end process;


end arch;

