library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpu_config.all;
use work.zpupkg.ALL;

entity ZPUTest is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000; -- Sysclk frequency * 10
		spi_maxspeed : integer := 4	-- lowest acceptable timer DIV7 value
	);
	port (
		clk 			: in std_logic;
		clk2			: in std_logic;
--		clk50			: in std_logic;
		src 			: in std_logic_vector(15 downto 0);
		counter 		: buffer unsigned(15 downto 0);
		reset_in 	: in std_logic;
		keys			: in std_logic_vector(3 downto 0);

		-- VGA
		vga_red 		: out unsigned(7 downto 0);
		vga_green 	: out unsigned(7 downto 0);
		vga_blue 	: out unsigned(7 downto 0);
		vga_hsync 	: out std_logic;
		vga_vsync 	: buffer std_logic;
		vga_window	: out std_logic;

		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector(11 downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic;
		sdr_clkena	: out std_logic;
		
		-- UART
		rs232_rxd	: in std_logic;
		rs232_txd	: out std_logic
	);
end entity;

architecture rtl of ZPUTest is

signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";

-- State machine
type SOCStates is (WAITING,READ1,WRITE1,PAUSE);
signal currentstate : SOCStates;

-- UART signals

signal ser_txdata : std_logic_vector(7 downto 0);
signal ser_txready : std_logic;
signal ser_rxdata : std_logic_vector(7 downto 0);
signal ser_rxrecv : std_logic;
signal ser_txgo : std_logic;
signal ser_rxint : std_logic;
signal ser_clock_divisor : unsigned(15 downto 0);

-- ZPU signals

signal mem_busy           : std_logic;
signal mem_read             : std_logic_vector(wordSize-1 downto 0);
signal mem_write            : std_logic_vector(wordSize-1 downto 0);
signal mem_addr             : std_logic_vector(maxAddrBitIncIO downto 0);
signal mem_writeEnable      : std_logic; 
signal mem_readEnable       : std_logic;
signal mem_writeMask        : std_logic_vector(wordBytes-1 downto 0);
signal zpu_enable               : std_logic;
signal zpu_interrupt            : std_logic;
signal zpu_break                : std_logic;

signal cpu_uds	: std_logic;
signal cpu_lds : std_logic;

-- VGA controller signals

signal vga_addr : std_logic_vector(31 downto 0);
signal vga_data : std_logic_vector(15 downto 0);
signal vga_req : std_logic;
signal vga_fill : std_logic;
signal vga_refresh : std_logic;
signal vga_newframe : std_logic;
signal vga_reservebank : std_logic; -- Keep bank clear for instant access.
signal vga_reserveaddr : std_logic_vector(31 downto 0); -- to SDRAM

-- VGA register block signals

signal vga_reg_addr : std_logic_vector(11 downto 0);
signal vga_reg_dataout : std_logic_vector(15 downto 0);
signal vga_reg_datain : std_logic_vector(15 downto 0);
signal vga_reg_rw : std_logic;
signal vga_reg_req : std_logic;
signal vga_reg_dtack : std_logic;
signal vga_ack : std_logic;
signal vblank_int : std_logic;


-- External RAM signal (actually M4k for now)

signal externram_wren : std_logic;
signal externram_data : std_logic_vector(wordSize-1 downto 0);

-- SDRAM signals

signal sdr_ready : std_logic;

--

begin

sdr_clkena <='1';

-- SDRAM
mysdram : entity work.sdram 
	generic map
	(
		rows => sdram_rows,
		cols => sdram_cols
	)
	port map
	(
	-- Physical connections to the SDRAM
		sdata => sdr_data,
		sdaddr => sdr_addr,
		sd_we	=> sdr_we,
		sd_ras => sdr_ras,
		sd_cas => sdr_cas,
		sd_cs	=> sdr_cs,
		dqm => sdr_dqm,
		ba	=> sdr_ba,

	-- Housekeeping
		sysclk => clk,
		reset => reset_in,  -- Contributes to reset, so have to use reset_in here.
		reset_out => sdr_ready,
		reinit => '0',

		vga_addr => vga_addr,
		vga_data => vga_data,
		vga_fill => vga_fill,
		vga_req => vga_req,
		vga_ack => vga_ack,
		vga_refresh => vga_refresh,
		vga_reservebank => vga_reservebank,
		vga_reserveaddr => vga_reserveaddr,

		vga_newframe => vga_newframe,

		datawr1 => (others => 'X'),
		Addr1 => (others => 'X'),
		req1 => '0',
		wr1 => '1',
		wrL1 => '0',
		wrU1 => '0',
		dataout1 => open,
		dtack1 => open
	);

-- Video
	
	myvga : entity work.vga_controller
		port map (
		clk => clk,
		reset => reset,

		reg_addr_in => mem_addr(11 downto 0),
		reg_data_in => mem_write,
		reg_data_out => vga_reg_dataout,
		reg_rw => vga_reg_rw,
		reg_uds => cpu_uds,
		reg_lds => cpu_lds,
		reg_dtack => vga_reg_dtack,
		reg_req => vga_reg_req,

		sdr_addrout => vga_addr,
		sdr_datain => vga_data, 
		sdr_fill => vga_fill,
		sdr_req => vga_req,
		sdr_ack => vga_ack,
		sdr_reservebank => vga_reservebank,
		sdr_reserveaddr => vga_reserveaddr,
		sdr_refresh => vga_refresh,

		hsync => vga_hsync,
		vsync => vga_vsync,
		vblank_int => vblank_int,
		red => vga_red,
		green => vga_green,
		blue => vga_blue,
		vga_window => vga_window
	);
	


process(clk)
begin
	if reset_in='0' then
		reset_counter<=X"FFFF";
		reset<='0';
	elsif rising_edge(clk) then
		reset_counter<=reset_counter-1;
		if reset_counter=X"0000" then
			reset<='1' and sdr_ready;
		end if;
	end if;
end process;


-- UART

	myuart : entity work.simple_uart
		port map(
			clk => clk,
			reset => reset, -- active low
			txdata => ser_txdata,
			txready => ser_txready,
			txgo => ser_txgo,
			rxdata => ser_rxdata,
			rxint => ser_rxint,
			txint => open,
			clock_divisor => ser_clock_divisor,
			rxd => rs232_rxd,
			txd => rs232_txd
		);


-- Main CPU

	 zpu: zpu_core 
	 generic map (
			HARDWARE_MULTIPLY => false,
			COMPARISON_SUB => true,
			EQBRANCH => true
		)
    port map (
        clk                 => clk2,
        reset               => not reset,
        enable              => zpu_enable,
        in_mem_busy         => mem_busy, 
        mem_read            => mem_read,
        mem_write           => mem_write, 
        out_mem_addr        => mem_addr, 
        out_mem_writeEnable => mem_writeEnable,  
        out_mem_readEnable  => mem_readEnable,
        mem_writeMask       => mem_writeMask, 
        interrupt           => zpu_interrupt,
        break               => zpu_break
    );

	 
	externram_wren <= mem_writeEnable when mem_addr(31 downto 16)=X"0000" else '0';

	ram : entity work.ExternalRAM
	port map (
		address => mem_addr(12 downto 2),
		clock	=> clk2,
		data => mem_write,
		wren => externram_wren,
		q => externram_data
	);

process(clk)
begin
	zpu_enable<='1';
	zpu_interrupt<='0';

	if rising_edge(clk2) then
		mem_busy<='1';

		ser_txgo<='0';
		if ser_rxint='1' then
			ser_rxrecv<='1';
		end if;

		vga_reg_rw<='1';
		vga_reg_req<='0';
		
		case currentstate is
			when WAITING =>
			
				-- Write from CPU
				if mem_writeEnable='1' then
					case mem_addr(31 downto 16) is
						when X"0000" =>	-- Boot BlockRAM
							currentstate<=WRITE1;
						when X"FFFE" =>	-- VGA controller
							vga_reg_rw<='0';
							vga_reg_req<='1';
							mem_busy<='0';
						when X"FFFF" =>	-- Peripherals
							case mem_addr(15 downto 0) is
								when X"FF84" => -- UART
									ser_txdata<=mem_write(7 downto 0);
									ser_txgo<='1';
									
								when X"FF88" => -- UART Clock divisor
									ser_clock_divisor<=unsigned(mem_write(15 downto 0));
									
								when X"FF90" => -- HEX display
									counter<=unsigned(mem_write(15 downto 0));
								when others =>
									null;
							end case;
							mem_busy<='0';
						when others => -- SDRAM access
							mem_busy<='0';
					end case;
					

				elsif mem_readEnable='1' then
					case mem_addr(31 downto 16) is
						when X"0000" =>	-- Boot BlockRAM
							currentstate<=READ1;

						when X"FFFE" =>	-- VGA controller
							vga_reg_req<='1';
							mem_read<=X"0000"&vga_reg_dataout;
							mem_busy<='0';

						when X"FFFF" =>	-- Peripherals
							case mem_addr is
								when X"FFFFFF84" => -- UART
									mem_read<=(others=>'0');
									mem_read(9 downto 0)<=ser_rxrecv&ser_txready&ser_rxdata;
									ser_rxrecv<='0';	-- Clear rx flag.
									
								when X"FFFFFF8C" => -- Flags (switches) register
									mem_read<=X"0000"&src;
									
								when others =>
									null;
							end case;
							mem_busy<='0';

						when others => -- SDRAM
							mem_busy<='0';
					end case;
				end if;

			when READ1 =>
				mem_read<=externram_data;
				mem_busy<='0';
				currentstate<=WAITING;

			when WRITE1 =>
				mem_busy<='0';
				currentstate<=PAUSE;
				
			when PAUSE =>
				currentstate<=WAITING;

			when others =>
				currentstate<=WAITING;
				null;
		end case;
	end if;

--	
--signal mem_read             : std_logic_vector(wordSize-1 downto 0);
--signal mem_write            : std_logic_vector(wordSize-1 downto 0);
--signal mem_addr             : std_logic_vector(maxAddrBitIncIO downto 0);
--signal mem_writeEnable      : std_logic; 
--signal mem_readEnable       : std_logic;
--signal mem_writeMask        : std_logic_vector(wordBytes-1 downto 0);
--signal zpu_enable               : std_logic;
--signal zpu_interrupt            : std_logic;
--signal zpu_break                : std_logic;

end process;
	
end architecture;
