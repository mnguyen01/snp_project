----------------------------------------------------------------------------------
-- Company: ESIEE PARIS
-- Engineer: K. ELM 
-- Create Date: 13:00:00 16/02/2018 
-- Design Name: Ball
-- Module Name: WolfGang
-- Project Name: Sweep&Play
-- Tool versions: v2
-- Description: description of the Ball's behavior on the axis of X
----------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Ball is
	generic (
		HORIZONTAL_RESOLUTION : natural := 640;
		VERTICAL_RESOLUTION   : natural := 480
	);
	port ( 
		clk            : in  std_logic;
		resetn         : in  std_logic;
		
		enable_vitesse : in  std_logic; --signal périodique qui règle la vitesse de déplacement de la balle
		etat_balle     : in  std_logic_vector(1 downto 0); --la balle se déplace : "00" haut droite ; "01" bas droite ; "10" bas gauche ; "11" haut gauche
		but            : in  std_logic; --signal qu'il y a eu un but. il faut remettre la balle au mileu du terrain
		pos_x          : out std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
		pos_y          : out std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0)
	);
end entity;

architecture rtl of Ball is
signal signal_pos_x : unsigned(pos_x'range);
signal signal_pos_y : unsigned(pos_y'range);
constant POSITION_INITIALE_X : unsigned(pos_x'range) := to_unsigned(HORIZONTAL_RESOLUTION/2, pos_x'length);
constant POSITION_INITIALE_Y : unsigned(pos_y'range) := to_unsigned(VERTICAL_RESOLUTION  /2, pos_y'length);
begin
	
	pos_x <= std_logic_vector(signal_pos_x);
	pos_y <= std_logic_vector(signal_pos_y);
	
process(clk,resetn) is
begin
	if resetn = '0' then
		signal_pos_x <= POSITION_INITIALE_X;
		signal_pos_y <= POSITION_INITIALE_Y;
	elsif rising_edge(clk) then
		if enable_vitesse = '1' then
			case etat_balle is
				when "01"   => signal_pos_x <= signal_pos_x + 1;
				               signal_pos_y <= signal_pos_y + 1;
				when "10"   => signal_pos_x <= signal_pos_x - 1;
				               signal_pos_y <= signal_pos_y + 1;
				when "11"   => signal_pos_x <= signal_pos_x - 1;
				               signal_pos_y <= signal_pos_y - 1;
				when others => signal_pos_x <= signal_pos_x + 1;
				               signal_pos_y <= signal_pos_y - 1;
			end case;
		end if;
		if but = '1' then
			signal_pos_x <= POSITION_INITIALE_X;
			signal_pos_y <= POSITION_INITIALE_Y;
		end if;
	end if;
end process;

end architecture;

