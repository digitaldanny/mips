library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component converts a 16 bit input
-- into a sign extended 32 bit output.

-- Author		: Daniel Hamilton
-- Creation 	: 4/2/2019
-- Last Edit 	: 4/2/2019

-- UPDATES
-- 4/2/2019	: Component initialization. 


entity sign_extended is
    port(
    	input 	: in std_logic_vector(15 downto 0);
    	output 	: out std_logic_vector(31 downto 0)
    );
end sign_extended;

architecture BHV of sign_extended is
begin
	
	process (input)
	begin
		
		if ( input(15) = '1' ) then
			output <= X"FFFF" & input; -- negative sign extend
		else
			output <= X"0000" & input; -- positive sign extend
		end if;
		
	end process;
 
end BHV;