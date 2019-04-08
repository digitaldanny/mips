library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mips_lib.all;

-- This testbench determines whether the ALU works correctly for
-- the following calculations.

-- TESTBENCH PROCEDURE:
-- 10 + 15
-- 25 - 10
-- 10 * -4
-- 65536 * 131072
-- 0x0000FFFF AND 0xFFFF1234
-- 0x0000000F >> 4
-- SRA 0xF0000008 >> 1
-- SRA 0x00000008 >> 1
-- SLT 10, 15
-- SLT 15, 10
-- Branch taken = 0 for 5 <= 0
-- Branch taken = 1 for 5 > 0

-- Author		: Daniel Hamilton
-- Creation 	: 4/8/2019

-- UPDATES
-- 4/8/2019	: Testbench initialization. 

entity TB_ALU is
end TB_ALU;

architecture TB of TB_ALU is
	
	constant WIDTH : positive := 32;
	
	---------------- ALU SIGNALS ------------------
	signal a 			: std_logic_vector( WIDTH-1 downto 0 );
	signal b 			: std_logic_vector( WIDTH-1 downto 0 );
	signal ir_shift 	: std_logic_vector( 4 downto 0 );		-- number of times to shift, bits IR(10 downto 6)
	signal branch_taken : std_logic;
	signal result 		: std_logic_vector( WIDTH-1 downto 0 );
	signal result_hi	: std_logic_vector( WIDTH-1 downto 0 );
	signal op_select 	: std_logic_vector(5 downto 0);
	signal op_select_var : integer;
	
begin
	
	U_ALU : entity work.ALU
		generic map(
			WIDTH    => WIDTH,
			IN_WIDTH => WIDTH
		)
		port map(
			a            => a,
			b            => b,
			ir_shift     => ir_shift,
			op_select    => op_select,
			branch_taken => branch_taken,
			result       => result,
			result_hi    => result_hi
		);
		
	process
	begin
		
		-- initialize all input signals
		ir_shift <= (others => '0');
		
		-- OP CODE SELECT INSTRUCTION --------------------------
		
		-- 10 + 15 -----------------------------------
		a <= std_logic_vector(to_unsigned(10, WIDTH));
		b <= std_logic_vector(to_unsigned(15, WIDTH));
		OP_SELECT_VAR <= ALU_ADD;
		wait for 10 ns;		
		
		-- 25 - 10 ------------------------------------
		a <= std_logic_vector(to_unsigned(25, WIDTH));
		b <= std_logic_vector(to_unsigned(10, WIDTH));
		OP_SELECT_VAR <= ALU_SUB;
		wait for 10 ns;
		
		-- 10 * -4 ------------------------------------
		a <= std_logic_vector(to_signed(10, WIDTH));
		b <= std_logic_vector(to_signed(-4, WIDTH));
		OP_SELECT_VAR <= ALU_MULT;
		wait for 10 ns;
		
		-- 65536 * 131072 -----------------------------
		a <= std_logic_vector(to_unsigned(65536, WIDTH));
		b <= std_logic_vector(to_unsigned(131072, WIDTH));
		OP_SELECT_VAR <= ALU_MULTU;
		wait for 10 ns;
		
		-- 0x0000FFFF AND 0xFFFF1234 -------------------
		a <= X"0000FFFF";
		b <= X"FFFF1234";
		OP_SELECT_VAR <= ALU_AND;
		wait for 10 ns;
		
		-- SLR 0x0000000F >> 4 ------------------------------
		a <= X"00000000";
		b <= X"0000000F";
		ir_shift <= std_logic_vector(to_unsigned(4, 5));
		OP_SELECT_VAR <= ALU_SRL;
		wait for 10 ns;
		
		-- SRA 0xF0000008 >> 1
		a <= X"00000000";
		b <= X"F0000008";
		ir_shift <= std_logic_vector(to_unsigned(1, 5));
		OP_SELECT_VAR <= ALU_SRA;
		wait for 10 ns;
				
		-- SRA 0x00000008 >> 1
		a <= X"00000000";
		b <= X"00000008";
		ir_shift <= std_logic_vector(to_unsigned(1, 5));
		OP_SELECT_VAR <= ALU_SRA;
		wait for 10 ns;
		
		-- SLT 10, 15
		a <= std_logic_vector(to_unsigned(10, WIDTH));
		b <= std_logic_vector(to_unsigned(15, WIDTH));
		ir_shift <= std_logic_vector(to_unsigned(0, 5));
		OP_SELECT_VAR <= ALU_SLT;
		wait for 10 ns;
				
		-- SLT 15, 10
		a <= std_logic_vector(to_unsigned(15, WIDTH));
		b <= std_logic_vector(to_unsigned(10, WIDTH));
		ir_shift <= std_logic_vector(to_unsigned(0, 5));
		OP_SELECT_VAR <= ALU_SLT;
		wait for 10 ns;
		
		-- Branch taken = 0 for 5 <= 0
		a <= std_logic_vector(to_unsigned(5, WIDTH));
		b <= std_logic_vector(to_unsigned(0, WIDTH));
		OP_SELECT_VAR <= ALU_BLEZ;
		wait for 10 ns;		
		
		-- Branch taken = 1 for 5 > 0
		a <= std_logic_vector(to_unsigned(5, WIDTH));
		b <= std_logic_vector(to_unsigned(0, WIDTH));
		OP_SELECT_VAR <= ALU_BGTZ;
		wait for 10 ns;		
		
		wait;
		
	end process;
	
	op_select <= std_logic_vector(to_unsigned(OP_SELECT_VAR, 6));
	
end TB;