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
    20 => x"86a07383",
    21 => x"06101005",
    22 => x"08067381",
    23 => x"ff067383",
    24 => x"06098105",
    25 => x"83051010",
    26 => x"102b0772",
    27 => x"fc060c51",
    28 => x"51040ba0",
    29 => x"8080fd0b",
    30 => x"a08085cf",
    31 => x"040ba080",
    32 => x"80fd0402",
    33 => x"f8050d02",
    34 => x"8f05a080",
    35 => x"80b42d52",
    36 => x"ff840870",
    37 => x"882a7081",
    38 => x"06515151",
    39 => x"70802ef0",
    40 => x"3871ff84",
    41 => x"0c028805",
    42 => x"0d0402f4",
    43 => x"050d7453",
    44 => x"72a08080",
    45 => x"b42d7081",
    46 => x"ff065252",
    47 => x"70802ea3",
    48 => x"387181ff",
    49 => x"06811454",
    50 => x"52ff8408",
    51 => x"70882a70",
    52 => x"81065151",
    53 => x"5170802e",
    54 => x"f03871ff",
    55 => x"840ca080",
    56 => x"81b00402",
    57 => x"8c050d04",
    58 => x"02f8050d",
    59 => x"ff840870",
    60 => x"892a7081",
    61 => x"06515252",
    62 => x"70802ef0",
    63 => x"387181ff",
    64 => x"0683ffe0",
    65 => x"800c0288",
    66 => x"050d0402",
    67 => x"fc050d73",
    68 => x"81df06c9",
    69 => x"05517080",
    70 => x"258438a7",
    71 => x"11517284",
    72 => x"2b710783",
    73 => x"ffe0800c",
    74 => x"0284050d",
    75 => x"0402f005",
    76 => x"0d029705",
    77 => x"a08080b4",
    78 => x"2d83ffe0",
    79 => x"a4088105",
    80 => x"83ffe0a4",
    81 => x"0c547380",
    82 => x"d32e0981",
    83 => x"06a23880",
    84 => x"0b83ffe0",
    85 => x"a40c800b",
    86 => x"83ffe094",
    87 => x"0c800b83",
    88 => x"ffe0a80c",
    89 => x"800b83ff",
    90 => x"e0900ca0",
    91 => x"8085ca04",
    92 => x"83ffe0a4",
    93 => x"08527181",
    94 => x"2e098106",
    95 => x"80c13883",
    96 => x"ffe09008",
    97 => x"7481df06",
    98 => x"c9055252",
    99 => x"70802584",
   100 => x"38a71151",
   101 => x"71842b71",
   102 => x"077083ff",
   103 => x"e0900c70",
   104 => x"52528372",
   105 => x"2585388a",
   106 => x"72315170",
   107 => x"10820583",
   108 => x"ffe09c0c",
   109 => x"80f40bff",
   110 => x"840ca080",
   111 => x"85ca0471",
   112 => x"8324a538",
   113 => x"83ffe0a8",
   114 => x"087481df",
   115 => x"06c90552",
   116 => x"52708025",
   117 => x"8438a711",
   118 => x"5171842b",
   119 => x"710783ff",
   120 => x"e0a80ca0",
   121 => x"8085ca04",
   122 => x"83ffe09c",
   123 => x"08830551",
   124 => x"717124a5",
   125 => x"3883ffe0",
   126 => x"94087481",
   127 => x"df06c905",
   128 => x"52527080",
   129 => x"258438a7",
   130 => x"11517184",
   131 => x"2b710783",
   132 => x"ffe0940c",
   133 => x"a0808587",
   134 => x"0483ffe0",
   135 => x"9008ff11",
   136 => x"52537082",
   137 => x"26819338",
   138 => x"83ffe0a8",
   139 => x"08108105",
   140 => x"51717124",
   141 => x"80dd3883",
   142 => x"ffe0a008",
   143 => x"7481df06",
   144 => x"c9055252",
   145 => x"70802584",
   146 => x"38a71151",
   147 => x"71842b71",
   148 => x"077083ff",
   149 => x"e0a00c83",
   150 => x"ffe09808",
   151 => x"ff0583ff",
   152 => x"e0980c52",
   153 => x"83ffe098",
   154 => x"08802580",
   155 => x"dd3883ff",
   156 => x"e0940851",
   157 => x"7171a080",
   158 => x"80c92d83",
   159 => x"ffe09408",
   160 => x"810583ff",
   161 => x"e0940c81",
   162 => x"0b83ffe0",
   163 => x"980ca080",
   164 => x"85ca0483",
   165 => x"ffe09808",
   166 => x"b13883ff",
   167 => x"e0a00884",
   168 => x"2b7083ff",
   169 => x"e0a00c83",
   170 => x"ffe09408",
   171 => x"52527171",
   172 => x"a08080c9",
   173 => x"2da08085",
   174 => x"ca048673",
   175 => x"258c3880",
   176 => x"c20bff84",
   177 => x"0ca08080",
   178 => x"882d0290",
   179 => x"050d0402",
   180 => x"fc050d88",
   181 => x"bd0bff88",
   182 => x"0c80d251",
   183 => x"a0808183",
   184 => x"2d80e551",
   185 => x"a0808183",
   186 => x"2d80e151",
   187 => x"a0808183",
   188 => x"2d80e451",
   189 => x"a0808183",
   190 => x"2d80f951",
   191 => x"a0808183",
   192 => x"2d8a51a0",
   193 => x"8081832d",
   194 => x"a08081e8",
   195 => x"2d83ffe0",
   196 => x"800881ff",
   197 => x"0651a080",
   198 => x"82ad2da0",
   199 => x"80868804",
   200 => x"00ffffff",
   201 => x"ff00ffff",
   202 => x"ffff00ff",
   203 => x"ffffff00",
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

