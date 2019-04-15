library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.mips_lib.all;

-- This component controls all the datapath signals to allow machine code
-- instructions to automatically perform calculations, update registers,
-- and increment to the next address of the program.

-- Author		: Daniel Hamilton
-- Creation 	: 4/14/2019
-- Last Edit 	: 4/14/2019

-- UPDATES
-- 4/14/2019	: Component initialization. 


entity MIPS_CONTROLLER is
	port ( 
	-- controller ports
	clk : in std_logic;
	rst : in std_logic;
	op_code : in std_logic_vector(5 downto 0);
	
    -- datapath interaction ports
	pcWrite 	: out std_logic;
	pcWriteCond : out std_logic;
	iOrD		: out std_logic;
	memRead		: out std_logic;
	memWrite	: out std_logic;
	memToReg	: out std_logic;
	irWrite		: out std_logic;
	jumpAndLink	: out std_logic;
	isSigned	: out std_logic;
	pcSource	: out std_logic_vector(1 downto 0);
	aluOp		: out std_logic_vector(5 downto 0);
	aluSrcA		: out std_logic;
	aluSrcB		: out std_logic_vector(1 downto 0);
	regWrite	: out std_logic;
	regDst		: out std_logic    
    );
    
end MIPS_CONTROLLER;

architecture BHV of MIPS_CONTROLLER is
	
	-- TYPE DEFINITIONS ----------------------------------------------------
	type STATE_T is 
	( 	
		S_START, S_FETCH, S_FETCH_WAIT, S_DECODE,		 	-- COMMON STATES
		S_R_EXECUTION, S_R_WAIT, S_R_COMPLETE, 				-- R TYPE STATES
		S_I_EXECUTION, S_I_WAIT, S_I_COMPLETE,				-- I TYPE STATES
		S_LW_SW, S_LW_SW_WAIT, S_SW_COMPLETE, 				-- LW / SW STATES
		S_LW_MEMACC, S_LW_WAIT, S_LW_COMPLETE, S_SW_WAIT,	-- LW / SW STATES CONTINUED
		S_BEQ_COMPLETE,										-- BRANCH STATES
		S_J_COMPLETE										-- J TYPE STATES
	);
	
	-- INTERNAL SIGNAL DECLARATIONS ----------------------------------------
	signal state 		: STATE_T;
	signal next_state 	: STATE_T;
	
	-- OUTPUT PORT SIGNAL DECLARATIONS -------------------------------------
	signal pcWrite_sig 	    : std_logic;
	signal pcWriteCond_sig  : std_logic;
	signal iOrD_sig		    : std_logic;
	signal memRead_sig		: std_logic;
	signal memWrite_sig	    : std_logic;
	signal memToReg_sig	    : std_logic;
	signal irWrite_sig		: std_logic;
	signal jumpAndLink_sig	: std_logic;
	signal isSigned_sig	    : std_logic;
	signal pcSource_sig	    : std_logic_vector(1 downto 0);
	signal aluOp_sig		: std_logic_vector(5 downto 0);
	signal aluSrcA_sig		: std_logic;
	signal aluSrcB_sig		: std_logic_vector(1 downto 0);
	signal regWrite_sig	    : std_logic;
	signal regDst_sig		: std_logic;	
begin  
	
	-- STATE SWITCHING PROCESS ---------------------------------------------
	process(clk, rst)
	begin
		
		if ( rst = '1' ) then
			state <= S_START;
			
		elsif ( rising_edge(clk) ) then
			state <= next_state;
		end if;
		
	end process;
	
	-- CONTROLLER STATE MACHINE --------------------------------------------
	process( state, op_code )
	begin
		
		-- DEFAULT SIGNAL ASSIGNMENTS
		next_state <= S_FETCH;
		pcWrite_sig 	<= '0';    
		pcWriteCond_sig <= '0'; 
		iOrD_sig		<= '0';    
		memRead_sig		<= '0';
		memWrite_sig	<= '0';    
		memToReg_sig	<= '0';    
		irWrite_sig		<= '0';
		jumpAndLink_sig	<= '0';
		isSigned_sig	<= '0';    
		pcSource_sig	<= (others => '0');    
		aluOp_sig		<= (others => '0');
		aluSrcA_sig		<= '0';
		aluSrcB_sig		<= (others => '0');
		regWrite_sig	<= '0';    
		regDst_sig		<= '0';
		
		case state is
			
		-- ==========================================================
		-- =														=
		-- = 		   COMMON COMMON COMMON COMMON COMMON			=
		-- =														=
		-- ==========================================================	
		
		-- S_START is the starting state on reset that deasserts all
		-- signals, so the S_FETCH doesn't auto-increment the PC value
		when S_START =>	
		
			-- STATE HANDLING
			next_state 	<= S_FETCH;
			
		-- S_FETCH instruction, store in IR (instruction register).
		-- Increment PC = PC + 4.
		when S_FETCH =>
		
			-- IR = mem[PC]
			IorD_sig 	<= '0'; -- select PC as the next memory address
			memRead_sig <= '1';	-- read next PC address
			irWrite_sig <= '1'; -- IR is loaded with the next memory data 	
			
			-- PC = PC + 4
			aluSrcA_sig  <= '0'; 	-- PC is loaded into ALU to increment to next address
			aluSrcB_sig  <= "01"; 	-- B = 4 to increment PC to next address
			aluOp_sig	 <= OP_ADDIU; -- addition op code
			pcWrite_sig  <= '1';	-- allow the PC to go to the next address
			pcSource_sig <= "00"; 	-- stores the newly incremented PC value
		
			-- STATE HANDLING
			next_state 	<= S_DECODE;
			
		-- S_DECODE the instruction. 
		-- Read in RS and RT register to A and B.
		-- Compute target branch address using lower 16 bits of instruction -> ALU_OUT
		when S_DECODE =>
		
			-- Lookahead logic
			aluSrcA_sig <= '1'; -- A ALU input is PC address information to prep for BRANCH instruction
			aluSrcB_sig <= "11"; -- B ALU input is sign extended IR[15-0] to prep for IMMEDIATE-type instruction
			regDst_sig 	<= '0';  -- loads register B with RT, register A also loads with RS to prep for R-Type instruction

			-- STATE HANDLING (defaults to fetch state)
			if ( op_code = OP_R_TYPE ) then						-- S_R_EXECUTION 
				next_state <= S_R_EXECUTION;
				
			elsif ( op_code = OP_SW or op_code = OP_LW) then 	-- S_LW_SW  
				next_state <= S_LW_SW;
				
			elsif ( op_code = OP_BCOMPZ ) then					-- S_BEQ_COMPLETE 
				next_state <= S_BEQ_COMPLETE;
				
			elsif ( op_code = OP_J ) then						-- S_J_COMPLETE	
				next_state <= S_J_COMPLETE;
				
			elsif ( op_code = OP_HALT ) then					-- INFINITE LOOP AT EOP
				next_state <= S_DECODE;
				
			else												-- I-TYPE INSTRUCTIONS
				next_state <= S_I_EXECUTION;
				
			end if;
			
		-- ==========================================================
		-- =														=
		-- = 		   			REGISTER OPERATIONS					=
		-- =														=
		-- ==========================================================	
		when S_R_EXECUTION =>
		
			aluSrcA_sig <= '1'; 	-- register A => ALU_A for R type instruction
			aluSrcB_sig <= "00";	-- register B => ALU_B for R type instruction
			aluOp_sig	<= (others => '0'); -- op code for R type instructions
			
			-- STATE HANDLING
			next_state <= S_R_WAIT;
			
		when S_R_WAIT =>
			
			regDst_sig 		<= '1';	-- RD register loaded as the register to write ALU_OUT to
			regWrite_sig 	<= '1';	-- enable register writes to the register file
			memToReg_sig 	<= '0';	-- Write the output of ALU_OUT to the register file
			
			-- STATE HANDLING
			next_state <= S_R_COMPLETE;
			
		when S_R_COMPLETE =>
			
			-- STATE HANDLING
			next_state <= S_FETCH;
			
		-- ==========================================================
		-- =														=
		-- = 		   			IMMEDIATE OPERATIONS				=
		-- =														=
		-- ==========================================================
		when  S_I_EXECUTION =>
			
			isSigned_sig 	<= '1';		-- allow 16 bit immediate value to be sign extended to 32 bit
			aluSrcA_sig 	<= '1';		-- register A => ALU_A for I type instructions
			aluSrcB_sig 	<= "10"; 	-- load the immediate value to the alu
			aluOp_sig 		<= op_code; -- op code specific instruction
			
			next_state <= S_I_WAIT;
			
		when S_I_WAIT =>
			
			regDst_sig 		<= '0';	-- RT register loaded as the register to write ALU_OUT to
			regWrite_sig 	<= '1';	-- enable register writes to the register file
			memToReg_sig 	<= '0';	-- Write the output of ALU_OUT to the register file
			
			-- STATE HANDLING
			next_state <= S_I_COMPLETE;
			
		when S_I_COMPLETE =>
			
			-- STATE HANDLING
			next_state <= S_FETCH;
			
		-- ==========================================================
		-- =														=
		-- = 		   	STORE / LOAD WORD INSTRUCTIONS				=
		-- =														=
		-- ==========================================================	
		when S_LW_SW =>			-- memory address computation 
		
			-- rt <= mem[base + offset]
			aluSrcA_sig <= '1';	 -- address base loaded into A
			aluSrcB_sig <= "10"; -- sign extended IR[15:0] with bit shifting to compute memory address
			aluOp_sig	<= OP_ADDIU; -- base + offset
			
			-- STATE HANDLING (defaults to fetch state)
			if (op_code = OP_SW) then		-- S_SW_COMPLETE
				next_state <= S_SW_WAIT;
			elsif (op_code = OP_LW) then	-- S_LW_MEMACC
				next_state <= S_LW_MEMACC;
			end if; 
			
		when S_SW_WAIT =>	
			
			memWrite_sig <= '1'; -- Allow the data from Register B to write into the out_port
			IorD_sig <= '1';	 -- 0xFFFC is placed in mem_in to allow register B to the out_port
			
			next_state <= S_SW_COMPLETE;
			
		when S_SW_COMPLETE =>	-- store the loaded value to memory or output to the out_port if addr = 0xFFFC
			
			next_state <= S_FETCH;
			
		when S_LW_MEMACC => 	-- memory access for load word instructions
			
			-- allow memory to read from the address sent to mem_in
			memRead_sig	<= '1';	 -- enable memory read to load data from memory
			IorD_sig 	<= '1';  -- memory address comes from ALU out to load data for LW instruction
			
			-- STATE HANDLING
			next_state <= S_LW_WAIT;
			
		when S_LW_WAIT =>	-- data from memory is already stored in memory data register
			
			memRead_sig	 <= '1';		-- allow the data to output from SRAM to the mem_out
			
			-- STATE HANDLING
			next_state <= S_LW_COMPLETE;
			
		when S_LW_COMPLETE => 	-- latch the information into the register file
			
			regDst_sig 	 <= '0';	-- load address of RT into the register file to be written to
			memToReg_sig <= '1'; 	-- set mux to allow data from memory into the register file
			regWrite_sig <= '1';	-- Load the data from memory into the register file
				
			-- STATE HANDLING		
			next_state <= S_FETCH;
			
		-- ==========================================================
		-- =														=
		-- = 		   			BEQ INSTRUCTIONS					=
		-- =														=
		-- ==========================================================
		when S_BEQ_COMPLETE =>
			
			-- STATE HANDLING
			next_state <= S_FETCH;
			
		-- ==========================================================
		-- =														=
		-- = 		   			JUMP INSTRUCTIONS					=
		-- =														=
		-- ==========================================================
		when S_J_COMPLETE =>
		
			-- STATE HANDLING
			next_state <= S_FETCH;
			
		when others => next_state <= S_FETCH;
		end case;
			
	end process;
	
	-- SIGNAL TO PORT ASSIGNMENTS ------------------------------------
	pcWrite 	<= pcWrite_sig; 	    
	pcWriteCond <= pcWriteCond_sig;  
	iOrD 		<= iOrD_sig;		    
	memRead 	<= memRead_sig;		
	memWrite 	<= memWrite_sig;	    
	memToReg 	<= memToReg_sig;	    
	irWrite 	<= irWrite_sig;		
	jumpAndLink <= jumpAndLink_sig;	
	isSigned 	<= isSigned_sig;	    
	pcSource 	<= pcSource_sig;	    
	aluOp 		<= aluOp_sig;		
	aluSrcA 	<= aluSrcA_sig;		
	aluSrcB 	<= aluSrcB_sig;		
	regWrite 	<= regWrite_sig;	    
	regDst 		<= regDst_sig;		
	
end BHV;