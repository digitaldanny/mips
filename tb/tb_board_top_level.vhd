library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This testbench allows the CPU to run the GCD program stored on 
-- the RAM and tests that the user can load in any new values to 
-- be compared.

-- Author		: Daniel Hamilton
-- Creation 	: 4/14/2019
-- Last Edit 	: 4/14/2019

-- UPDATES
-- 4/14/2019	: Component initialization. 

entity TB_BOARD_TOP_LEVEL is
end TB_BOARD_TOP_LEVEL;

architecture STR of TB_BOARD_TOP_LEVEL is
	
	constant WIDTH : integer := 32;
	signal clk			: std_logic := '0';
	signal rst			: std_logic;
	signal in_port_sel 	: std_logic;
	signal in_port     	: std_logic_vector(WIDTH-1 downto 0);
	signal in_port_en	: std_logic;
	signal led0         : std_logic_vector(6 downto 0);
	signal led0_dp      : std_logic;
	signal led1         : std_logic_vector(6 downto 0);
	signal led1_dp      : std_logic;
	signal led2         : std_logic_vector(6 downto 0);
	signal led2_dp      : std_logic;
	signal led3         : std_logic_vector(6 downto 0);
	signal led3_dp      : std_logic;
	signal led4         : std_logic_vector(6 downto 0);
	signal led4_dp      : std_logic;
	signal led5         : std_logic_vector(6 downto 0);
	signal led5_dp      : std_logic;
	
    signal buttons	 	: std_logic_vector(1 downto 0);
    signal switches		: std_logic_vector(9 downto 0);	
	
begin	
	
	rst 		<= not(buttons(1));
	in_port_en 	<= not(buttons(0));

	in_port_sel <= switches(9);
	in_port 	<= "00000000000000000000000" & switches(8 downto 0);
	
	U_BOARD : entity work.board_top_level
		port map(
			clk50MHz => clk,
			buttons  => buttons,
			switches => switches,
			led0     => led0,
			led0_dp  => led0_dp,
			led1     => led1,
			led1_dp  => led1_dp,
			led2     => led2,
			led2_dp  => led2_dp,
			led3     => led3,
			led3_dp  => led3_dp,
			led4     => led4,
			led4_dp  => led4_dp,
			led5     => led5,
			led5_dp  => led5_dp
		);
		
	-- Test if fetch instructions works by feeding clock
	-- cycles. Next instruction from the MIF file should 
	-- go into the Instruction Register and the PC value
	-- should be incremented.
	process
	begin
		
		for i in 1 to 50000 loop
			if ( clk = '0' ) then
				clk <= '1';
			else 
				clk <= '0';
			end if;
			wait for 10 ns;
		end loop;
		
		wait;
		
	end process;
	
	process( clk )
		variable count : unsigned(31 downto 0) := X"00000000";
	begin
		if ( rising_edge(clk) ) then
			count := count + to_unsigned(1, 32);
		end if;
		
		if ( count < to_unsigned(50, 32) ) then
			buttons(1) <= '0';	-- reset on
			buttons(0) <= '1';	-- in port enable is off
			switches(9)	<= '0';		-- in port 0 selected
			
		-- LOAD TABLE SIZE
		elsif ( count < to_unsigned(100,32) ) then
			buttons(1) <= '1';	-- reset off
		
			buttons(0)	<= '0'; 	-- in port enable is on
			switches(9)	<= '0';		-- in port 0 selected
			-- switches(8 downto 0) <= "000110001";	-- first value to compare 49
			switches(8 downto 0) <= "000001100";	-- 12
									 
		-- LOAD TABLE VALUE
		elsif ( count < to_unsigned(150,32) ) then
			buttons(1) <= '1';	-- reset off
		
			buttons(0)	<= '0'; 	-- in port enable is on
			switches(9)	<= '1';		-- in port 0 selected
			-- switches(8 downto 0) <= "001100010";	-- second value to compare 49*2
			switches(8 downto 0) <= "000100001";
			
		elsif ( count  < to_unsigned(200, 32) ) then
			buttons(1) <= '0'; -- reset on
			buttons(0) <= '1'; -- in port enable is off
		
		-- RESET THE PROGRAM
		elsif ( count < to_unsigned(200, 32) ) then
			buttons(1) <= '0';	-- reset on
			buttons(0) <= '1';	-- in port enable is off
			switches(9)	<= '0';		-- in port 0 selected
			
		elsif ( count < to_unsigned(250, 32) ) then
			buttons(1) <= '1';	-- reset off
			buttons(0) <= '1';	-- in port enable is off
			
		end if;
		
	end process;
	
end STR;