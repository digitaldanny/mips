library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Author		: Daniel Hamilton
-- Creation 	: 4/2/2019
-- Last Edit 	: 4/2/2019

-- ==========================================================
-- This testbench determines whether the sign extended 
-- component will convert signed 16 bit number into 
-- a signed 32 bit number.
-- ==========================================================

-- ==========================================================
-- UPDATES
-- 4/2/2019	: Testbench initialization.
-- ========================================================== 

entity TB_SIGN_EXTENDED is
end TB_SIGN_EXTENDED;

architecture TB of TB_SIGN_EXTENDED is
	signal input : std_logic_vector(15 downto 0);
	signal output : std_logic_vector(31 downto 0);
begin
	
	UUT : entity work.sign_extended
		port map(
			input  => input,
			output => output
		);
	
	process
	begin
		
		-- output should be X"00007FFF"
		input <= X"7FFF";
		wait for 10 ns;
		
		-- output should be X"FFFFFFFF"
		input <= X"FFFF";
		wait for 10 ns;
		
		wait;
		
	end process;
	
end TB;