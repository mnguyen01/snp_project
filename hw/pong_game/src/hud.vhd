library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.math_real.all;

entity hud is 
	generic ( 
		freq_carte            : positive := 100e6;
		--caractéristique écran
		HORIZONTAL_RESOLUTION : natural := 640;
		VERTICAL_RESOLUTION   : natural := 480;
		
		Front_porch_h         : natural := 16;
		Sync_pulse_h          : natural := 96;
		Back_porch_h          : natural := 48;
		Front_porch_v         : natural := 10;
		Sync_pulse_v          : natural := 2;
		Back_porch_v          : natural := 33;
		
		SCORE_MAX             : natural := 10;
		TAILLE_CARRE          : natural := 10;
		OFFSET_CARRE          : natural := 5
	);

	port ( 
		vga_x    : in  std_logic_vector(integer(ceil(log2(real(HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h + Back_porch_h-1)))) - 1 downto 0); -- position de pixel en X  
		vga_y    : in  std_logic_vector(integer(ceil(log2(real(VERTICAL_RESOLUTION   + Front_porch_v + Sync_pulse_v + Back_porch_v-1)))) - 1 downto 0); -- position de pixel en Y  
		score_J1 : in  std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0); --score du joueur 1
		score_J2 : in  std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0); --score du joueur 2
		
		afficher_score : out std_logic
	);
end entity; 


architecture affichage of hud is 

signal afficher_J1 : std_logic_vector(SCORE_MAX-1 downto 0);
signal afficher_J2 : std_logic_vector(SCORE_MAX-1 downto 0);
signal in_ligne    : std_logic;

begin 
	
	in_ligne <= '1' when (unsigned(vga_y) >= to_unsigned(OFFSET_CARRE               , vga_y'length)
					  and unsigned(vga_y) <= to_unsigned(OFFSET_CARRE+TAILLE_CARRE  , vga_y'length)
					  )
					else '0';
	
	test_carres :
	for i in 0 to SCORE_MAX-1 generate
		afficher_J1(i) <= '1' when (unsigned(vga_x) >= to_unsigned(OFFSET_CARRE*(i+1) + TAILLE_CARRE* i   , vga_x'length)
								and unsigned(vga_x) <= to_unsigned(OFFSET_CARRE*(i+1) + TAILLE_CARRE*(i+1), vga_x'length)
								and in_ligne = '1'
								and to_unsigned(i, score_J1'length) < unsigned(score_J1)
								)
							  else '0';
							  
		afficher_J2(i) <= '1' when (unsigned(vga_x) <= to_unsigned(HORIZONTAL_RESOLUTION - (OFFSET_CARRE*(i+1) + TAILLE_CARRE* i   ), vga_x'length)
								and unsigned(vga_x) >= to_unsigned(HORIZONTAL_RESOLUTION - (OFFSET_CARRE*(i+1) + TAILLE_CARRE*(i+1)), vga_x'length)
								and in_ligne = '1'
								and to_unsigned(i, score_J2'length) < unsigned(score_J2)
								)
							  else '0';
	end generate;
	
	afficher_score <= '1' when (afficher_J1 /= (afficher_J1'range => '0')) or (afficher_J2 /= (afficher_J2'range => '0')) else '0';
	
end architecture; 