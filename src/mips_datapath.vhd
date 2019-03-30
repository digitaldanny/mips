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
		clk			: in std_logic;
		rst 		: in std_logic;
		in_port_sel : in std_logic;	-- select between port_in_0 and port_in_1
		in_port_x 	: in std_logic_vector(WIDTH-1 downto 0);
		out_port 	: out std_logic_vector(WIDTH-1 downto 0)
	);
end MIPS_DATAPATH;

architecture STR of MIPS_DATAPATH is
	
	constant C4	: std_logic_vector(WIDTH-1 downto 0) := std_logic_vector(to_unsigned(4, WIDTH));
	constant C0	: std_logic_vector(WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, WIDTH));
	
	---------------- ALU SIGNALS ------------------
	signal a 			: std_logic_vector( WIDTH-1 downto 0 );
	signal b 			: std_logic_vector( WIDTH-1 downto 0 );
	signal ir_shift 	: std_logic_vector( 4 downto 0 );		-- number of times to shift, bits IR(10 downto 6)
	signal branch_taken : std_logic;
	signal result 		: std_logic_vector( WIDTH-1 downto 0 );
	
	--------- ALU + ALU CONTROLLER SIGNALS --------
	signal op_select 	: std_logic_vector(5 downto 0);
	
	----------- ALU CONTROLLER SIGNALS ------------
	signal ir_r_type 	: std_logic_vector(5 downto 0);	-- IR(5 downto 0) for opcodes of 0x00
	signal op_code	 	: std_logic_vector(5 downto 0);
	signal hi_en	 	: std_logic;
	signal lo_en	 	: std_logic;
	signal alu_lo_hi 	: std_logic_vector(1 downto 0);
	
	--------------- REGISTER A SIGNALS -------------
	signal reg_a_in		: std_logic_vector(WIDTH-1 downto 0);
	signal reg_a_out	: std_logic_vector(WIDTH-1 downto 0);
	
	--------------- REGISTER B SIGNALS -------------
	signal reg_b_in		: std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_out	: std_logic_vector(WIDTH-1 downto 0);
	
	------------ REGISTER ALU OUT SIGNALS ----------
	signal reg_alu_out	: std_logic_vector(WIDTH-1 downto 0);
	
	-------------- REGISTER LO SIGNALS -------------
	signal reg_lo_out	: std_logic_vector(WIDTH-1 downto 0);
	
	-------------- REGISTER HI SIGNALS -------------
	signal reg_hi_out	: std_logic_vector(WIDTH-1 downto 0);
	
	--------------- ALU MUX A SIGNALS --------------
	signal mux_a_sel	: std_logic;
	signal in_pc		: std_logic_vector(WIDTH-1 downto 0);
	signal in_reg_a		: std_logic_vector(WIDTH-1 downto 0);
	
	--------------- ALU MUX B SIGNALS --------------
	signal mux_b_sel	: std_logic_vector(1 downto 0);
	signal in_reg_b		: std_logic_vector(WIDTH-1 downto 0);
	signal in_imm		: std_logic_vector(WIDTH-1 downto 0);
	signal in_imm_shift : std_logic_vector(WIDTH-1 downto 0);
	
	-------------- ALU OUT MUX SIGNALS -------------
	signal mux_alu_out_sel : std_logic_vector(1 downto 0);
	signal mux_alu_out_out : std_logic_vector(WIDTH-1 downto 0);
	
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
			result       => result
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
	
	U_REG_A	: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			input  => reg_a_in,
			output => reg_a_out
		);
		
	U_REG_B : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			input  => reg_b_in,
			output => reg_b_out
		);
		
	U_REG_ALU_OUT : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			input  => result(WIDTH-1 downto 0),
			output => reg_alu_out
		);
		
	U_REG_LO : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			input  => result(WIDTH-1 downto 0),
			output => reg_lo_out
		);
		
	U_REG_HI : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			input  => result(2*WIDTH-1 downto WIDTH),
			output => reg_hi_out
		);
		
	U_MUX_A : entity work.mux_2x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => mux_a_sel,
			a      => in_pc,
			b      => in_reg_a,
			output => a	-- to the alu
		);
		
	U_MUX_B	: entity work.mux_4x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => mux_b_sel,
			a      => in_reg_b,
			b      => C4, 	-- for addressing
			c      => in_imm,
			d      => in_imm_shift,
			output => b 	-- to the alu
		);
		
	U_MUX_ALU_OUT : entity work.mux_4x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => mux_alu_out_sel,
			a      => reg_alu_out,
			b      => reg_lo_out,
			c      => reg_hi_out,
			d      => C0,
			output => mux_alu_out_out
		);
	
end STR;