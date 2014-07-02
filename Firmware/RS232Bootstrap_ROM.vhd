-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- Modified by Alastair M. Robinson for the ZPUFlex project.
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
generic
	(
		maxAddrBit : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end RS232Bootstrap_ROM;

architecture arch of RS232Bootstrap_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBit+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"0ba08080",
     1 => x"f2040000",
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
    20 => x"86dc7383",
    21 => x"06101005",
    22 => x"08067381",
    23 => x"ff067383",
    24 => x"06098105",
    25 => x"83051010",
    26 => x"102b0772",
    27 => x"fc060c51",
    28 => x"51040ba0",
    29 => x"8080fd0b",
    30 => x"a0808688",
    31 => x"040ba080",
    32 => x"80fd0402",
    33 => x"f8050d73",
    34 => x"52ff8408",
    35 => x"70882a70",
    36 => x"81065151",
    37 => x"5170802e",
    38 => x"f03871ff",
    39 => x"840c7183",
    40 => x"ffe0800c",
    41 => x"0288050d",
    42 => x"0402f005",
    43 => x"0d755380",
    44 => x"73a08080",
    45 => x"b42d7081",
    46 => x"ff065353",
    47 => x"5470742e",
    48 => x"b0387181",
    49 => x"ff068114",
    50 => x"5452ff84",
    51 => x"0870882a",
    52 => x"70810651",
    53 => x"51517080",
    54 => x"2ef03871",
    55 => x"ff840c81",
    56 => x"1473a080",
    57 => x"80b42d70",
    58 => x"81ff0653",
    59 => x"535470d2",
    60 => x"387383ff",
    61 => x"e0800c02",
    62 => x"90050d04",
    63 => x"02f8050d",
    64 => x"ff840870",
    65 => x"892a7081",
    66 => x"06515252",
    67 => x"70802ef0",
    68 => x"387181ff",
    69 => x"0683ffe0",
    70 => x"800c0288",
    71 => x"050d0402",
    72 => x"f4050d74",
    73 => x"c0085451",
    74 => x"70802e93",
    75 => x"38c00852",
    76 => x"71732ef9",
    77 => x"3871ff12",
    78 => x"5253a080",
    79 => x"82a80402",
    80 => x"8c050d04",
    81 => x"02fc050d",
    82 => x"7381df06",
    83 => x"c9055170",
    84 => x"80258438",
    85 => x"a7115172",
    86 => x"842b7107",
    87 => x"83ffe080",
    88 => x"0c028405",
    89 => x"0d0402f0",
    90 => x"050d0297",
    91 => x"05a08080",
    92 => x"b42d83ff",
    93 => x"e0a40881",
    94 => x"0583ffe0",
    95 => x"a40c5473",
    96 => x"80d32e09",
    97 => x"8106a238",
    98 => x"800b83ff",
    99 => x"e0a40c80",
   100 => x"0b83ffe0",
   101 => x"940c800b",
   102 => x"83ffe0a8",
   103 => x"0c800b83",
   104 => x"ffe0900c",
   105 => x"a0808683",
   106 => x"0483ffe0",
   107 => x"a4085271",
   108 => x"812e0981",
   109 => x"0680c138",
   110 => x"83ffe090",
   111 => x"087481df",
   112 => x"06c90552",
   113 => x"52708025",
   114 => x"8438a711",
   115 => x"5171842b",
   116 => x"71077083",
   117 => x"ffe0900c",
   118 => x"70525283",
   119 => x"72258538",
   120 => x"8a723151",
   121 => x"70108205",
   122 => x"83ffe09c",
   123 => x"0c80f40b",
   124 => x"ff840ca0",
   125 => x"80868304",
   126 => x"718324a5",
   127 => x"3883ffe0",
   128 => x"a8087481",
   129 => x"df06c905",
   130 => x"52527080",
   131 => x"258438a7",
   132 => x"11517184",
   133 => x"2b710783",
   134 => x"ffe0a80c",
   135 => x"a0808683",
   136 => x"0483ffe0",
   137 => x"9c088305",
   138 => x"51717124",
   139 => x"a53883ff",
   140 => x"e0940874",
   141 => x"81df06c9",
   142 => x"05525270",
   143 => x"80258438",
   144 => x"a7115171",
   145 => x"842b7107",
   146 => x"83ffe094",
   147 => x"0ca08085",
   148 => x"c00483ff",
   149 => x"e09008ff",
   150 => x"11525370",
   151 => x"82268193",
   152 => x"3883ffe0",
   153 => x"a8081081",
   154 => x"05517171",
   155 => x"2480dd38",
   156 => x"83ffe0a0",
   157 => x"087481df",
   158 => x"06c90552",
   159 => x"52708025",
   160 => x"8438a711",
   161 => x"5171842b",
   162 => x"71077083",
   163 => x"ffe0a00c",
   164 => x"83ffe098",
   165 => x"08ff0583",
   166 => x"ffe0980c",
   167 => x"5283ffe0",
   168 => x"98088025",
   169 => x"80dd3883",
   170 => x"ffe09408",
   171 => x"517171a0",
   172 => x"8080c92d",
   173 => x"83ffe094",
   174 => x"08810583",
   175 => x"ffe0940c",
   176 => x"810b83ff",
   177 => x"e0980ca0",
   178 => x"80868304",
   179 => x"83ffe098",
   180 => x"08b13883",
   181 => x"ffe0a008",
   182 => x"842b7083",
   183 => x"ffe0a00c",
   184 => x"83ffe094",
   185 => x"08525271",
   186 => x"71a08080",
   187 => x"c92da080",
   188 => x"86830486",
   189 => x"73258c38",
   190 => x"80c20bff",
   191 => x"840ca080",
   192 => x"80882d02",
   193 => x"90050d04",
   194 => x"02fc050d",
   195 => x"88bd0bff",
   196 => x"880c80d2",
   197 => x"51a08081",
   198 => x"832d80e5",
   199 => x"51a08081",
   200 => x"832d80e1",
   201 => x"51a08081",
   202 => x"832d80e4",
   203 => x"51a08081",
   204 => x"832d80f9",
   205 => x"51a08081",
   206 => x"832d8a51",
   207 => x"a0808183",
   208 => x"2da08081",
   209 => x"fc2d83ff",
   210 => x"e0800881",
   211 => x"ff0651a0",
   212 => x"8082e62d",
   213 => x"a08086c1",
   214 => x"04000000",
   215 => x"00ffffff",
   216 => x"ff00ffff",
   217 => x"ffff00ff",
   218 => x"ffffff00",
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
			ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBit downto 2)))) := from_zpu.memAWrite;
			to_zpu.memARead <= from_zpu.memAWrite;
		else
			to_zpu.memARead <= ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBit downto 2))));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memBWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBit downto 2)))) := from_zpu.memBWrite;
			to_zpu.memBRead <= from_zpu.memBWrite;
		else
			to_zpu.memBRead <= ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBit downto 2))));
		end if;
	end if;
end process;


end arch;

