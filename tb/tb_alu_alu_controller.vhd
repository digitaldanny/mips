library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This testbench determines whether the ALU works correctly with
-- the alu controller component.

-- Author		: Daniel Hamilton
-- Creation 	: 3/29/2019
-- Last Edit 	: 3/29/2019

-- UPDATES
-- 3/29/2019	: Testbench initialization. 

entity TB_ALU_ALU_CONTROLLER is
end TB_ALU_ALU_CONTROLLER;

architecture TB of TB_ALU_ALU_CONTROLLER is
	
	constant WIDTH : positive := 32;
	
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
		
	process
	begin
		
		-- initialize all input signals
		a <= std_logic_vector(to_unsigned(15, WIDTH));
		b <= std_logic_vector(to_unsigned(5, WIDTH));
		ir_shift <= (others => '0');
		
		-- REGISTER INSTRUCTION OP CODE ==================================
		op_code <= (others => '0');
		
		-- ADD
		ir_r_type <= "100001";
		wait for 10 ns;
		
		-- SUB
		ir_r_type <= "100011";
		wait for 10 ns;
		
		-- MULT UNSIGNED
		ir_r_type <= "011001";
		wait for 10 ns;
		
		-- MULT SIGNED
		a <= std_logic_vector(to_signed(-15, WIDTH));
		b <= std_logic_vector(to_unsigned(5, WIDTH));
		ir_r_type <= "011000";
		wait for 10 ns;
		
		-- LOGICAL AND
		a <= std_logic_vector(to_unsigned(5, WIDTH));
		b <= std_logic_vector(to_unsigned(13, WIDTH));
		ir_r_type <= "100100";
		wait for 10 ns;
		
		-- LOGICAL OR
		ir_r_type <= "100101";
		wait for 10 ns;
		
		-- LOGICAL XOR
		ir_r_type <= "100110";
		wait for 10 ns;
		
		-- SHIFT RIGHT LOGICAL
		b <= std_logic_vector(to_unsigned(5, WIDTH));
		ir_r_type <= "000010";
		ir_shift <= "00001";
		wait for 10 ns;
		
		-- SHIFT LEFT LOGICAL
		ir_r_type <= "000000";
		wait for 10 ns;
		
		-- SHIFT RIGHT ARITHMETIC
		ir_r_type <= "000011";
		b <= std_logic_vector(to_signed(-10, WIDTH));
		wait for 10 ns;
		
		-- SET ON LESS THAN (1)
		a <= std_logic_vector(to_signed(-10, WIDTH));
		b <= std_logic_vector(to_signed(10, WIDTH));
		ir_r_type <= "101010";
		wait for 10 ns;
		
		-- SET ON LESS THAN (2)
		a <= std_logic_vector(to_signed(10, WIDTH));
		b <= std_logic_vector(to_signed(10, WIDTH));
		ir_r_type <= "101010";
		wait for 10 ns;
		
		-- SET ON LESS THAN (3)
		a <= std_logic_vector(to_signed(15, WIDTH));
		b <= std_logic_vector(to_signed(10, WIDTH));
		ir_r_type <= "101010";
		wait for 10 ns;
		
		-- SET ON LESS THAN UNSIGNED (1)
		a <= std_logic_vector(to_unsigned(10,WIDTH));
		b <= std_logic_vector(to_unsigned(15,WIDTH));
		ir_r_type <= "101011";
		wait for 10 ns;
		
		-- SET ON LESS THAN UNSIGNED (2)
		a <= std_logic_vector(to_unsigned(15,WIDTH));
		b <= std_logic_vector(to_unsigned(15,WIDTH));
		ir_r_type <= "101011";
		wait for 10 ns;
		
		-- SET ON LESS THAN UNSIGNED (3)
		a <= std_logic_vector(to_unsigned(20,WIDTH));
		b <= std_logic_vector(to_unsigned(15,WIDTH));
		ir_r_type <= "101011";
		wait for 10 ns;
		
		-- JUMP REGISTER TEST
		ir_r_type <= "001000";
		wait for 10 ns;
		
		wait;
		
	end process;
	
end TB;