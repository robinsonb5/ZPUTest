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
     0 => x"a08085a0",
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
    20 => x"85cc7383",
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
    63 => x"02f8050d",
    64 => x"028f05a0",
    65 => x"8080b42d",
    66 => x"52ff8408",
    67 => x"70882a70",
    68 => x"81065151",
    69 => x"5170802e",
    70 => x"f03871ff",
    71 => x"840c0288",
    72 => x"050d0402",
    73 => x"d0050d02",
    74 => x"b405a080",
    75 => x"81fc7170",
    76 => x"84055308",
    77 => x"5c5c5880",
    78 => x"7a708105",
    79 => x"5ca08080",
    80 => x"b42d5459",
    81 => x"72792e82",
    82 => x"cc3872a5",
    83 => x"2e098106",
    84 => x"82ab3879",
    85 => x"7081055b",
    86 => x"a08080b4",
    87 => x"2d537280",
    88 => x"e42e9f38",
    89 => x"7280e424",
    90 => x"8d387280",
    91 => x"e32e81c4",
    92 => x"38a08084",
    93 => x"c6047280",
    94 => x"f32e818d",
    95 => x"38a08084",
    96 => x"c6047784",
    97 => x"19710883",
    98 => x"ffe0e00b",
    99 => x"83ffe090",
   100 => x"595a5659",
   101 => x"53805673",
   102 => x"762e0981",
   103 => x"069538b0",
   104 => x"0b83ffe0",
   105 => x"900ba080",
   106 => x"80c92d81",
   107 => x"1555a080",
   108 => x"83db0473",
   109 => x"8f06a080",
   110 => x"85dc0553",
   111 => x"72a08080",
   112 => x"b42d7570",
   113 => x"810557a0",
   114 => x"8080c92d",
   115 => x"73842a54",
   116 => x"73e13874",
   117 => x"83ffe090",
   118 => x"2e9c38ff",
   119 => x"155574a0",
   120 => x"8080b42d",
   121 => x"77708105",
   122 => x"59a08080",
   123 => x"c92d8116",
   124 => x"56a08083",
   125 => x"d3048077",
   126 => x"a08080c9",
   127 => x"2d7583ff",
   128 => x"e0e05654",
   129 => x"a08084da",
   130 => x"04778419",
   131 => x"71085759",
   132 => x"538075a0",
   133 => x"8080b42d",
   134 => x"54547274",
   135 => x"2ebc3881",
   136 => x"14701670",
   137 => x"a08080b4",
   138 => x"2d515454",
   139 => x"72f138a0",
   140 => x"8084da04",
   141 => x"77841983",
   142 => x"12a08080",
   143 => x"b42d5259",
   144 => x"53a08084",
   145 => x"fd048052",
   146 => x"a5517a2d",
   147 => x"80527251",
   148 => x"7a2d8219",
   149 => x"59a08085",
   150 => x"860473ff",
   151 => x"15555380",
   152 => x"7325a338",
   153 => x"74708105",
   154 => x"56a08080",
   155 => x"b42d5380",
   156 => x"5272517a",
   157 => x"2d811959",
   158 => x"a08084da",
   159 => x"04805272",
   160 => x"517a2d81",
   161 => x"19597970",
   162 => x"81055ba0",
   163 => x"8080b42d",
   164 => x"5372fdb6",
   165 => x"387883ff",
   166 => x"e0800c02",
   167 => x"b0050d04",
   168 => x"02fc050d",
   169 => x"88bd0bff",
   170 => x"880ca080",
   171 => x"85f051a0",
   172 => x"80819b2d",
   173 => x"a08081d9",
   174 => x"2d83ffe0",
   175 => x"800881ff",
   176 => x"0651a080",
   177 => x"80f42da0",
   178 => x"8085b404",
   179 => x"00ffffff",
   180 => x"ff00ffff",
   181 => x"ffff00ff",
   182 => x"ffffff00",
   183 => x"30313233",
   184 => x"34353637",
   185 => x"38394142",
   186 => x"43444546",
   187 => x"00000000",
   188 => x"48656c6c",
   189 => x"6f2c2077",
   190 => x"6f726c64",
   191 => x"0a000000",
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

