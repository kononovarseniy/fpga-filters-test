library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Filters is
	port (
		clk_i: in std_logic;
		reset_i: in std_logic;
		signal_i: in std_logic_vector(9 downto 0);
		signal_o: out std_logic_vector(9 downto 0)
	);
end entity;

architecture rtl of Filters is

	component Median is
		generic (
			data_bits: positive := 10;
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
			data_bits: positive := 10;
			param_a: positive
		);
		port (
			clk_i: in std_logic;
			reset_i: in std_logic;
			signal_i: in unsigned(data_bits - 1 downto 0);
			signal_o: out unsigned(data_bits - 1 downto 0)
		);
	end component;

	signal med_in, med_out, low_in, low_out: unsigned(9 downto 0);
	signal input_s: unsigned(9 downto 0);
	signal output_s: unsigned(9 downto 0);
	
begin
	
	med: Median
		generic map (
			data_bits => 10,
			window => 3
		)
		port map (
			clk_i => clk_i,
			reset_i => reset_i,
			signal_i => med_in,
			signal_o => med_out
		);
		
	rc: LowFreq
		generic map (
			data_bits => 10,
			param_a => 10
		)
		port map (
			clk_i => clk_i,
			reset_i => reset_i,
			signal_i => low_in,
			signal_o => low_out
		);
	
	input_s <= unsigned(signal_i);
	signal_o <= std_logic_vector(output_s);
	
	med_in <= input_s;
	low_in <= med_out;
	output_s <= low_out;
	
	process (clk_i) is
	begin
		if rising_edge(clk_i) then
		end if;
	end process;
	
end architecture;
