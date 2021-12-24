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
			data_bits: positive := 8;
			window: integer := 3
		);
		port (
			clk_i: in std_logic;
			reset_i: in std_logic;
			signal_i: in unsigned(data_bits - 1 downto 0);
			signal_o: out unsigned(data_bits - 1 downto 0)
		);
	end component;
	
	component LowFreq is
		generic (
			data_bits: positive := 8;
			param_a: positive
		);
		port (
			clk_i: in std_logic;
			reset_i: in std_logic;
			signal_i: in unsigned(data_bits - 1 downto 0);
			signal_o: out unsigned(data_bits - 1 downto 0)
		);
	end component;

	signal input_s: unsigned(4 downto 0);
	signal output_s: unsigned(4 downto 0);
	signal input_s2: unsigned(4 downto 0);
	signal output_s2: unsigned(4 downto 0);
	
begin
	
	med: Median
		generic map (
			data_bits => 5,
			window => 3
		)
		port map (
			clk_i => clk_i,
			reset_i => reset_i,
			signal_i => input_s,
			signal_o => output_s
		);
		
	rc: LowFreq
		generic map (
			data_bits => 5,
			param_a => 30
		)
		port map (
			clk_i => clk_i,
			reset_i => reset_i,
			signal_i => input_s2,
			signal_o => output_s2
		);
	
--	input_s <= unsigned(signal_i);
--	signal_o <= std_logic_vector(output_s);
	input_s2 <= unsigned(signal_i);
	signal_o <= std_logic_vector(output_s2);
	process (clk_i) is
	begin
		if rising_edge(clk_i) then
		end if;
	end process;
	
end architecture;
