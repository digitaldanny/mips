library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Author		: Daniel Hamilton
-- Creation 	: 3/29/2019
-- Last Edit 	: 3/29/2019

-- UPDATES
-- 3/29/2019	: Component initialization. 

entity ALU is
	generic (
		WIDTH : positive := 32
	);
	port (
		a 			: in std_logic_vector( WIDTH-1 downto 0 );
		b 			: in std_logic_vector( WIDTH-1 downto 0 );
		ir_shift 	: in std_logic_vector( 4 downto 0 );		-- number of times to shift, bits IR(10 downto 6)
		op_select 	: in std_logic_vector( 5 downto 0 );		-- op code select from the ALU controller
	
		branch_taken : out std_logic;
		result 		 : out std_logic_vector( WIDTH-1 downto 0 )
	);
end ALU;

architecture BHV of ALU is
begin
	
	
end BHV;
	