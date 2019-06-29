library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity pong_avec_score is
	generic (
		freq_carte             : natural := 100e6;
		freq_deplacement       : natural := 240;
		
		HORIZONTAL_RESOLUTION : natural := 640;
		VERTICAL_RESOLUTION   : natural := 480;
		
		Front_porch_h          : natural := 16;
		Sync_pulse_h           : natural := 96;
		Back_porch_h           : natural := 48;
		Front_porch_v          : natural := 10;
		Sync_pulse_v           : natural := 2;
		Back_porch_v           : natural := 33;
		
		TAILLE_PIXEL           : natural := 8;
		
		OFFSET_CURSEUR_X       : natural := 5;
		LONGUEUR_PALETTE       : natural := 100;
		LARGEUR_PALETTE        : natural := 10;
		TAILLE_BALLE           : natural := 20;
		
		SCORE_MAX              : natural := 10
	);
	port( 
		clk        : in  std_logic;
		resetn     : in  std_logic;
		           
		control_J1_in : in std_logic_vector(2 downto 0);
		control_J2_in : in std_logic_vector(2 downto 0);
		
		Rout_out   : out std_logic_vector(2 downto 0);
		Gout_out   : out std_logic_vector(2 downto 0);
		Bout_out   : out std_logic_vector(1 downto 0);
		Vsync      : out std_logic;
		Hsync      : out std_logic;
		leds       : out std_logic_vector(3 downto 0)
	);

end entity;

architecture fsm of pong_avec_score is
signal pos_balle_x_out   : std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
signal pos_balle_y_out   : std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
signal pos_palette_1_out : std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
signal pos_palette_2_out : std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);


signal pos_pixel_x : std_logic_vector( integer(ceil(log2(real(HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h + Back_porch_h-1)))) - 1 downto 0);
signal pos_pixel_y : std_logic_vector( integer(ceil(log2(real(VERTICAL_RESOLUTION   + Front_porch_v + Sync_pulse_v + Back_porch_v-1)))) - 1 downto 0);
signal pixel       : std_logic_vector(7 downto 0);
signal control_J1 : std_logic_vector(2 downto 0);
signal control_J2 : std_logic_vector(2 downto 0);
signal score_J1 : std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0); --score du joueur
signal score_J2 : std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0); --score du joueur
begin
	
	leds <= score_J2;
	
	control_J1 <= control_J1_in;
	control_J2 <= control_J2_in;
	
	physique_du_jeu : entity work.game_engine
	generic map(
		freq_carte             => freq_carte            ,
		freq_deplacement       => freq_deplacement      ,
		
		HORIZONTAL_RESOLUTION => HORIZONTAL_RESOLUTION,
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION  ,
		
		OFFSET_CURSEUR_X       => OFFSET_CURSEUR_X      ,
		LONGUEUR_PALETTE       => LONGUEUR_PALETTE      ,
		LARGEUR_PALETTE        => LARGEUR_PALETTE       
	)
	port map(
		clk               => clk              ,
		resetn            => resetn           ,
		
		control_J1        => control_J1       ,
		control_J2        => control_J2       ,
		
		pos_balle_x_out   => pos_balle_x_out  ,
		pos_balle_y_out   => pos_balle_y_out  ,
		pos_palette_1_out => pos_palette_1_out,
		pos_palette_2_out => pos_palette_2_out,
		score_J1          => score_J1         ,
		score_J2          => score_J2
	);
	
	graphique_du_jeu : entity work.graphic_engine
	generic map(
		freq_carte            => freq_carte           ,
		
		HORIZONTAL_RESOLUTION => HORIZONTAL_RESOLUTION,
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION  ,
		
		Front_porch_h         => Front_porch_h        ,
		Sync_pulse_h          => Sync_pulse_h         ,
		Back_porch_h          => Back_porch_h         ,
		Front_porch_v         => Front_porch_v        ,
		Sync_pulse_v          => Sync_pulse_v         ,
		Back_porch_v          => Back_porch_v         ,
		
		TAILLE_PIXEL          => TAILLE_PIXEL         ,
		
		OFFSET_CURSEUR_X      => OFFSET_CURSEUR_X     ,
		LONGUEUR_PALETTE      => LONGUEUR_PALETTE     ,
		LARGEUR_PALETTE       => LARGEUR_PALETTE      ,
		TAILLE_BALLE          => TAILLE_BALLE         
	)
	port map(
		--entrée vga
		pos_X_vga     => pos_pixel_x,                   
	    pos_Y_vga     => pos_pixel_y,
		--sortie vga
	    pixel     => pixel,
	    CurseurY1_in => pos_palette_1_out,
		CurseurY2_in => pos_palette_2_out,
	    Balle_X_in   => pos_balle_x_out,
		Balle_Y_in   => pos_balle_y_out,
		score_J1   => score_J1   ,
		score_J2   => score_J2
	);
	
	affichage : entity work.VGA
	generic map(
		freq_carte            => freq_carte           ,
		
		HORIZONTAL_RESOLUTION => HORIZONTAL_RESOLUTION,
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION  ,
		
		Front_porch_h         => Front_porch_h        ,
		Sync_pulse_h          => Sync_pulse_h         ,
		Back_porch_h          => Back_porch_h         ,
		Front_porch_v         => Front_porch_v        ,
		Sync_pulse_v          => Sync_pulse_v         ,
		Back_porch_v          => Back_porch_v         
	)
	port map(
		resetn     => resetn     ,
		clk        => clk        ,
		enable     => '1'        ,
		                         
		pixel_in   => pixel      ,
		pos_x      => pos_pixel_x,
		pos_y      => pos_pixel_y,
		
		Rout_out   => Rout_out   ,
		Gout_out   => Gout_out   ,
		Bout_out   => Bout_out   ,
		Vsync      => Vsync      ,
		Hsync      => Hsync      
	);
	
end architecture;