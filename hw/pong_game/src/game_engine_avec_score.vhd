library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity game_engine is
	generic (
		freq_carte             : natural := 100e6;
		freq_deplacement       : natural := 240;
		
		HORIZONTAL_RESOLUTION  : natural := 640;
		VERTICAL_RESOLUTION    : natural := 480;
		
		OFFSET_CURSEUR_X       : natural := 50;
		LONGUEUR_PALETTE       : natural := 50;
		LARGEUR_PALETTE        : natural := 5;
		SCORE_MAX              : natural := 10
	);
	port( 
		clk               : in  std_logic;
		resetn            : in  std_logic;
		                  
		control_J1        : in std_logic_vector(2 downto 0);
		control_J2        : in std_logic_vector(2 downto 0);
		
		pos_balle_x_out   : out std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
		pos_balle_y_out   : out std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
		pos_palette_1_out : out std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
		pos_palette_2_out : out std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
		score_J1          : out std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0); --score du joueur
		score_J2          : out std_logic_vector(integer(ceil(log2(real(SCORE_MAX-1))))-1 downto 0)  --score du joueur
	);

end entity;

architecture fsm of game_engine is
signal pos_balle_x    : std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0);
signal pos_balle_y    : std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
signal pos_palette_1  : std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
signal pos_palette_2  : std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0);
signal etat_balle     : std_logic_vector(1 downto 0);
signal enable_vitesse : std_logic;
signal but, but_J1, but_J2 : std_logic;
begin
	
	pos_balle_x_out   <= pos_balle_x  ;
	pos_balle_y_out   <= pos_balle_y  ;
	pos_palette_1_out <= pos_palette_1;
	pos_palette_2_out <= pos_palette_2;
	
	controleur_de_vitesse : entity work.generateur_d_impulsion
	generic map(
		freq_in  => freq_carte,
		freq_out => freq_deplacement
	)
	port map(
		clk_in  => clk           ,
		resetn  => resetn        ,
		enable  => '1'            ,
		clk_out	=> enable_vitesse
	);
	
	controleur_de_balle : entity work.control_balle
	generic map(
		HORIZONTAL_RESOLUTION => HORIZONTAL_RESOLUTION,
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION  ,
		POS_CURSEUR_X          => OFFSET_CURSEUR_X      ,
		LONGUEUR_PALETTE       => LONGUEUR_PALETTE      ,
		LARGEUR_PALETTE        => LARGEUR_PALETTE
	)
	port map(
		clk           => clk          ,
		resetn        => resetn       ,
		etat_balle    => etat_balle   ,
		
		pos_balle_x   => pos_balle_x  ,
		pos_balle_y   => pos_balle_y  ,
		pos_palette_1 => pos_palette_1,
		pos_palette_2 => pos_palette_2,
		but_J1        => but_J1       ,
		but_J2        => but_J2       
	);
	but <= '1' when but_J1 = '1' or but_J2 = '1' else '0';
	
	position_balle : entity work.Ball
	generic map(
		HORIZONTAL_RESOLUTION => HORIZONTAL_RESOLUTION,
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION  
	)
	port map(
		clk            => clk           ,
		resetn         => resetn        ,
		
		enable_vitesse => enable_vitesse,
		etat_balle     => etat_balle    ,
		but            => but           ,
		pos_x          => pos_balle_x   ,
		pos_y          => pos_balle_y         
	);
	
	position_palette_J1 : entity work.palette
	generic map(  
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION,
		LONGUEUR_PALETTE      => LONGUEUR_PALETTE
	)
	port map(
		clk              => clk           ,
		resetn           => resetn        ,
		
		commande         => control_J1 	  ,
		enable_vitesse   => enable_vitesse,
		
		position_curseur => pos_palette_1
	);
	
	position_palette_J2 : entity work.palette
	generic map(  
		VERTICAL_RESOLUTION   => VERTICAL_RESOLUTION,
		LONGUEUR_PALETTE      => LONGUEUR_PALETTE
	)
	port map(
		clk              => clk           ,
		resetn           => resetn        ,
		
		commande         => control_J2 	  ,
		enable_vitesse   => enable_vitesse,
		
		position_curseur => pos_palette_2
	);
	
	compteur_score_J1 : entity work.Compteur_Score
	generic map(
		SCORE_MAX  => SCORE_MAX 
	)
	port map(
		clk     => clk    ,
		resetn  => resetn ,
		--entrées
		but     => but_J1 ,
		newGame => '0',
		--sortie
		score   => score_J1  
	);
	
	compteur_score_J2 : entity work.Compteur_Score
	generic map(
		SCORE_MAX  => SCORE_MAX 
	)
	port map(
		clk     => clk    ,
		resetn  => resetn ,
		--entrées
		but     => but_J2 ,
		newGame => '0',
		--sortie
		score   => score_J2  
	);
	
end architecture;