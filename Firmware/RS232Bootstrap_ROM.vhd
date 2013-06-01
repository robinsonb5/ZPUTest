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
     0 => x"a08085a4",
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
    20 => x"85d07383",
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
    54 => x"0402fc05",
    55 => x"0dff8408",
    56 => x"70892a70",
    57 => x"81065151",
    58 => x"5170802e",
    59 => x"f038ff84",
    60 => x"087081ff",
    61 => x"0683ffe0",
    62 => x"800c5102",
    63 => x"84050d04",
    64 => x"02f8050d",
    65 => x"028f05a0",
    66 => x"8080b42d",
    67 => x"52ff8408",
    68 => x"70882a70",
    69 => x"81065151",
    70 => x"5170802e",
    71 => x"f03871ff",
    72 => x"840c0288",
    73 => x"050d0402",
    74 => x"d0050d02",
    75 => x"b405a080",
    76 => x"82807170",
    77 => x"84055308",
    78 => x"5c5c5880",
    79 => x"7a708105",
    80 => x"5ca08080",
    81 => x"b42d5459",
    82 => x"72792e82",
    83 => x"cc3872a5",
    84 => x"2e098106",
    85 => x"82ab3879",
    86 => x"7081055b",
    87 => x"a08080b4",
    88 => x"2d537280",
    89 => x"e42e9f38",
    90 => x"7280e424",
    91 => x"8d387280",
    92 => x"e32e81c4",
    93 => x"38a08084",
    94 => x"ca047280",
    95 => x"f32e818d",
    96 => x"38a08084",
    97 => x"ca047784",
    98 => x"19710883",
    99 => x"ffe0e00b",
   100 => x"83ffe090",
   101 => x"595a5659",
   102 => x"53805673",
   103 => x"762e0981",
   104 => x"069538b0",
   105 => x"0b83ffe0",
   106 => x"900ba080",
   107 => x"80c92d81",
   108 => x"1555a080",
   109 => x"83df0473",
   110 => x"8f06a080",
   111 => x"85e00553",
   112 => x"72a08080",
   113 => x"b42d7570",
   114 => x"810557a0",
   115 => x"8080c92d",
   116 => x"73842a54",
   117 => x"73e13874",
   118 => x"83ffe090",
   119 => x"2e9c38ff",
   120 => x"155574a0",
   121 => x"8080b42d",
   122 => x"77708105",
   123 => x"59a08080",
   124 => x"c92d8116",
   125 => x"56a08083",
   126 => x"d7048077",
   127 => x"a08080c9",
   128 => x"2d7583ff",
   129 => x"e0e05654",
   130 => x"a08084de",
   131 => x"04778419",
   132 => x"71085759",
   133 => x"538075a0",
   134 => x"8080b42d",
   135 => x"54547274",
   136 => x"2ebc3881",
   137 => x"14701670",
   138 => x"a08080b4",
   139 => x"2d515454",
   140 => x"72f138a0",
   141 => x"8084de04",
   142 => x"77841983",
   143 => x"12a08080",
   144 => x"b42d5259",
   145 => x"53a08085",
   146 => x"81048052",
   147 => x"a5517a2d",
   148 => x"80527251",
   149 => x"7a2d8219",
   150 => x"59a08085",
   151 => x"8a0473ff",
   152 => x"15555380",
   153 => x"7325a338",
   154 => x"74708105",
   155 => x"56a08080",
   156 => x"b42d5380",
   157 => x"5272517a",
   158 => x"2d811959",
   159 => x"a08084de",
   160 => x"04805272",
   161 => x"517a2d81",
   162 => x"19597970",
   163 => x"81055ba0",
   164 => x"8080b42d",
   165 => x"5372fdb6",
   166 => x"387883ff",
   167 => x"e0800c02",
   168 => x"b0050d04",
   169 => x"02fc050d",
   170 => x"88bd0bff",
   171 => x"880ca080",
   172 => x"85f451a0",
   173 => x"80819b2d",
   174 => x"a08081d9",
   175 => x"2d83ffe0",
   176 => x"800881ff",
   177 => x"0651a080",
   178 => x"80f42da0",
   179 => x"8085b804",
   180 => x"00ffffff",
   181 => x"ff00ffff",
   182 => x"ffff00ff",
   183 => x"ffffff00",
   184 => x"30313233",
   185 => x"34353637",
   186 => x"38394142",
   187 => x"43444546",
   188 => x"00000000",
   189 => x"48656c6c",
   190 => x"6f2c2077",
   191 => x"6f726c64",
   192 => x"0a000000",
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

