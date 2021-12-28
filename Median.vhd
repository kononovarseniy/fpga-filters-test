library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Median is
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
end entity;

architecture rtl of Median is

	type window_type is array (0 to window - 1) of unsigned(data_bits - 1 downto 0);
	signal w, sw: window_type;

begin
	
	process (clk_i) is
	variable rem_val, add_val: unsigned(data_bits - 1 downto 0);
	begin
		if rising_edge(clk_i) then
			if reset_i = '1' then
				for i in 0 to window - 1 loop
					w(i) <= signal_i;
					sw(i) <= signal_i;
					signal_o <= to_unsigned(0, data_bits);
				end loop;
			else
				if window mod 2 = 1 then
					signal_o <= sw(window / 2);
				else
					signal_o <= (sw(window / 2 - 1) + sw(window / 2)) / 2;
				end if;
			
				rem_val := w(0);
				add_val := signal_i;
				-- Move window.
				for i in 0 to window - 2 loop
					w(i) <= w(i + 1);
				end loop;
				w(window - 1) <= signal_i;
				-- Update sorted window.
				-- First case.
				if rem_val < add_val then
					if sw(0) = rem_val then
						sw(0) <= sw(1);
					end if;
					if sw(window - 1) < add_val then
						sw(window - 1) <= add_val;
					end if;
					for i in 1 to window - 2 loop
						if sw(i) < rem_val then
							sw(i) <= sw(i);
						elsif sw(i) >= rem_val and sw(i) < add_val then
							if sw(i + 1) >= add_val then
								sw(i) <= add_val;
							else
								sw(i) <= sw(i + 1);
							end if;
						elsif sw(i) >= add_val then
							sw(i) <= sw(i);
						end if;
					end loop;
				-- Second case.
				elsif add_val < rem_val then
					if sw(0) > add_val then
						sw(0) <= add_val;
					end if;
					if sw(window - 1) = rem_val then
						sw(window - 1) <= sw(window - 2);
					end if;
					
					for i in 1 to window - 2 loop
						if sw(i) < add_val then
							sw(i) <= sw(i);
						elsif sw(i) >= add_val and sw(i) < rem_val then
							if sw(i - 1) < add_val then
								sw(i) <= add_val;
							else
								sw(i) <= sw(i - 1);
							end if;
						elsif sw(i) >= rem_val then
							if sw(i - 1) < rem_val and sw(i - 1) < add_val then
								sw(i) <= add_val;
							elsif sw(i - 1) < rem_val then
								sw(i) <= sw(i - 1);
							else
								sw(i) <= sw(i);
							end if;
						end if;
					end loop;
				end if;
			end if;
		end if;
	end process;
	
end architecture;
