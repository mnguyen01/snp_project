----------------------------------------------------------------------------------
-- Company: ESIEE PARIS
-- Engineer: K. ELM & S. BEAU
-- Create Date: 13:00:00 19/03/2018 
-- Design Name: Compteur_Score
-- Project Name: Sweep&Play
-- Tool versions: v1
-- Description: counter of the player's score
----------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Compteur_Score is
generic (
		SCORE_INIT : integer := 0; --valeur initiale du score
		SCORE_MAX  : integer := 255 --valeur maximale du score
	);
	port ( 
		-- entrees
		clk     : in  std_logic;
		resetn  : in  std_logic;
		but     : in  std_logic; --un but a été marqué et il faut incrémenter le score
		newGame : in  std_logic; --le jeu redémarre, et il faut raz le score
		-- sortie
		score   : out std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0) --score du joueur
	);
end entity;

architecture rtl of Compteur_Score is 
signal signal_score : unsigned(score'range);
begin

	score <= std_logic_vector(signal_score);

	process(clk,resetn) is
	begin
		if resetn ='0' then
			signal_score <= to_unsigned(SCORE_INIT, score'length);
		elsif rising_edge(clk) then
			if newGame = '1' then
				signal_score <= to_unsigned(SCORE_INIT, score'length);
			elsif but = '1' and signal_score < to_unsigned(SCORE_MAX, score'length) then
				signal_score <= signal_score + 1;
			end if;
		end if;
	end process;

end architecture;