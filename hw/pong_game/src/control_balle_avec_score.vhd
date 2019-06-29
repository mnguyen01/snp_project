library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity control_balle is
	generic (
		HORIZONTAL_RESOLUTION  : natural := 640;
		VERTICAL_RESOLUTION    : natural := 480;
		POS_CURSEUR_X          : natural := 5;
		LONGUEUR_PALETTE       : natural := 50;
		LARGEUR_PALETTE        : natural := 5
	);
	port( 
		clk           : in  std_logic;
		resetn        : in  std_logic;
		
		etat_balle    : out std_logic_vector(1 downto 0); --la balle se déplace en : "00" haut à droite ; "01" bas à droite ; "10" bas à gauche ; "11" haut à gauche
		-- environnement (tout ce qui peut modifier le comportement de la balle)
		--Replay        : in  std_logic; --rejouer une partie (pas une manche).
		pos_balle_x   : in  std_logic_vector(natural(ceil(log2(real(HORIZONTAL_RESOLUTION-1))))-1 downto 0); --position de la balle en x
		pos_balle_y   : in  std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0); --position de la balle en y
		pos_palette_1 : in  std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0); --position du curseur J1
		pos_palette_2 : in  std_logic_vector(natural(ceil(log2(real(VERTICAL_RESOLUTION  -1))))-1 downto 0); --position du curseur J2
		-- sorties
		but_J1        : out std_logic; --pour reinitialiser la position de la balle.
		but_J2        : out std_logic --pour reinitialiser la position de la balle.
	);

end entity;

architecture fsm of control_balle is
signal signal_pos_balle_x   : unsigned(pos_balle_x  'range);
signal signal_pos_balle_y   : unsigned(pos_balle_y  'range);
signal signal_pos_palette_1 : unsigned(pos_palette_1'range);
signal signal_pos_palette_2 : unsigned(pos_palette_2'range);
type etat is (HD, BD, BG, HG);
signal  present, futur : etat;
signal rebond_palette_d, rebond_palette_g, rebond_bord_d, rebond_bord_g, rebond_bord_h, rebond_bord_b : std_logic; 
begin

	signal_pos_balle_x   <= unsigned(pos_balle_x  );
    signal_pos_balle_y   <= unsigned(pos_balle_y  );
    signal_pos_palette_1 <= unsigned(pos_palette_1);
    signal_pos_palette_2 <= unsigned(pos_palette_2);
	
	registre_etat : process(clk, resetn) is
	begin
		if resetn = '0' then
			present <= HD;
		elsif 
			rising_edge(clk) then present <= futur;
		end if;
	end process registre_etat;
	
	rebond_palette_d <= '1' when (signal_pos_balle_x = to_unsigned(HORIZONTAL_RESOLUTION-POS_CURSEUR_X-LARGEUR_PALETTE/2, signal_pos_balle_x'length)) and (signal_pos_balle_y >= signal_pos_palette_2-to_unsigned(LONGUEUR_PALETTE/2, signal_pos_palette_2'length)) and (signal_pos_balle_y <= signal_pos_palette_2+to_unsigned(LONGUEUR_PALETTE/2, signal_pos_palette_2'length)) 
	               else '0';
	rebond_palette_g <= '1' when (signal_pos_balle_x = to_unsigned(POS_CURSEUR_X+LARGEUR_PALETTE/2, signal_pos_balle_x'length))                        and (signal_pos_balle_y >= signal_pos_palette_1-to_unsigned(LONGUEUR_PALETTE/2, signal_pos_palette_1'length)) and (signal_pos_balle_y <= signal_pos_palette_1+to_unsigned(LONGUEUR_PALETTE/2, signal_pos_palette_1'length))
				   else '0';
	rebond_bord_d <= '1' when signal_pos_balle_x >= to_unsigned(HORIZONTAL_RESOLUTION, signal_pos_balle_x'length) else '0';
	rebond_bord_g <= '1' when signal_pos_balle_x =  to_unsigned(0                     , signal_pos_balle_x'length) else '0';
	rebond_bord_h <= '1' when signal_pos_balle_y =  to_unsigned(0                     , signal_pos_balle_y'length) else '0';
	rebond_bord_b <= '1' when signal_pos_balle_y >= to_unsigned(VERTICAL_RESOLUTION  , signal_pos_balle_y'length) else '0';

	combinatoire : process(present, rebond_palette_d, rebond_palette_g, rebond_bord_d, rebond_bord_g, rebond_bord_h, rebond_bord_b) is -- FSM
	begin
		futur <= present;
		but_J1 <= '0';
		but_J2 <= '0';

	case present is 
	------------------------------------------------------------------------------------------------------------------------------------
		when HD =>								-- etat initial de la balle
			if rebond_bord_h = '1' then 
				futur <= BD; 
			elsif rebond_palette_d = '1' then
				futur <= HG;
			elsif rebond_bord_d = '1' then
				futur <= HG;
				but_J1 <= '1';
			end if ;
			etat_balle <= "00";
	------------------------------------------------------------------------------------------------------------------------------------
		when BD =>
			if rebond_bord_b = '1' then 
				futur <= HD; 
			elsif rebond_palette_d = '1' then
				futur <= BG;
			elsif rebond_bord_d = '1' then
				futur <= BG;
				but_J1 <= '1';
			end if ;
			etat_balle <= "01";
	------------------------------------------------------------------------------------------------------------------------------------
		when BG =>
			if rebond_bord_b = '1' then 
				futur <= HG; 
			elsif rebond_palette_g = '1' then
				futur <= BD;
			elsif rebond_bord_g = '1' then
				futur <= BD;
				but_J2 <= '1';
			end if ;
			etat_balle <= "10";
	------------------------------------------------------------------------------------------------------------------------------------
		when HG =>
			if rebond_bord_h = '1' then 
				futur <= BG;
			elsif rebond_palette_g = '1' then
				futur <= HD;
			elsif rebond_bord_g = '1' then
				futur <= HD;
				but_J2 <= '1';
			end if;
			etat_balle <= "11";
		end case ;
	end process ; 
end architecture;