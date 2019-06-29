---------------------------------------------
-- VGA                                     --
--                                         --
-- BEAU & GUILMONT                         --
--                                         --
-- 23/11/2017                              --
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity VGA is
  generic(
		freq_carte            : positive := 100e6;
		
		HORIZONTAL_RESOLUTION : positive := 640;
		VERTICAL_RESOLUTION   : positive := 480;
		
		Front_porch_h         : positive := 16;
		Sync_pulse_h          : positive := 96;
		Back_porch_h          : positive := 48;
		Front_porch_v         : positive := 10;
		Sync_pulse_v          : positive := 2;
		Back_porch_v          : positive := 33
	);
  port(
    resetn     : in std_logic;
    clk        : in std_logic;
	enable     : in std_logic;
	
	--signaux de commande
    pixel_in   : in  std_logic_vector(7 downto 0);--le pixel à transmettre
	pos_x      : out std_logic_vector( integer(ceil(log2(real(HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h + Back_porch_h)))) - 1 downto 0);
	pos_y      : out std_logic_vector( integer(ceil(log2(real(VERTICAL_RESOLUTION   + Front_porch_v + Sync_pulse_v + Back_porch_v)))) - 1 downto 0);
	
	--Sortie vers le VGA
    Rout_out   : out std_logic_vector(2 downto 0);
    Gout_out   : out std_logic_vector(2 downto 0);
    Bout_out   : out std_logic_vector(1 downto 0);
    Vsync      : out std_logic;
    Hsync      : out std_logic
   );
end entity;

architecture rtl of VGA is
	signal clk_pixel : std_logic;
	signal Hpos : natural range 0 to HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h + Back_porch_h;
	signal Vpos : natural range 0 to VERTICAL_RESOLUTION   + Front_porch_v + Sync_pulse_v + Back_porch_v;
	signal compteur_h : std_logic_vector(9 downto 0);
	signal compteur_v : std_logic_vector(9 downto 0);
	signal fin_ligne : std_logic;
	signal fin_image : std_logic;
    signal Rout : std_logic_vector(2 downto 0);
    signal Gout : std_logic_vector(2 downto 0);
    signal Bout : std_logic_vector(1 downto 0);
	
	signal zone_blanche : std_logic;
	signal signal_next_pixel : std_logic;
begin

	pos_x <= std_logic_vector(to_unsigned(Hpos, pos_x'length));
	pos_y <= std_logic_vector(to_unsigned(Vpos, pos_y'length));

------------------------------
--                          --
--    Génération horloge    --
--                          --
------------------------------
	--Comme tous les timing sur les diagrammes de la doc correspondent à des multiples d'un temps_bit, on décide de travailler à cette fréquence
	--On génère une horloge à la fréquence 1/(Temps_bit)
	horloge_temps_pixel : entity work.generateur_d_impulsion
	generic map(
		freq_in	 => freq_carte,
		freq_out => 25e6--fréquence de l'horloge de sortie (25.175MHz arondit à 25MHz)
	)
	port map(
		clk_in	=> clk,
		clk_out	=> clk_pixel,
		enable  => enable,
		resetn	=> resetn--On démarre cette horloge en même temps que la transmission
	);
	
------------------------------
--                          --
--        Compteurs         --
--                          --
------------------------------
	--On compte le nombre de pixel
	compteur_pix : entity work.compteur_binaire
	generic map(
		N => 10,
		x => HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h + Back_porch_h
	)
	port map(
		clk		 => clk,
		resetn	 => resetn,
		enable   => clk_pixel,
		cptr_out => compteur_h,
		fin_cptr => fin_ligne
	);
	Hpos <= to_integer(unsigned(compteur_h));
	Hsync <= '0' when (Hpos >= HORIZONTAL_RESOLUTION + Front_porch_h) and (Hpos < HORIZONTAL_RESOLUTION + Front_porch_h + Sync_pulse_h) else '1';--Hsync à l'état bas entre le front porch et le back porch
	
	--On compte le nombre de ligne
	compteur_ligne : entity work.compteur_binaire
	generic map(
		N => 10,
		x => VERTICAL_RESOLUTION + Front_porch_v + Sync_pulse_v + Back_porch_v
	)
	port map(
		clk		 => clk,
		resetn	 => resetn,
		enable   => fin_ligne,
		cptr_out => compteur_v,
		fin_cptr => fin_image
	);
	Vpos <= to_integer(unsigned(compteur_v));
	Vsync <= '0' when (Vpos >= VERTICAL_RESOLUTION + Front_porch_v) and (Vpos < VERTICAL_RESOLUTION + Front_porch_v + Sync_pulse_v) else '1';--Hsync à l'état bas entre le front porch et le back porch
	
	

------------------------------
--                          --
--       Transmisson        --
--                          --
------------------------------
	--Met à jour le pixel en sortie et demande le nouveau pixel
	process(clk, resetn) is
	begin
		if resetn = '0' then
			Rout <= (others => '0');
			Gout <= (others => '0');
			Bout <= (others => '0');
		elsif rising_edge(clk) then
			if signal_next_pixel = '1' or enable = '0' then
				Rout <= pixel_in(2 downto 0);
				Gout <= pixel_in(5 downto 3);
				Bout <= pixel_in(7 downto 6);
			end if;
		end if;
	end process;
	Rout_out <= Rout when zone_blanche = '0' else "000";
	Gout_out <= Gout when zone_blanche = '0' else "000";
	Bout_out <= Bout when zone_blanche = '0' else "00";
	zone_blanche <= '1' when (Hpos > HORIZONTAL_RESOLUTION-1) or (Vpos > VERTICAL_RESOLUTION-1) else '0';
	--zone_blanche_out <= zone_blanche;
	signal_next_pixel <= '1' when zone_blanche = '0' and clk_pixel = '1' else '0';
	
end;