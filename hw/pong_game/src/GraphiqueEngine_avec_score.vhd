library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.math_real.all;

entity graphic_engine is 
	generic ( 
		freq_carte            : positive := 100e6;
		--caractéristiques écran
		HORIZONTAL_RESOLUTION : natural := 640;
		VERTICAL_RESOLUTION   : natural := 480;
		
		Front_porch_h         : natural := 16;
		Sync_pulse_h          : natural := 96;
		Back_porch_h          : natural := 48;
		Front_porch_v         : natural := 10;
		Sync_pulse_v          : natural := 2;
		Back_porch_v          : natural := 33;
		
		TAILLE_PIXEL          : natural := 8;
		 
		--caractéristiques objets du jeu
		OFFSET_CURSEUR_X      : natural := 50;
		LONGUEUR_PALETTE      : natural := 50;
		LARGEUR_PALETTE       : natural := 5;
		TAILLE_BALLE          : natural := 10;
		
		--caractéristiques score
		SCORE_MAX             : natural := 10;
		TAILLE_CARRE          : natural := 10;
		OFFSET_CARRE          : natural := 5
	);

	port ( 
		pos_X_vga    : in  std_logic_vector( integer(ceil(log2(real(HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h + Back_porch_h-1)))) - 1 downto 0); -- position de pixel en X  
		pos_Y_vga    : in  std_logic_vector( integer(ceil(log2(real(VERTICAL_RESOLUTION   + Front_porch_v + Sync_pulse_v + Back_porch_v-1)))) - 1 downto 0); -- position de pixel en Y  
		pixel        : out std_logic_vector ( TAILLE_PIXEL-1 downto 0);  -- pixel à activer en fct de X et Y
		--de chez Kamel
		--CurseurX1_in : in std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
		--CurseurX2_in : in std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
		CurseurY1_in : in  std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
		CurseurY2_in : in  std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
		Balle_X_in   : in  std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
		Balle_Y_in   : in  std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
		score_J1     : in  std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0); --score du joueur
		score_J2     : in  std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0) --score du joueur
	);
end entity; 


architecture affichage of graphic_engine is 
signal vga_x     : unsigned(pos_X_vga'range);
signal vga_y     : unsigned(pos_Y_vga'range);
signal curseur_x_j1 : unsigned(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
signal curseur_x_j2 : unsigned(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
signal curseur_y_j1 : unsigned(CurseurY1_in'range);
signal curseur_y_j2 : unsigned(CurseurY2_in'range);
signal balle_x   : unsigned(Balle_X_in'range);  
signal balle_y   : unsigned(Balle_Y_in'range); 	
signal afficher_balle, afficher_cur_1, afficher_cur_2 : std_logic;
signal afficher_contour : std_logic;
signal afficher_score : std_logic;
--signal afficher : std_logic_vector(4 downto 0);
constant bleu  : std_logic_vector(7 downto 0) := "11100000";
constant blanc : std_logic_vector(7 downto 0) := "11111111";
constant rouge : std_logic_vector(7 downto 0) := "00000111";
constant noir  : std_logic_vector(7 downto 0) := "00000000";
begin 

	vga_x        <= unsigned(pos_X_vga);
    vga_y        <= unsigned(pos_Y_vga);
	curseur_x_j1 <= to_unsigned(OFFSET_CURSEUR_X                      , curseur_x_j1'length);
    curseur_x_j2 <= to_unsigned(HORIZONTAL_RESOLUTION-OFFSET_CURSEUR_X, curseur_x_j2'length);
    curseur_y_j1 <= unsigned(CurseurY1_in);
    curseur_y_j2 <= unsigned(CurseurY2_in);
    balle_x      <= unsigned(Balle_X_in  );
    balle_y      <= unsigned(Balle_Y_in  );

	--afficher <= afficher_balle & afficher_cur_1 & afficher_cur_2 & afficher_contour & afficher_score;
	pixel <= pos_X_vga(vga_x'high downto vga_x'high-7 ) when afficher_balle   = '1' else
			 rouge when afficher_cur_1   = '1' else
			 rouge when afficher_cur_2   = '1' else
			 bleu  when afficher_contour = '1' else
			 blanc when afficher_score   = '1' else
			 noir;
	
	afficher_balle <= '1' when (vga_x >= balle_x-to_unsigned(TAILLE_BALLE/2, balle_x'length)
							and vga_x <= balle_x+to_unsigned(TAILLE_BALLE/2, balle_x'length)
							and vga_y >= balle_y-to_unsigned(TAILLE_BALLE/2, balle_y'length)
							and vga_y <= balle_y+to_unsigned(TAILLE_BALLE/2, balle_y'length)
							)
						  else '0';
				
	afficher_cur_1 <= '1' when (vga_x >= curseur_x_j1-to_unsigned(LARGEUR_PALETTE/2, curseur_x_j1'length)
							and vga_x <= curseur_x_j1+to_unsigned(LARGEUR_PALETTE/2, curseur_x_j1'length)
							and vga_y >= curseur_y_j1-to_unsigned(LONGUEUR_PALETTE/2, curseur_y_j1'length)
							and vga_y <= curseur_y_j1+to_unsigned(LONGUEUR_PALETTE/2, curseur_y_j1'length)
							)
						  else '0';

	afficher_cur_2 <= '1' when (vga_x >= curseur_x_j2-to_unsigned(LARGEUR_PALETTE/2, curseur_x_j2'length)
							and vga_x <= curseur_x_j2+to_unsigned(LARGEUR_PALETTE/2, curseur_x_j2'length)
							and vga_y >= curseur_y_j2-to_unsigned(LONGUEUR_PALETTE/2, curseur_y_j2'length)
							and vga_y <= curseur_y_j2+to_unsigned(LONGUEUR_PALETTE/2, curseur_y_j2'length)
								)
						  else '0';
			
	afficher_contour <= '1' when (vga_x = to_unsigned(0, vga_x'length)
							   or vga_x = to_unsigned(HORIZONTAL_RESOLUTION-1, vga_x'length)
							   or vga_y = to_unsigned(0, vga_y'length)
							   or vga_y = to_unsigned(VERTICAL_RESOLUTION-1  , vga_y'length)
								 )
							else '0';
							
	interface : entity work.hud
	generic map(
		SCORE_MAX    => SCORE_MAX   ,
		TAILLE_CARRE => TAILLE_CARRE,
		OFFSET_CARRE => OFFSET_CARRE
	)
	port map(
		vga_x    => pos_X_vga,
		vga_y    => pos_Y_vga,
		score_J1 => score_J1 ,
		score_J2 => score_J2 ,
		
		afficher_score => afficher_score
	);
	
end architecture; 