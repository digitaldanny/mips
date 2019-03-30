library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- All muxes used in the MIPS architecture are either
-- 2x1 muxes or 4x1 muxes. This file contains both
-- entities and architectures.

-- Author		: Daniel Hamilton
-- Creation 	: 3/29/2019
-- Last Edit 	: 3/29/2019

-- UPDATES
-- 3/29/2019	: Component initialization.

entity mux_2x1 is
	generic (
		WIDTH : positive := 32
	);
	port (
		sel 	: in std_logic;
		a		: in std_logic_vector(WIDTH-1 downto 0);
		b 		: in std_logic_vector(WIDTH-1 downto 0);
		output 	: out std_logic_vector(WIDTH-1 downto 0)
	);
end mux_2x1;

architecture BHV of mux_2x1 is
begin
	
	process(sel, a, b)
	begin
		
		if (sel = '0') then
			output <= a;
		else
			output <= b;
		end if;
		
	end process;
	
end BHV;

--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_4x1 is
	generic (
		WIDTH : positive := 32
	);
	port (
		sel 	: in 	std_logic_vector(1 downto 0);
		a 		: in 	std_logic_vector(WIDTH-1 downto 0);
		b 		: in 	std_logic_vector(WIDTH-1 downto 0);
		c		: in	std_logic_vector(WIDTH-1 downto 0);
		d		: in	std_logic_vector(WIDTH-1 downto 0);
		output 	: out 	std_logic_vector(WIDTH-1 downto 0)
	);
end mux_4x1;

architecture BHV of mux_4x1 is
begin
	
	process( sel, a, b, c, d )
	begin
		case SEL is
		when "00" =>
			output <= a;
		when "01" =>
			output <= b;
		when "10" =>
			output <= c;
		when "11" =>
			output <= d;
		when others => null;
		end case;
	end process;
	
end BHV;


