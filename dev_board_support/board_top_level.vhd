library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- dev board top level allows user to pick
-- appropriate architecture based on which dev
-- board the design is being implemented on. 
-- The user can also make board specific adjustments
-- within this layer of abstraction.
entity board_top_level is
    port (
        clk50MHz 	: in std_logic;
        buttons	 	: in std_logic_vector(1 downto 0);
        switches	: in std_logic_vector(9 downto 0);
      	
      	led0     : out std_logic_vector(6 downto 0);
        led0_dp  : out std_logic;
        led1     : out std_logic_vector(6 downto 0);
        led1_dp  : out std_logic;
        led2     : out std_logic_vector(6 downto 0);
        led2_dp  : out std_logic;
        led3     : out std_logic_vector(6 downto 0);
        led3_dp  : out std_logic;
        led4     : out std_logic_vector(6 downto 0);
        led4_dp  : out std_logic;
        led5     : out std_logic_vector(6 downto 0);
        led5_dp  : out std_logic
        );
end board_top_level;

architecture STR of board_top_level is
	
	signal rst 				: std_logic;
	signal in_port_en 		: std_logic;	-- user_in_port_wr_en in lower abstractions
	signal in_port_sel		: std_logic;	-- user_in_port_en  in lower abstractions
	signal in_port_data		: std_logic_vector(31 downto 0);
	signal out_port_data	: std_logic_vector(31 downto 0);
	
begin
	
	---------------------- SIGNAL ASSIGNEMNTS -------------------------
	rst 			<= not(buttons(1));
	in_port_en 		<= not(buttons(0));
	in_port_sel 	<= switches(9);
	in_port_data 	<= "00000000000000000000000" & switches(8 downto 0);
	
	------------------------ MAIN ENTITIES ----------------------------
	U_TOP_LEVEL_MIPS : entity work.MIPS_TOP_LEVEL
		generic map(
			WIDTH => 32
		)
		port map(
			clk         => clk50MHz,
			rst         => rst,
			in_port_en  => in_port_en,
			in_port_sel => in_port_sel,
			in_port     => in_port_data,
			out_port    => out_port_data
		);
		
	------------------------ OUTPUT ENTITIES --------------------------
	U_LED_0 : entity work.decoder7seg
		port map(
			input  => out_port_data(3 downto 0),
			output => led0
		);
		
	U_LED_1 : entity work.decoder7seg
		port map(
			input  => out_port_data(7 downto 4),
			output => led1
		);
		
	U_LED_2 : entity work.decoder7seg
		port map(
			input  => out_port_data(11 downto 8),
			output => led2
		);
		
	U_LED_3 : entity work.decoder7seg
		port map(
			input  => out_port_data(15 downto 12),
			output => led3
		);
	
	U_LED_4 : entity work.decoder7seg
		port map(
			input  => out_port_data(19 downto 16),
			output => led4
		);
		
	U_LED_5 : entity work.decoder7seg
		port map(
			input  => out_port_data(23 downto 20),
			output => led5
		);
	
	led0_dp  <= '1';
	led1_dp  <= '1';
	led2_dp  <= '1';
	led3_dp  <= '1';
	led4_dp  <= '1';
	led5_dp  <= '1';
	
end STR;