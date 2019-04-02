library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component concatenates PC[31 - 28] and
-- instruction register value IR[27 - 0] to be
-- sent back to PC.

-- Author		: Daniel Hamilton
-- Creation 	: 4/2/2019
-- Last Edit 	: 4/2/2019

-- UPDATES
-- 4/2/2019	: Component initialization. 

entity CONCAT is
	port (
		input 	: in std_logic_vector(27 downto 0);
		pc 	  	: in std_logic_vector(31 downto 28);
		output 	: out std_logic_vector(31 downto 0)
	);
end CONCAT;

architecture BHV of CONCAT is
begin
	
	output <= pc & input;
	
end BHV;