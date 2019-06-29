library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity palette is
	generic (
		VERTICAL_RESOLUTION : natural := 480;
		LONGUEUR_PALETTE    : natural := 50
	);
	port ( 
		clk              : in  std_logic; --horloge
		resetn           : in  std_logic; --remise a zero active a l'etat bas
		
		commande         : in  std_logic_vector(2 downto 0); --"00" ne bouge pas  --"01" descend  --"10" monte  --"11" remet au centre
		enable_vitesse   : in  std_logic; --signal périodique qui règle la vitesse de déplacement du curseur
		
		-- sorties
		position_curseur : out std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION-1))))-1 downto 0) --position du curseur
	);
end entity;

architecture rtl of palette is 
signal signal_position_curseur : unsigned(position_curseur'range);
constant POSITION_INITIALE : unsigned(position_curseur'range) := to_unsigned(VERTICAL_RESOLUTION/2, signal_position_curseur'length);
begin
	
	position_curseur <= std_logic_vector(signal_position_curseur);
	
	process(clk, resetn) is
	begin
		if resetn = '0' then
			signal_position_curseur <= POSITION_INITIALE;
		elsif rising_edge(clk) then
			if enable_vitesse = '1' then
				case commande is
					when "100" => --descendre
						if signal_position_curseur < to_unsigned(VERTICAL_RESOLUTION-LONGUEUR_PALETTE/2, signal_position_curseur'length) then
							signal_position_curseur <= signal_position_curseur + 1;
						end if;
					when "001" => --monter
						if signal_position_curseur > to_unsigned(LONGUEUR_PALETTE/2, signal_position_curseur'length) then
							signal_position_curseur <= signal_position_curseur - 1;
						end if;
					--when "011" => signal_position_curseur <= to_unsigned(VERTICAL_RESOLUTION/2, signal_position_curseur'length);
					when others => signal_position_curseur <= signal_position_curseur;
				end case;
			end if;
		end if;
	end process;

end architecture;