library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity C4Toplevel is
port(
	CLK50M : in std_logic;
	KEY0 : in std_logic;
	KEY1 : in std_logic;
	LED : out std_logic_vector(1 downto 0);
	CK : in std_logic_vector(3 downto 0); -- Alias SW(3 downto 0)
	-- SDRAM interface
	SDRAM_Addr : out std_logic_vector(12 downto 0);
	SDRAM_BA : out std_logic_vector(1 downto 0);
	SDRAM_CAS_N : out std_logic;
	SDRAM_CKE : out std_logic;
	SDRAM_CLK : out std_logic;
	SDRAM_CS_N : out std_logic;
	SDRAM_DQ : inout std_logic_vector(15 downto 0);
	SDRAM_DQM : out std_logic_vector(1 downto 0);
	SDRAM_RAS_N : out std_logic;
	SDRAM_WE_N : out std_logic;
	-- GPIO
	IO_D : inout std_logic_vector(40 downto 1)
);
end entity;

architecture rtl of C4Toplevel is

signal sysclk : std_logic;
signal reset : std_logic;
signal UART_TXD : std_logic;
signal UART_RXD : std_logic;

signal LCD_data_out : std_logic_vector(15 downto 0);
signal LCD_data_in : std_logic_vector(15 downto 0);
signal LCD_drive : std_logic; -- Select signal used to control tristate bus
signal LCD_reset : std_logic;
signal LCD_cs : std_logic;
signal LCD_wr : std_logic;
signal LCD_rd : std_logic;
signal LCD_rs : std_logic;
signal LCD_blcnt : std_logic;

begin

IO_D <= (others => 'Z');

-- UART mapping
IO_D(40) <= UART_TXD;
UART_RXD <= IO_D(39);

-- LCD signal mapping.
IO_D(16 downto 1) <= LCD_data_out when LCD_drive='1' else (others => 'Z');
LCD_data_in <= IO_D(16 downto 1);
IO_D(17) <= LCD_cs;
IO_D(18) <= LCD_rs;
IO_D(19) <= LCD_wr;
IO_D(20) <= LCD_rd;
IO_D(21) <= LCD_reset;
IO_D(22) <= LCD_blcnt;

-- Other IO mappings

reset <= KEY0;

-- PLL

MyPLL : entity work.PLL
port map(
	inclk0 => CLK50M,
	c0 => sysclk,
	c1 => SDRAM_CLK
);

-- Main project instance.

myZPUTest : entity work.ZPUTest
		generic map(
			sdram_rows => 13,
			sdram_cols => 9,
			sysclk_frequency => 1250,
			spi_maxspeed => 4,
			run_from_ram => true,
			manifest_file1 => X"5a505554", -- ZPUT
			manifest_file2 => X"45535420"  -- EST 
		)
		port map(
			clk => sysclk,
			reset_in => reset,
			keys => "1111",
			src => X"0000",

			-- SDRAM - presenting a single interface to both chips.
			sdr_addr => SDRAM_Addr,
			sdr_data => SDRAM_DQ,
			sdr_ba => SDRAM_BA,
			sdr_cke => SDRAM_CKE,
			sdr_dqm => SDRAM_DQM,
			sdr_cs => SDRAM_CS_N,
			sdr_we => SDRAM_WE_N,
			sdr_cas => SDRAM_CAS_N,
			sdr_ras => SDRAM_RAS_N,
			
			-- VGA
			vga_red => open,
			vga_green => open,
			vga_blue => open,
			
			vga_hsync => open,
			vga_vsync => open,
			
			vga_window => open,

			-- UART
			rxd => UART_RXD,
			txd => UART_TXD,

			-- SD Card interface
--			spi_cs => sd_cs,
--			spi_miso => sd_miso,
--			spi_mosi => sd_mosi,
--			spi_clk => sd_clk

			-- LCD interface
			lcd_data_out => LCD_data_out,
			lcd_data_in => LCD_data_in,
			lcd_drive => LCD_drive,
			lcd_reset => LCD_reset,
			lcd_cs => LCD_cs,
			lcd_wr => LCD_wr,
			lcd_rd => LCD_rd,
			lcd_rs => LCD_rs,
			lcd_blcnt => LCD_blcnt
		);


end architecture;
