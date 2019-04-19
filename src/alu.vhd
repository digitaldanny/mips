library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

-- All computation is handled by this component. Inputs are 
-- selected by the main controller's signals AluSrcA, AluSrcB.
-- Output is controlled by ALU controller signal ALU_LO_HI.

-- Author		: Daniel Hamilton
-- Creation 	: 3/29/2019
-- Last Edit 	: 3/29/2019

-- UPDATES
-- 3/29/2019	: Component initialization.
-- 4/8/2019		: Simplified IF-branches with default signal values in process

-- TODO: Does ALU have anything to do for _MFHI and _MFLO?

entity ALU is
	generic (
		WIDTH 		: positive := 32;
		IN_WIDTH 	: positive := 32
	);
	port (
		a 			: in std_logic_vector( IN_WIDTH-1 downto 0 );  -- rs
		b 			: in std_logic_vector( IN_WIDTH-1 downto 0 );  -- rt
		ir_shift 	: in std_logic_vector( 4 downto 0 );		-- number of times to shift, bits IR(10 downto 6)
		op_select 	: in std_logic_vector( 5 downto 0 );		-- op code select from the ALU controller
	
		branch_taken : out std_logic;
		result 		 : out std_logic_vector( WIDTH-1 downto 0 );
		result_hi	 : out std_logic_vector( WIDTH-1 downto 0 )
	);
end ALU;

architecture BHV of ALU is
	signal result_sig 		: std_logic_vector( 2*WIDTH-1 downto 0 ); -- works with multiply
	signal branch_taken_sig : std_logic;
begin
	
	process( op_select, ir_shift, a, b )
		variable OP_SELECT_VAR 	: integer; -- just to make decoding pretty :)
		variable IR_SHIFT_VAR 	: integer;
		variable SIGNED_A		: signed(IN_WIDTH-1 downto 0);
		variable SIGNED_B		: signed(IN_WIDTH-1 downto 0);
		variable UNSIGNED_A_64	: unsigned(2*IN_WIDTH-1 downto 0);
		variable UNSIGNED_B_64 	: unsigned(2*IN_WIDTH-1 downto 0);
		variable SIGNED_B_64 	: signed(2*IN_WIDTH-1 downto 0);
	begin
		
		-- MUX SELECT PREPARATION
		OP_SELECT_VAR 	:= to_integer(unsigned(OP_SELECT));
		IR_SHIFT_VAR 	:= to_integer(unsigned(IR_SHIFT));
		SIGNED_A 		:= signed(a);
		SIGNED_B 		:= signed(b);
		UNSIGNED_A_64	:= resize(unsigned(a), UNSIGNED_A_64'length);
		UNSIGNED_B_64	:= resize(unsigned(b), UNSIGNED_B_64'length);
		SIGNED_B_64		:= resize(signed(b), UNSIGNED_B_64'length);
		
		-- DEFAULT SIGNAL VALUES
		branch_taken_sig 	<= '0';
		result_sig 			<= (others => '0');
		
		-- MUX FOR ALU FUNCTIONS
		case OP_SELECT_VAR is
			
		when ALU_ADD =>		-- add unsigned bits
			-- rd <- rs + rt
			result_sig <= std_logic_vector( unsigned(UNSIGNED_A_64) + unsigned(UNSIGNED_B_64) );
			
		when ALU_SUB =>		-- subtract unsigned bits
			-- rd <- rs - rt
			result_sig <= std_logic_vector( unsigned(UNSIGNED_A_64) - unsigned(UNSIGNED_B_64) );
			
		when ALU_MULT =>	-- signed multiply
			-- (LO, HI) <- rs x rt
			result_sig <= std_logic_vector( signed(a) * signed(b) );
			
		when ALU_MULTU =>	-- unsigned multiply
			-- (LO, HI) <- rs x rt
			result_sig <= std_logic_vector( unsigned(a) * unsigned(b) );
	
		when ALU_AND =>		-- bitwise and
			-- rd <- rs AND rt
			result_sig <= std_logic_vector(UNSIGNED_A_64 and UNSIGNED_B_64);
			
		when ALU_OR =>		-- bitwise or
			-- rd <- rs OR rt
			result_sig <= std_logic_vector(UNSIGNED_A_64 or UNSIGNED_B_64);
			
		when ALU_XOR =>		-- bitwise exclusive or
			-- rd <- rs XOR rt
			result_sig <= std_logic_vector(UNSIGNED_A_64 xor UNSIGNED_B_64);
			
		when ALU_SRL =>		-- shift right logical
			-- rd <- rt >> sa
			result_sig <= std_logic_vector(shift_right(UNSIGNED_B_64, IR_SHIFT_VAR));
			
		when ALU_SLL =>		-- shift left logical
			-- rd <- rt << sa
			result_sig <= std_logic_vector(shift_left(UNSIGNED_B_64, IR_SHIFT_VAR));
			
		when ALU_SRA =>		-- shift right arithmetic
			-- rd <- rt >> sa
			result_sig <= std_logic_vector(shift_right(SIGNED_B_64, IR_SHIFT_VAR));
			
		when ALU_SLT =>		-- set if less than signed
			-- rd <- rs < rt	
			if ( signed_a < signed_b ) then
				result_sig <= std_logic_vector(to_unsigned(1, 2*WIDTH));
			end if;
				
		when ALU_SLTU =>	-- set if less than unsigned
			if ( unsigned(a) < unsigned(b) ) then
				result_sig <= std_logic_vector(to_unsigned(1, 2*WIDTH));
			end if;
			
		when ALU_LW =>		-- load word
			-- rd <- mem[base + offset] stored in rt
			result_sig <= std_logic_vector(UNSIGNED_B_64);
			
		when ALU_SW =>		-- store word
			-- mem[base + offset] <- rt
			result_sig <= std_logic_vector(UNSIGNED_B_64);
			
		when ALU_BEQ =>		-- break if A equals B
			-- if rs = rt, branch
			-- if result = 0, don't branch.
			-- if result = 1, branch.
			if ( unsigned(a) = unsigned(b) ) then
				branch_taken_sig <= '1';
			end if;
			
		when ALU_BNE =>		-- break if A does not equal B
			-- if rs != rt, branch
			-- if result = 0, don't branch.
			-- if result = 1, branch.
			if ( unsigned(a) /= unsigned(b) ) then
				branch_taken_sig <= '1';
			end if;
			
		when ALU_BLEZ =>	-- break if less than equal to 0
			-- if rs <= 0, branch
			-- if result = 0, don't branch.
			-- if result = 1, branch.
			if ( signed_a <= to_signed(0, WIDTH) ) then
				branch_taken_sig <= '1';
			end if;
			
		when ALU_BGTZ =>	-- break if greater than 0
			-- if rs <= 0, branch
			-- if result = 0, don't branch.
			-- if result = 1, branch.
			if ( signed_a > to_signed(0, WIDTH) ) then
				branch_taken_sig <= '1';
			end if;
			
		when ALU_BCOMPZ =>	-- compare to 0
			
			-- check what the controller loaded into register B to
			-- determine what comparison to make.
			if ( b = std_logic_vector(to_unsigned(0, WIDTH)) ) then
				-- branch on less than 0
				if ( signed_b < to_signed(0, WIDTH) ) then
					branch_taken_sig <= '1';
				end if;
								
			else -- if b = 1
				-- branch on greater than or equal to 0
				if ( signed_b >= to_signed(1, WIDTH) ) then
					branch_taken_sig <= '1';
				end if;
			end if;
			
		when ALU_JR =>		-- jump register
			branch_taken_sig <= '1';
			
		when ALU_MFHI =>	-- move HI register into GPR[RD]
			
		when ALU_MFLO =>	-- move LO register into GPR[RD]
			
		when ALU_HALT =>	-- fake instruction
		
		when others => null;
		end case;
		
	end process;
	
	-- SIGNAL TO PORT CONNECTIONS
	branch_taken 	<= branch_taken_sig;			
	result 			<= result_sig(WIDTH-1 downto 0); -- lo, alu_out
	result_hi 		<= result_sig(2*WIDTH-1 downto WIDTH); -- hi
	
end BHV;
	