	others => x"00000000"
);

begin

mem_busy<=mem_readEnable; -- we're done on the cycle after we serve the read request

process (clk, areset)
begin
		if areset = '1' then
		elsif (clk'event and clk = '1') then
			if (mem_writeEnable = '1') then
				ram(to_integer(unsigned(mem_addr(maxAddrBit downto minAddrBit)))) := mem_write;
			end if;
		if (mem_readEnable = '1') then
			mem_read <= ram(to_integer(unsigned(mem_addr(maxAddrBit downto minAddrBit))));
		end if;
	end if;
end process;




end arch;

	others => x"00000000"
);

begin

mem_busy<=mem_readEnable; -- we're done on the cycle after we serve the read request

process (clk, areset)
begin
		if areset = '1' then
		elsif (clk'event and clk = '1') then
			if (mem_writeEnable = '1') then
				ram(to_integer(unsigned(mem_addr(maxAddrBit downto minAddrBit)))) := mem_write;
			end if;
		if (mem_readEnable = '1') then
			mem_read <= ram(to_integer(unsigned(mem_addr(maxAddrBit downto minAddrBit))));
		end if;
	end if;
end process;




end arch;

