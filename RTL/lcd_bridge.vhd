library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity lcd_bridge is
port(
	-- Housekeeping
	clk : in std_logic;
	reset : in std_logic; -- Active low
	-- CPU signals
	from_cpu : in std_logic_vector(15 downto 0);
	cmd : in std_logic; -- '0' for command, '1' for data
	req : in std_logic;
	ack : out std_logic;
	rw : in std_logic;
	cs_in : in std_logic; -- Chip select
	-- LCD signals
	lcd_data_out : out std_logic_vector(15 downto 0);
	lcd_data_in : in std_logic_vector(15 downto 0);
	lcd_drive : out std_logic :='0'; -- Select signal used to control tristate bus
	lcd_reset : out std_logic;
	lcd_cs : out std_logic;
	lcd_wr : out std_logic;
	lcd_rd : out std_logic;
	lcd_rs : out std_logic;
	lcd_blcnt : out std_logic
);
end entity;

architecture rtl of lcd_bridge is

signal delay : unsigned(5 downto 0);
type lcdstate is (idle, waiting, wr1, wr2, wr3, wr4, rd1, rd2, rd3, rd4);
signal currentstate : lcdstate;
signal nextstate : lcdstate;

begin

lcd_reset <= reset;
lcd_cs <= cs_in; -- Routing CS explicitly through this entity ensures it's not forgotten.
lcd_data_out <= from_cpu; -- Just parrot this blindly since we're making the CPU wait.

process(clk, reset)
begin
	if reset='0' then
		delay<=(others=>'0');
		nextstate<=idle;
		currentstate<=waiting;
		lcd_drive<='0';
		lcd_rd<='1';
		lcd_blcnt<='1';
	elsif rising_edge(clk) then
		-- Unless directed otherwise by the state machine, we'll land in the waiting state.
		-- Provided delay remains at zero, this will be overridden by the idle state when idle.
		currentstate<=waiting;

		-- Change state after a certain number of cycles have elapsed.
		if delay="000000" then
			currentstate<=nextstate;
			delay<="000001";
		else
			delay<=delay-1;
		end if;

		ack<='0';

		case currentstate is
		
			when idle =>
				if req='1' then
					lcd_rs<=cmd;

					if rw='0' then -- write cycle?
						nextstate<=wr1;
						lcd_wr<='0';
						delay<="000010";
					end if;
				end if;
				
			when wr1 =>
				lcd_drive<='1';
				delay<="000010";
				nextstate<=wr2;
			
			when wr2 =>
				lcd_wr<='1';
				delay<="000010";
				nextstate<=wr3;

			when wr3 =>
				lcd_drive<='0';
				ack<='1';
				nextstate<=idle;

			when waiting =>
				null;

			when others =>
				null;
		end case;

	end if;
end process;

end architecture;
