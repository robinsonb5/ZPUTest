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

entity SDBootstrap_ROM is
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end SDBootstrap_ROM;

architecture arch of SDBootstrap_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"a08087fe",
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
    20 => x"97907383",
    21 => x"06101005",
    22 => x"08067381",
    23 => x"ff067383",
    24 => x"06098105",
    25 => x"83051010",
    26 => x"102b0772",
    27 => x"fc060c51",
    28 => x"51040000",
    29 => x"02f4050d",
    30 => x"74767181",
    31 => x"ff06c80c",
    32 => x"535383ff",
    33 => x"f09c0885",
    34 => x"3871892b",
    35 => x"5271982a",
    36 => x"c80c7190",
    37 => x"2a7081ff",
    38 => x"06c80c51",
    39 => x"71882a70",
    40 => x"81ff06c8",
    41 => x"0c517181",
    42 => x"ff06c80c",
    43 => x"72902a70",
    44 => x"81ff06c8",
    45 => x"0c51c808",
    46 => x"7081ff06",
    47 => x"515182b8",
    48 => x"bf527081",
    49 => x"ff2e0981",
    50 => x"06943881",
    51 => x"ff0bc80c",
    52 => x"c8087081",
    53 => x"ff06ff14",
    54 => x"54515171",
    55 => x"e5387083",
    56 => x"ffe0800c",
    57 => x"028c050d",
    58 => x"0402fc05",
    59 => x"0d81c751",
    60 => x"81ff0bc8",
    61 => x"0cff1151",
    62 => x"708025f4",
    63 => x"38028405",
    64 => x"0d0402f0",
    65 => x"050da080",
    66 => x"81e92d81",
    67 => x"9c9f5380",
    68 => x"5287fc80",
    69 => x"f751a080",
    70 => x"80f42d83",
    71 => x"ffe08008",
    72 => x"5483ffe0",
    73 => x"8008812e",
    74 => x"098106ab",
    75 => x"3881ff0b",
    76 => x"c80c820a",
    77 => x"52849c80",
    78 => x"e951a080",
    79 => x"80f42d83",
    80 => x"ffe08008",
    81 => x"8d3881ff",
    82 => x"0bc80c73",
    83 => x"53a08082",
    84 => x"de04a080",
    85 => x"81e92dff",
    86 => x"135372ff",
    87 => x"b2387283",
    88 => x"ffe0800c",
    89 => x"0290050d",
    90 => x"0402f405",
    91 => x"0d81ff0b",
    92 => x"c80c9353",
    93 => x"805287fc",
    94 => x"80c151a0",
    95 => x"8080f42d",
    96 => x"83ffe080",
    97 => x"088d3881",
    98 => x"ff0bc80c",
    99 => x"8153a080",
   100 => x"839e04a0",
   101 => x"8081e92d",
   102 => x"ff135372",
   103 => x"d7387283",
   104 => x"ffe0800c",
   105 => x"028c050d",
   106 => x"0402f005",
   107 => x"0da08081",
   108 => x"e92d83aa",
   109 => x"52849c80",
   110 => x"c851a080",
   111 => x"80f42d83",
   112 => x"ffe08008",
   113 => x"812e0981",
   114 => x"069038cc",
   115 => x"087083ff",
   116 => x"ff065153",
   117 => x"7283aa2e",
   118 => x"9938a080",
   119 => x"82e92da0",
   120 => x"8083eb04",
   121 => x"8154a080",
   122 => x"84cc0480",
   123 => x"54a08084",
   124 => x"cc0481ff",
   125 => x"0bc80cb1",
   126 => x"53a08082",
   127 => x"822d83ff",
   128 => x"e0800880",
   129 => x"2eb73880",
   130 => x"5287fc80",
   131 => x"fa51a080",
   132 => x"80f42d83",
   133 => x"ffe08008",
   134 => x"a43881ff",
   135 => x"0bc80cc8",
   136 => x"08cc0871",
   137 => x"862a7081",
   138 => x"0683ffe0",
   139 => x"80085351",
   140 => x"52555372",
   141 => x"802e9538",
   142 => x"a08083e4",
   143 => x"0472822e",
   144 => x"ffa938ff",
   145 => x"135372ff",
   146 => x"b0387254",
   147 => x"7383ffe0",
   148 => x"800c0290",
   149 => x"050d0402",
   150 => x"f4050d81",
   151 => x"0b83fff0",
   152 => x"9c0cc408",
   153 => x"708f2a70",
   154 => x"81065151",
   155 => x"5372f338",
   156 => x"72c40ca0",
   157 => x"8081e92d",
   158 => x"c408708f",
   159 => x"2a708106",
   160 => x"51515372",
   161 => x"f338810b",
   162 => x"c40c8753",
   163 => x"805284d4",
   164 => x"80c051a0",
   165 => x"8080f42d",
   166 => x"83ffe080",
   167 => x"08812e96",
   168 => x"3872822e",
   169 => x"09810688",
   170 => x"388053a0",
   171 => x"8085ee04",
   172 => x"ff135372",
   173 => x"d738a080",
   174 => x"83a92d83",
   175 => x"ffe08008",
   176 => x"83fff09c",
   177 => x"0c815287",
   178 => x"fc80d051",
   179 => x"a08080f4",
   180 => x"2d81ff0b",
   181 => x"c80cc408",
   182 => x"708f2a70",
   183 => x"81065151",
   184 => x"5372f338",
   185 => x"72c40c81",
   186 => x"ff0bc80c",
   187 => x"81537283",
   188 => x"ffe0800c",
   189 => x"028c050d",
   190 => x"04800b83",
   191 => x"ffe0800c",
   192 => x"0402e805",
   193 => x"0d785580",
   194 => x"56c40870",
   195 => x"8f2a7081",
   196 => x"06515153",
   197 => x"72f33882",
   198 => x"810bc40c",
   199 => x"81ff0bc8",
   200 => x"0c775287",
   201 => x"fc80d151",
   202 => x"a08080f4",
   203 => x"2d83ffe0",
   204 => x"800880d2",
   205 => x"3880dbc6",
   206 => x"df5481ff",
   207 => x"0bc80cc8",
   208 => x"087081ff",
   209 => x"06515372",
   210 => x"81fe2e09",
   211 => x"81069b38",
   212 => x"80ff54cc",
   213 => x"08757084",
   214 => x"05570cff",
   215 => x"14547380",
   216 => x"25f13881",
   217 => x"56a08086",
   218 => x"f004ff14",
   219 => x"5473cb38",
   220 => x"81ff0bc8",
   221 => x"0cc40870",
   222 => x"8f2a7081",
   223 => x"06515153",
   224 => x"72f33872",
   225 => x"c40c7583",
   226 => x"ffe0800c",
   227 => x"0298050d",
   228 => x"0402f405",
   229 => x"0d747088",
   230 => x"2a83fe80",
   231 => x"06707298",
   232 => x"2a077288",
   233 => x"2b87fc80",
   234 => x"80067398",
   235 => x"2b81f00a",
   236 => x"06717307",
   237 => x"0783ffe0",
   238 => x"800c5651",
   239 => x"5351028c",
   240 => x"050d0402",
   241 => x"f4050d02",
   242 => x"9205a080",
   243 => x"809f2d70",
   244 => x"882a7188",
   245 => x"2b077083",
   246 => x"ffff0683",
   247 => x"ffe0800c",
   248 => x"5252028c",
   249 => x"050d0402",
   250 => x"f8050d73",
   251 => x"70902b71",
   252 => x"902a0783",
   253 => x"ffe0800c",
   254 => x"52028805",
   255 => x"0d0402ec",
   256 => x"050d88bd",
   257 => x"0bff880c",
   258 => x"800b870a",
   259 => x"0cf80883",
   260 => x"fff0900c",
   261 => x"fc0883ff",
   262 => x"f0940c84",
   263 => x"eacda880",
   264 => x"0b83fff0",
   265 => x"980ca080",
   266 => x"84d72d83",
   267 => x"ffe08008",
   268 => x"802e81d1",
   269 => x"38a0808a",
   270 => x"d92d83ff",
   271 => x"e0905283",
   272 => x"fff09051",
   273 => x"a08095de",
   274 => x"2d83ffe0",
   275 => x"8008802e",
   276 => x"81b33883",
   277 => x"ffe09054",
   278 => x"80557370",
   279 => x"810555a0",
   280 => x"8080b42d",
   281 => x"5372a02e",
   282 => x"80de3872",
   283 => x"a32e80fd",
   284 => x"387280c7",
   285 => x"2e098106",
   286 => x"8b38a080",
   287 => x"80882da0",
   288 => x"8089a404",
   289 => x"728a2e09",
   290 => x"81068b38",
   291 => x"a0808090",
   292 => x"2da08089",
   293 => x"a4047280",
   294 => x"cc2e0981",
   295 => x"06863883",
   296 => x"ffe09054",
   297 => x"7281df06",
   298 => x"f0057081",
   299 => x"ff065153",
   300 => x"b8732789",
   301 => x"38ef1370",
   302 => x"81ff0651",
   303 => x"5374842b",
   304 => x"730755a0",
   305 => x"8088da04",
   306 => x"72a32ea1",
   307 => x"38737081",
   308 => x"0555a080",
   309 => x"80b42d53",
   310 => x"72a02ef1",
   311 => x"38ff1475",
   312 => x"53705254",
   313 => x"a08095de",
   314 => x"2d74870a",
   315 => x"0c737081",
   316 => x"0555a080",
   317 => x"80b42d53",
   318 => x"728a2e09",
   319 => x"8106ee38",
   320 => x"a08088d8",
   321 => x"04800b83",
   322 => x"ffe0800c",
   323 => x"0294050d",
   324 => x"0402e805",
   325 => x"0d77797b",
   326 => x"58555580",
   327 => x"53727625",
   328 => x"ab387470",
   329 => x"810556a0",
   330 => x"8080b42d",
   331 => x"74708105",
   332 => x"56a08080",
   333 => x"b42d5252",
   334 => x"71712e88",
   335 => x"388151a0",
   336 => x"808ace04",
   337 => x"811353a0",
   338 => x"808a9d04",
   339 => x"80517083",
   340 => x"ffe0800c",
   341 => x"0298050d",
   342 => x"0402d805",
   343 => x"0dff0b83",
   344 => x"fff4c80c",
   345 => x"800b83ff",
   346 => x"f4dc0c83",
   347 => x"fff0b452",
   348 => x"8051a080",
   349 => x"86812d83",
   350 => x"ffe08008",
   351 => x"5583ffe0",
   352 => x"8008802e",
   353 => x"86d33880",
   354 => x"56810b83",
   355 => x"fff0a80c",
   356 => x"8853a080",
   357 => x"97a05283",
   358 => x"fff0ea51",
   359 => x"a0808a91",
   360 => x"2d83ffe0",
   361 => x"8008762e",
   362 => x"0981068b",
   363 => x"3883ffe0",
   364 => x"800883ff",
   365 => x"f0a80c88",
   366 => x"53a08097",
   367 => x"ac5283ff",
   368 => x"f18651a0",
   369 => x"808a912d",
   370 => x"83ffe080",
   371 => x"088b3883",
   372 => x"ffe08008",
   373 => x"83fff0a8",
   374 => x"0c83fff0",
   375 => x"a808802e",
   376 => x"819c3883",
   377 => x"fff3fa0b",
   378 => x"a08080b4",
   379 => x"2d83fff3",
   380 => x"fb0ba080",
   381 => x"80b42d71",
   382 => x"982b7190",
   383 => x"2b0783ff",
   384 => x"f3fc0ba0",
   385 => x"8080b42d",
   386 => x"70882b72",
   387 => x"0783fff3",
   388 => x"fd0ba080",
   389 => x"80b42d71",
   390 => x"0783fff4",
   391 => x"b20ba080",
   392 => x"80b42d83",
   393 => x"fff4b30b",
   394 => x"a08080b4",
   395 => x"2d71882b",
   396 => x"07535f54",
   397 => x"525a5657",
   398 => x"557381ab",
   399 => x"aa2e0981",
   400 => x"06933875",
   401 => x"51a08087",
   402 => x"912d83ff",
   403 => x"e0800856",
   404 => x"a0808ce2",
   405 => x"04805573",
   406 => x"82d4d52e",
   407 => x"09810684",
   408 => x"f83883ff",
   409 => x"f0b45275",
   410 => x"51a08086",
   411 => x"812d83ff",
   412 => x"e0800855",
   413 => x"83ffe080",
   414 => x"08802e84",
   415 => x"dc388853",
   416 => x"a08097ac",
   417 => x"5283fff1",
   418 => x"8651a080",
   419 => x"8a912d83",
   420 => x"ffe08008",
   421 => x"8d38810b",
   422 => x"83fff4dc",
   423 => x"0ca0808d",
   424 => x"c2048853",
   425 => x"a08097a0",
   426 => x"5283fff0",
   427 => x"ea51a080",
   428 => x"8a912d80",
   429 => x"5583ffe0",
   430 => x"8008752e",
   431 => x"09810684",
   432 => x"983883ff",
   433 => x"f4b20ba0",
   434 => x"8080b42d",
   435 => x"547380d5",
   436 => x"2e098106",
   437 => x"80db3883",
   438 => x"fff4b30b",
   439 => x"a08080b4",
   440 => x"2d547381",
   441 => x"aa2e0981",
   442 => x"0680c638",
   443 => x"800b83ff",
   444 => x"f0b40ba0",
   445 => x"8080b42d",
   446 => x"56547481",
   447 => x"e92e8338",
   448 => x"81547481",
   449 => x"eb2e8c38",
   450 => x"80557375",
   451 => x"2e098106",
   452 => x"83c73883",
   453 => x"fff0bf0b",
   454 => x"a08080b4",
   455 => x"2d557491",
   456 => x"3883fff0",
   457 => x"c00ba080",
   458 => x"80b42d54",
   459 => x"73822e88",
   460 => x"388055a0",
   461 => x"8091d904",
   462 => x"83fff0c1",
   463 => x"0ba08080",
   464 => x"b42d7083",
   465 => x"fff4e40c",
   466 => x"ff0583ff",
   467 => x"f4d80c83",
   468 => x"fff0c20b",
   469 => x"a08080b4",
   470 => x"2d83fff0",
   471 => x"c30ba080",
   472 => x"80b42d58",
   473 => x"76057782",
   474 => x"80290570",
   475 => x"83fff4cc",
   476 => x"0c83fff0",
   477 => x"c40ba080",
   478 => x"80b42d70",
   479 => x"83fff4c4",
   480 => x"0c83fff4",
   481 => x"dc085957",
   482 => x"5876802e",
   483 => x"81df3888",
   484 => x"53a08097",
   485 => x"ac5283ff",
   486 => x"f18651a0",
   487 => x"808a912d",
   488 => x"83ffe080",
   489 => x"0882b238",
   490 => x"83fff4e4",
   491 => x"0870842b",
   492 => x"83fff4b4",
   493 => x"0c7083ff",
   494 => x"f4e00c83",
   495 => x"fff0d90b",
   496 => x"a08080b4",
   497 => x"2d83fff0",
   498 => x"d80ba080",
   499 => x"80b42d71",
   500 => x"82802905",
   501 => x"83fff0da",
   502 => x"0ba08080",
   503 => x"b42d7084",
   504 => x"80802912",
   505 => x"83fff0db",
   506 => x"0ba08080",
   507 => x"b42d7081",
   508 => x"800a2912",
   509 => x"7083fff0",
   510 => x"ac0c83ff",
   511 => x"f4c40871",
   512 => x"2983fff4",
   513 => x"cc080570",
   514 => x"83fff4ec",
   515 => x"0c83fff0",
   516 => x"e10ba080",
   517 => x"80b42d83",
   518 => x"fff0e00b",
   519 => x"a08080b4",
   520 => x"2d718280",
   521 => x"290583ff",
   522 => x"f0e20ba0",
   523 => x"8080b42d",
   524 => x"70848080",
   525 => x"291283ff",
   526 => x"f0e30ba0",
   527 => x"8080b42d",
   528 => x"70982b81",
   529 => x"f00a0672",
   530 => x"057083ff",
   531 => x"f0b00cfe",
   532 => x"117e2977",
   533 => x"0583fff4",
   534 => x"d40c5259",
   535 => x"5243545e",
   536 => x"51525952",
   537 => x"5d575957",
   538 => x"a08091d7",
   539 => x"0483fff0",
   540 => x"c60ba080",
   541 => x"80b42d83",
   542 => x"fff0c50b",
   543 => x"a08080b4",
   544 => x"2d718280",
   545 => x"29057083",
   546 => x"fff4b40c",
   547 => x"70a02983",
   548 => x"ff057089",
   549 => x"2a7083ff",
   550 => x"f4e00c83",
   551 => x"fff0cb0b",
   552 => x"a08080b4",
   553 => x"2d83fff0",
   554 => x"ca0ba080",
   555 => x"80b42d71",
   556 => x"82802905",
   557 => x"7083fff0",
   558 => x"ac0c7b71",
   559 => x"291e7083",
   560 => x"fff4d40c",
   561 => x"7d83fff0",
   562 => x"b00c7305",
   563 => x"83fff4ec",
   564 => x"0c555e51",
   565 => x"51555581",
   566 => x"557483ff",
   567 => x"e0800c02",
   568 => x"a8050d04",
   569 => x"02ec050d",
   570 => x"7670872c",
   571 => x"7180ff06",
   572 => x"57555383",
   573 => x"fff4dc08",
   574 => x"8a387288",
   575 => x"2c7381ff",
   576 => x"06565473",
   577 => x"83fff4c8",
   578 => x"082ea838",
   579 => x"83fff0b4",
   580 => x"5283fff4",
   581 => x"cc081451",
   582 => x"a0808681",
   583 => x"2d83ffe0",
   584 => x"80085383",
   585 => x"ffe08008",
   586 => x"802e80cb",
   587 => x"387383ff",
   588 => x"f4c80c83",
   589 => x"fff4dc08",
   590 => x"802ea038",
   591 => x"74842983",
   592 => x"fff0b405",
   593 => x"70085253",
   594 => x"a0808791",
   595 => x"2d83ffe0",
   596 => x"8008f00a",
   597 => x"0655a080",
   598 => x"92f50474",
   599 => x"1083fff0",
   600 => x"b40570a0",
   601 => x"80809f2d",
   602 => x"5253a080",
   603 => x"87c32d83",
   604 => x"ffe08008",
   605 => x"55745372",
   606 => x"83ffe080",
   607 => x"0c029405",
   608 => x"0d0402cc",
   609 => x"050d7e60",
   610 => x"5e5b8056",
   611 => x"ff0b83ff",
   612 => x"f4c80c83",
   613 => x"fff0b008",
   614 => x"83fff4d4",
   615 => x"08565a83",
   616 => x"fff4dc08",
   617 => x"762e8e38",
   618 => x"83fff4e4",
   619 => x"08842b58",
   620 => x"a08093bd",
   621 => x"0483fff4",
   622 => x"e008842b",
   623 => x"58805978",
   624 => x"782781c9",
   625 => x"38788f06",
   626 => x"a0175754",
   627 => x"73953883",
   628 => x"fff0b452",
   629 => x"74518115",
   630 => x"55a08086",
   631 => x"812d83ff",
   632 => x"f0b45680",
   633 => x"76a08080",
   634 => x"b42d5557",
   635 => x"73772e83",
   636 => x"38815773",
   637 => x"81e52e81",
   638 => x"8c388170",
   639 => x"7806555c",
   640 => x"73802e81",
   641 => x"80388b16",
   642 => x"a08080b4",
   643 => x"2d980657",
   644 => x"7680f238",
   645 => x"8b537c52",
   646 => x"7551a080",
   647 => x"8a912d83",
   648 => x"ffe08008",
   649 => x"80df389c",
   650 => x"160851a0",
   651 => x"8087912d",
   652 => x"83ffe080",
   653 => x"08841c0c",
   654 => x"9a16a080",
   655 => x"809f2d51",
   656 => x"a08087c3",
   657 => x"2d83ffe0",
   658 => x"800883ff",
   659 => x"e0800855",
   660 => x"5583fff4",
   661 => x"dc08802e",
   662 => x"9e389416",
   663 => x"a080809f",
   664 => x"2d51a080",
   665 => x"87c32d83",
   666 => x"ffe08008",
   667 => x"902b83ff",
   668 => x"f00a0670",
   669 => x"16515473",
   670 => x"881c0c76",
   671 => x"7b0c7b54",
   672 => x"a08095d3",
   673 => x"04811959",
   674 => x"a08093bf",
   675 => x"0483fff4",
   676 => x"dc08802e",
   677 => x"bc387951",
   678 => x"a08091e4",
   679 => x"2d83ffe0",
   680 => x"800883ff",
   681 => x"e0800880",
   682 => x"fffffff8",
   683 => x"06555a73",
   684 => x"80ffffff",
   685 => x"f82e9a38",
   686 => x"83ffe080",
   687 => x"08fe0583",
   688 => x"fff4e408",
   689 => x"2983fff4",
   690 => x"ec080555",
   691 => x"a08093bd",
   692 => x"04805473",
   693 => x"83ffe080",
   694 => x"0c02b405",
   695 => x"0d0402e4",
   696 => x"050d7979",
   697 => x"5383fff4",
   698 => x"b85255a0",
   699 => x"8093822d",
   700 => x"83ffe080",
   701 => x"0881ff06",
   702 => x"70555372",
   703 => x"802e8185",
   704 => x"3883fff4",
   705 => x"bc0883ff",
   706 => x"05892a57",
   707 => x"80705556",
   708 => x"75772580",
   709 => x"ee3883ff",
   710 => x"f4c008fe",
   711 => x"0583fff4",
   712 => x"e4082983",
   713 => x"fff4ec08",
   714 => x"117583ff",
   715 => x"f4d80806",
   716 => x"05765452",
   717 => x"53a08086",
   718 => x"812d83ff",
   719 => x"e0800880",
   720 => x"2eb63881",
   721 => x"147083ff",
   722 => x"f4d80806",
   723 => x"54547296",
   724 => x"3883fff4",
   725 => x"c00851a0",
   726 => x"8091e42d",
   727 => x"83ffe080",
   728 => x"0883fff4",
   729 => x"c00c8480",
   730 => x"15811757",
   731 => x"55767624",
   732 => x"ffa438a0",
   733 => x"80978304",
   734 => x"83ffe080",
   735 => x"0854a080",
   736 => x"97850481",
   737 => x"547383ff",
   738 => x"e0800c02",
   739 => x"9c050d04",
   740 => x"00ffffff",
   741 => x"ff00ffff",
   742 => x"ffff00ff",
   743 => x"ffffff00",
   744 => x"46415431",
   745 => x"36202020",
   746 => x"00000000",
   747 => x"46415433",
   748 => x"32202020",
   749 => x"00000000",
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

