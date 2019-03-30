library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This entity contains the datapath for the MIPS FSM+D. 
-- All non-controller CPU structures connect here.

-- Author		: Daniel Hamilton
-- Creation 	: 3/29/2019
-- Last Edit 	: 3/29/2019

-- UPDATES
-- 3/29/2019	: Component initialization. 

entity MIPS_DATAPATH is
	generic (
		WIDTH : positive := 32
	);
	port (
		-- controller IO ----------------------------------
		
		-- non controller IO ------------------------------
		in_port_sel : in std_logic;	-- select between port_in_0 and port_in_1
		in_port_x 	: in std_logic_vector(WIDTH-1 downto 0);
		out_port 	: out std_logic_vector(WIDTH-1 downto 0)
	);
end MIPS_DATAPATH;

architecture STR of MIPS_DATAPATH is
	
	---------------- ALU SIGNALS ------------------
	signal a 			: std_logic_vector( WIDTH-1 downto 0 );
	signal b 			: std_logic_vector( WIDTH-1 downto 0 );
	signal ir_shift 	: std_logic_vector( 4 downto 0 );		-- number of times to shift, bits IR(10 downto 6)
	signal branch_taken : std_logic;
	signal result 		: std_logic_vector( WIDTH-1 downto 0 );
	signal result_hi	: std_logic_vector( WIDTH-1 downto 0 );
	
	--------- ALU + ALU CONTROLLER SIGNALS --------
	signal op_select 	: std_logic_vector(5 downto 0);
	
	----------- ALU CONTROLLER SIGNALS ------------
	signal ir_r_type 	: std_logic_vector(5 downto 0);	-- IR(5 downto 0) for opcodes of 0x00
	signal op_code	 	: std_logic_vector(5 downto 0);
	signal hi_en	 	: std_logic;
	signal lo_en	 	: std_logic;
	signal alu_lo_hi 	: std_logic_vector(1 downto 0);
	
begin
	
	U_ALU : entity work.ALU
		generic map( 
			IN_WIDTH => WIDTH,
			WIDTH => WIDTH
		)
		port map(
			a            => a,
			b            => b,
			ir_shift     => ir_shift,
			op_select    => op_select,
			branch_taken => branch_taken,
			result       => result,
			result_hi	 => result_hi
		);
		
	U_ALU_CONTROLLER : entity work.ALU_CONTROLLER
		port map(
			ir_r_type => ir_r_type,
			op_code   => op_code,
			op_select => op_select,
			hi_en     => hi_en,
			lo_en     => lo_en,
			alu_lo_hi => alu_lo_hi
		);
	
end STR;