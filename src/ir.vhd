library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mips_lib.all;

-- This instruction register component sends out slices of
-- the mips instruction to the correct components of the 
-- cpu.

-- Author		: Daniel Hamilton
-- Creation 	: 4/1/2019
-- Last Edit 	: 4/1/2019

-- UPDATES
-- 3/29/2019	: Component initialization. 

entity IR is
	generic (
		WIDTH : positive := 32
	);
	port (
		-- inputs
		clk			: in std_logic;
		rst			: in std_logic;
		ir_write 	: in std_logic;
		data 		: in std_logic_vector(WIDTH-1 downto 0);	
		
		-- outputs
		out_25_0 	: out std_logic_vector(25 downto 0);
		out_31_26 	: out std_logic_vector(5 downto 0);
		out_25_21 	: out std_logic_vector(4 downto 0);
		out_20_16	: out std_logic_vector(4 downto 0);
		out_15_11	: out std_logic_vector(4 downto 0);
		out_15_0	: out std_logic_vector(15 downto 0)
	);
end IR;

architecture BHV of IR is
	signal output : std_logic_vector(WIDTH-1 downto 0);
begin
	
	U_REG	: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => ir_write,
			input  => data,
			output => output
		);
	
	-- break out all signal slices
	out_25_0 	<= output(25 downto 0);
	out_31_26 	<= output(31 downto 26);
	out_25_21	<= output(25 downto 21);
	out_20_16	<= output(20 downto 16);
	out_15_11	<= output(15 downto 11);
	out_15_0	<= output(15 downto 0);
	
end BHV;