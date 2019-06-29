---------------------------------------------
-- Diviseur d'horloge                      --
--                                         --
-- BEAU                                    --
--                                         --
-- 10/2017                                 --
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generateur_d_impulsion is
	generic(
		freq_in : positive := 100e6; --fréquence de l'horloge d'entré
		freq_out : positive := 800e3 --fréquence de l'horloge de sortie
	);
	port (
		clk_in  : in std_logic; --horloge d'entré
		resetn  : in std_logic; -- active low
		clk_out	: out std_logic; --horloge de sortie
		enable  : in std_logic := '1'
	);
end entity;

architecture rtl of generateur_d_impulsion is
	constant x : natural := freq_in/freq_out;
	signal ctr : natural range 0 to x-1;
begin

	process(clk_in, resetn) is
	begin
		if resetn = '0' then
			ctr <= 0;
			clk_out <= '0';
		elsif rising_edge(clk_in) then
			if enable = '1' then
				if ctr >= (x-1) then
					ctr <= 0;
					clk_out <= '1';
				else
					ctr <= ctr+1;
					clk_out <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;