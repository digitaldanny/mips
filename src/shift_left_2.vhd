library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component shifts 26 bit number to the
-- left by 2 bits and outputs 28 bit number. 
-- To be used to simplify datapath.

-- Author		: Daniel Hamilton
-- Creation 	: 4/2/2019
-- Last Edit 	: 4/2/2019

-- UPDATES
-- 4/2/2019	: Component initialization. 

entity SHIFT_LEFT_2_26 is
	port (
		input : in std_logic_vector(25 downto 0);
		output : out std_logic_vector(27 downto 0)
	);
end SHIFT_LEFT_2_26;

architecture BHV of SHIFT_LEFT_2_26 is
begin
	
	output <= input & "00";
	
end BHV;

-- This component shifts 32 bit number to the
-- left by 2 bits and outputs 32 bit number. 
-- To be used to simplify datapath.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SHIFT_LEFT_2_32 is
	port (
		input : in std_logic_vector(31 downto 0);
		output : out std_logic_vector(31 downto 0)
	);
end SHIFT_LEFT_2_32;

architecture BHV of SHIFT_LEFT_2_32 is
begin
	
	output <= input(29 downto 0) & "00";
	
end BHV;