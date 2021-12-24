library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Filters is
	port (
		clk_i: in std_logic;
		reset_i: in std_logic;
		signal_i: in std_logic_vector(4 downto 0);
		signal_o: out std_logic_vector(4 downto 0)
	);
end entity;

architecture rtl of Filters is

	component Median is
		generic (
			window: integer := 3
		);
		port (
			clk_i: in std_logic;
			reset_i: in std_logic;
			signal_i: in integer;
			signal_o: out integer
		);
	end component;

	signal input_s: integer;
	signal output_s: integer;
	
begin
	
	med: Median
		generic map (
			window => 3
		)
		port map (
			clk_i => clk_i,
			reset_i => reset_i,
			signal_i => input_s,
			signal_o => output_s
		);
	
	input_s <= to_integer(unsigned(signal_i));
	signal_o <= std_logic_vector(to_unsigned(output_s, signal_o'length));
	process (clk_i) is
	begin
		if rising_edge(clk_i) then
		end if;
	end process;
	
end architecture;
