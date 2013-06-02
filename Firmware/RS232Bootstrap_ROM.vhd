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
     0 => x"a08085d1",
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
    20 => x"85f47383",
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
    87 => x"a08085cc",
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
   107 => x"8085cc04",
   108 => x"718324ab",
   109 => x"3883ffe0",
   110 => x"a8087481",
   111 => x"df06c905",
   112 => x"52527080",
   113 => x"258438a7",
   114 => x"11517184",
   115 => x"2b710783",
   116 => x"ffe0a80c",
   117 => x"80e20bff",
   118 => x"840ca080",
   119 => x"85cc0483",
   120 => x"ffe09c08",
   121 => x"83055171",
   122 => x"7124b238",
   123 => x"83ffe094",
   124 => x"087481df",
   125 => x"06c90552",
   126 => x"52708025",
   127 => x"8438a711",
   128 => x"5171842b",
   129 => x"710783ff",
   130 => x"e0940c81",
   131 => x"0b83ffe0",
   132 => x"980c80e1",
   133 => x"0bff840c",
   134 => x"a08085cc",
   135 => x"0483ffe0",
   136 => x"9008ff11",
   137 => x"52537082",
   138 => x"26819138",
   139 => x"83ffe0a8",
   140 => x"08108105",
   141 => x"83ffe094",
   142 => x"08545171",
   143 => x"712480d8",
   144 => x"3872a080",
   145 => x"80b42d74",
   146 => x"81df06c9",
   147 => x"05525270",
   148 => x"80258438",
   149 => x"a7115171",
   150 => x"842b7107",
   151 => x"527173a0",
   152 => x"8080c92d",
   153 => x"83ffe098",
   154 => x"08ff0583",
   155 => x"ffe0980c",
   156 => x"83ffe098",
   157 => x"08802580",
   158 => x"d33883ff",
   159 => x"e0940881",
   160 => x"0583ffe0",
   161 => x"940c810b",
   162 => x"83ffe098",
   163 => x"0c80f70b",
   164 => x"ff840ca0",
   165 => x"8085cc04",
   166 => x"83ffe098",
   167 => x"08933872",
   168 => x"a08080b4",
   169 => x"2d70842b",
   170 => x"52527073",
   171 => x"a08080c9",
   172 => x"2d80e60b",
   173 => x"ff840ca0",
   174 => x"8085cc04",
   175 => x"8673258c",
   176 => x"3880c20b",
   177 => x"ff840ca0",
   178 => x"8080882d",
   179 => x"0290050d",
   180 => x"0402fc05",
   181 => x"0d88bd0b",
   182 => x"ff880ca0",
   183 => x"8081d92d",
   184 => x"83ffe080",
   185 => x"0881ff06",
   186 => x"51a08082",
   187 => x"9e2da080",
   188 => x"85db0400",
   189 => x"00ffffff",
   190 => x"ff00ffff",
   191 => x"ffff00ff",
   192 => x"ffffff00",
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

