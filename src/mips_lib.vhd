library ieee;
use ieee.std_logic_1164.all;

package MIPS_LIB is

  -----------------------------------------------------
  -- OP CODE INSTRUCIONS
  	constant OP_R_TYPE 	: std_logic_vector(5 downto 0) := "000000";
  	constant OP_BCOMPZ 	: std_logic_vector(5 downto 0) := "000001";
  	constant OP_J 		: std_logic_vector(5 downto 0) := "000010";
  	constant OP_JAL 	: std_logic_vector(5 downto 0) := "000011";
  	constant OP_BEQ 	: std_logic_vector(5 downto 0) := "000100";
  	constant OP_BNE 	: std_logic_vector(5 downto 0) := "000101";
  	constant OP_BLEZ 	: std_logic_vector(5 downto 0) := "000110";
  	constant OP_BGTZ 	: std_logic_vector(5 downto 0) := "000111";
  	constant OP_ADDIU 	: std_logic_vector(5 downto 0) := "001001";
  	constant OP_SLTI 	: std_logic_vector(5 downto 0) := "001010";
  	constant OP_SLTIU 	: std_logic_vector(5 downto 0) := "001011";
  	constant OP_ANDI 	: std_logic_vector(5 downto 0) := "001100";
  	constant OP_ORI		: std_logic_vector(5 downto 0) := "001101";
  	constant OP_XORI	: std_logic_vector(5 downto 0) := "001110";
  	constant OP_SUBIU 	: std_logic_vector(5 downto 0) := "010000";
  	constant OP_LW 		: std_logic_vector(5 downto 0) := "100011";
  	constant OP_SW 		: std_logic_vector(5 downto 0) := "101011";
  	constant OP_HALT 	: std_logic_vector(5 downto 0) := "111111";
  
  -----------------------------------------------------
  -- ALU R/I TYPE INSTRUCTION CONSTANTS
  
	constant ALU_ADD 	: integer := 0;
	constant ALU_SUB 	: integer := 1;
	constant ALU_MULT 	: integer := 2;
	constant ALU_MULTU 	: integer := 3;
	constant ALU_AND	: integer := 4;
	constant ALU_OR		: integer := 5;
	constant ALU_XOR	: integer := 6;
	constant ALU_SRL	: integer := 7;
	constant ALU_SLL	: integer := 8;
	constant ALU_SRA	: integer := 9;
	constant ALU_SLT	: integer := 10;
	constant ALU_SLTU	: integer := 11;
	constant ALU_MFHI	: integer := 12;
	constant ALU_MFLO	: integer := 13;
	constant ALU_JR		: integer := 14;
	
  -----------------------------------------------------
  -- ALU ADDITIONAL I/J TYPE INSTRUCTION CONSTANTS
  	
  	constant ALU_BLTZ	: integer := 15; -- unused, ALU_BCOMP instead 
  	constant ALU_BGEZ 	: integer := 16; -- unused, ALU_BCOMP instead 
  	constant ALU_BCOMPZ	: integer := 17;
  	constant ALU_J		: integer := 18; -- unused, J type command
  	constant ALU_JAL	: integer := 19; -- unused, J type command
  	constant ALU_BEQ	: integer := 20;
  	constant ALU_BNE	: integer := 21;
  	constant ALU_BLEZ	: integer := 22;
  	constant ALU_BGTZ	: integer := 23;
	constant ALU_ADDI	: integer := 24; -- unused, ALU_ADD instead
	constant ALU_SUBIU	: integer := 25; -- unused, ALU_SUB instead
	constant ALU_ANDI	: integer := 26; -- unused, ALU_AND instead
	constant ALU_SLTI	: integer := 27; -- unused, SLT instead
	constant ALU_SLTIU	: integer := 28; -- unused, SLTU instead
	constant ALU_LW		: integer := 29;
	constant ALU_SW		: integer := 30;
	constant ALU_XORI	: integer := 31; -- unused, ALU_XOR instead
	constant ALU_HALT	: integer := 32;

  -----------------------------------------------------
  -- ALU OUT MUX constants
  	
  	constant ALU_OUT_MUX_ALU : integer := 0;
  	constant ALU_OUT_MUX_HI	: integer := 1;
  	constant ALU_OUT_MUX_LO : integer := 2;
  	
  -----------------------------------------------------
  -- MEMORY ADDRESSING CONSTANTS
  
  	constant MEM_INPORT0 : std_logic_vector(31 downto 0) := X"0000FFF8";
  	constant MEM_INPORT1 : std_logic_vector(31 downto 0) := X"0000FFFC";
  	constant MEM_OUTPORT : std_logic_vector(31 downto 0) := X"0000FFFC";
  	
  -----------------------------------------------------
  -- INSTRUCTION CONSTANTS  	
  
end MIPS_LIB;