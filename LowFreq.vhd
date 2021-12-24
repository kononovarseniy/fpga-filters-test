library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math.all;

entity LowFreq is
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
end entity;

architecture rtl of LowFreq is

	constant extra_bits: positive := log2(param_a);
	constant total_bits: positive := data_bits + 2 * extra_bits;
	signal acc: unsigned(total_bits - 1 downto 0);

begin
	
	process (clk_i) is
	variable rem_val, add_val: integer;
	begin
		if rising_edge(clk_i) then
			if reset_i = '1' then
				acc <= to_unsigned(0, total_bits);
				signal_o <= to_unsigned(0, data_bits);
			else
				acc <= resize(resize(signal_i, total_bits) * (2**extra_bits), total_bits) + acc - acc / param_a;
				signal_o <= resize(acc / (2**extra_bits) / param_a, data_bits);
			end if;
		end if;
	end process;
	
end architecture;
