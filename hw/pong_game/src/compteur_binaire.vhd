library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity compteur_binaire is
	generic(
		N : positive := 8; -- compteur sur 8 bits
		x : positive := 100 -- modulo 100 (compte de 0 à 99)
	);
	port (
		clk		 : in  std_logic;
		resetn	 : in  std_logic; -- active low
		enable   : in  std_logic;
		cptr_out : out std_logic_vector(N-1 downto 0); --Etat du compteur
		fin_cptr : out std_logic
	);
end entity;

architecture rtl of compteur_binaire is
	signal cptr : unsigned(cptr_out'range);
begin
	cptr_out <= std_logic_vector(cptr);
	fin_cptr <= '1' when to_integer(cptr) >= x-1 and enable='1' else '0';
	
	process(clk, resetn) is
	begin
		if resetn = '0' then
			cptr <= (others => '0');
		elsif rising_edge(clk) then
			if enable = '1' then
				if to_integer(cptr) >= (x-1) then
					cptr <= (others => '0');
				else
					cptr <= cptr+1;
				end if;
			end if;
		end if;
	end process;

end architecture;