library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpu_config.all;
use work.zpupkg.ALL;

entity ZPUTest is
	port (
		clk 			: in std_logic;
--		clk50			: in std_logic;
		src 			: in std_logic_vector(15 downto 0);
		counter 		: buffer unsigned(15 downto 0);
		reset_in 	: in std_logic;
		keys			: in std_logic_vector(3 downto 0);

		-- VGA
		vga_red 		: out unsigned(3 downto 0);
		vga_green 	: out unsigned(3 downto 0);
		vga_blue 	: out unsigned(3 downto 0);
		vga_hsync 	: out std_logic;
		vga_vsync 	: buffer std_logic;

		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector(11 downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
		sdr_clk		: out std_logic;
		sdr_clkena	: out std_logic
	);
end entity;

architecture rtl of ZPUTest is

signal clk100 : std_logic;
signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";

-- State machine
type SOCStates is (WAITING,READ1,WRITE1,PAUSE);
signal currentstate : SOCStates;

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

-- External RAM signal (actually M4k for now)

signal externram_wren : std_logic;
signal externram_data : std_logic_vector(wordSize-1 downto 0);

--

type sdrstate is (init,write1,write2,write3,write4,read1,read2,read3,read4,waitread,waitwrite,waitkey,
	burstwrite1,burstwrite2,burstwrite3,burstwrite4);
signal ramstate : sdrstate;
signal nextstate : sdrstate;

begin

sdr_clkena <='1';

mypll : ENTITY work.PLL
	port map
	(
		inclk0 => clk,
		c0 => sdr_clk,
		c1 => clk100,
		locked => open
	);


process(clk100)
begin
	if reset_in='0' then
		reset_counter<=X"FFFF";
		reset<='0';
	elsif rising_edge(clk100) then
		reset_counter<=reset_counter-1;
		if reset_counter=X"0000" then
			reset<='1'; --  and sdr_ready;
		end if;
	end if;
end process;

	 zpu: zpu_core 
	 generic map (
			HARDWARE_MULTIPLY => true
			)
    port map (
        clk                 => clk100,
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

	 
	externram_wren <= mem_writeEnable when mem_addr(31 downto 24)=X"00" else '0';

	ram : entity work.ExternalRAM
	port map (
		address => mem_addr(12 downto 2),
		clock	=> clk100,
		data => mem_write,
		wren => externram_wren,
		q => externram_data
	);

process(clk100)
begin
	zpu_enable<='1';
	zpu_interrupt<='0';

	if rising_edge(clk100) then
		mem_busy<='1';

		case currentstate is
			when WAITING =>
				if mem_writeEnable='1' then
					if mem_addr(31 downto 24)=X"00" then
						currentstate<=WRITE1;
					else
						case mem_addr is
							when X"FFFFFF80" => -- Need to make registers 32-bit aligned for ZPU
								counter<=unsigned(mem_write(15 downto 0));
							when others =>
								null;
						end case;
						mem_busy<='0';
					end if;		
				elsif mem_readEnable='1' then
					if mem_addr(31 downto 24)=X"00" then
						currentstate<=READ1;
					else
						case mem_addr is
							when X"FFFFFF84" => -- Need to make registers 32-bit aligned for ZPU
								mem_read<=X"0000"&src;
							when others =>
								null;
						end case;
						mem_busy<='0';
					end if;		
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
