library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component tests how the CPU controller and the CPU datapath 
-- communicate with each other and if they perform the correct operations.

-- Author		: Daniel Hamilton
-- Creation 	: 4/14/2019
-- Last Edit 	: 4/14/2019

-- UPDATES
-- 4/14/2019	: Component initialization. 

entity TB_MIPS_TOP_LEVEL is
end TB_MIPS_TOP_LEVEL;

architecture STR of TB_MIPS_TOP_LEVEL is
	
	constant WIDTH : integer := 32;
	signal clk			: std_logic;
	signal rst			: std_logic;
	signal in_port_sel 	: std_logic;
	signal in_port     	: std_logic_vector(WIDTH-1 downto 0);
	signal out_port    	: std_logic_vector(WIDTH-1 downto 0);
	
begin	
	
	U_MIPS : entity work.MIPS_TOP_LEVEL
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk			=> clk,
			rst			=> rst,
			in_port_sel => in_port_sel,
			in_port     => in_port,
			out_port    => out_port
		);
		
	-- Test if fetch instructions works by feeding clock
	-- cycles. Next instruction from the MIF file should 
	-- go into the Instruction Register and the PC value
	-- should be incremented.
	process
	begin
		
		rst <= '1';
		clk <= '0';
		wait for 20 ns;
		rst <= '0';
		
		for i in 1 to 10000 loop
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
		
		in_port_sel <= '0';
		in_port    	<= (others => '0');
		
	end process;
	
end STR;