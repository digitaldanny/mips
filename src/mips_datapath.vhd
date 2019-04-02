library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component contains the datapath for the MIPS FSM+D. 
-- All non-controller CPU structures connect here.

-- Author		: Daniel Hamilton
-- Creation 	: 3/29/2019
-- Last Edit 	: 4/1/2019

-- UPDATES
-- 3/29/2019	: Component initialization. 
-- 4/1/2019		: Linked datapath to memory block and register file
-- 4/2/2019		: Reorganized datapath connections using more clearly named signals.

entity MIPS_DATAPATH is
	generic (
		WIDTH : positive := 32
	);
	port (
		-- controller IO ----------------------------------
		pcWrite 	: in std_logic;
		pcWriteCond : in std_logic;
		iOrD		: in std_logic;
		memRead		: in std_logic;
		memWrite	: in std_logic;
		memToReg	: in std_logic;
		irWrite		: in std_logic;
		jumpAndLink	: in std_logic;
		isSigned	: in std_logic;
		pcSource	: in std_logic_vector(1 downto 0);
		aluOp		: in std_logic_vector(5 downto 0);
		aluSrcA		: in std_logic;
		aluSrcB		: in std_logic_vector(1 downto 0);
		regWrite	: in std_logic;
		regDst		: in std_logic;
		
		-- non controller IO ------------------------------
		clk			: in std_logic;
		rst 		: in std_logic;
		in_port_sel : in std_logic;	-- select between port_in_0 and port_in_1
		in_port 	: in std_logic_vector(WIDTH-1 downto 0);
		out_port 	: out std_logic_vector(WIDTH-1 downto 0)
	);
end MIPS_DATAPATH;

architecture STR of MIPS_DATAPATH is
	
	constant C4	: std_logic_vector(WIDTH-1 downto 0) := std_logic_vector(to_unsigned(4, WIDTH));
	constant C0	: std_logic_vector(WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, WIDTH));
	
	-------------------- ALU ----------------------
	signal alu_a           	: std_logic_vector(WIDTH-1 downto 0);
	signal alu_b           	: std_logic_vector(WIDTH-1 downto 0);
	signal alu_ir_shift    	: std_logic_vector(4 downto 0);
	signal alu_op_select   	: std_logic_vector(5 downto 0);
	signal alu_branch_taken : std_logic;
	signal alu_result       : std_logic_vector(WIDTH-1 downto 0);
	signal alu_result_hi	: std_logic_vector(WIDTH-1 downto 0);
	
	---------------- ALU OUT REG ------------------
	signal alu_out_en     : std_logic;
	signal alu_out_input  : std_logic_vector(WIDTH-1 downto 0);
	signal alu_out_output : std_logic_vector(WIDTH-1 downto 0);
	
	------------------ LO REG ---------------------
	signal lo_en      : std_logic;
	signal lo_input   : std_logic_vector(WIDTH-1 downto 0);
	signal lo_output  : std_logic_vector(WIDTH-1 downto 0);
	-------------------HI REG ---------------------
	signal hi_en      : std_logic;
	signal hi_input   : std_logic_vector(WIDTH-1 downto 0);
	signal hi_output  : std_logic_vector(WIDTH-1 downto 0);
	
	---------------- ALU OUT MUX ------------------
	signal alu_out_mux_sel     : std_logic_vector(1 downto 0);
	signal alu_out_mux_a       : std_logic_vector(WIDTH-1 downto 0);
	signal alu_out_mux_b       : std_logic_vector(WIDTH-1 downto 0);
	signal alu_out_mux_c       : std_logic_vector(WIDTH-1 downto 0);
	signal alu_out_mux_d       : std_logic_vector(WIDTH-1 downto 0);
	signal alu_out_mux_output  : std_logic_vector(WIDTH-1 downto 0);
	
	--------------- ALU CONTROLLER ----------------
	signal alu_controller_ir_r_type   : std_logic_vector(5 downto 0);
	signal alu_controller_op_code     : std_logic_vector(5 downto 0);
	signal alu_controller_op_select   : std_logic_vector(5 downto 0);
	signal alu_controller_hi_en       : std_logic;
	signal alu_controller_lo_en       : std_logic;
	signal alu_controller_alu_lo_hi   : std_logic_vector(1 downto 0);
	
	----------------- PC IN MUX -------------------
	signal pc_in_mux_sel     : std_logic_vector(1 downto 0);
	signal pc_in_mux_a       : std_logic_vector(WIDTH-1 downto 0);
	signal pc_in_mux_b       : std_logic_vector(WIDTH-1 downto 0);
	signal pc_in_mux_c       : std_logic_vector(WIDTH-1 downto 0);
	signal pc_in_mux_d       : std_logic_vector(WIDTH-1 downto 0);
	signal pc_in_mux_output  : std_logic_vector(WIDTH-1 downto 0);
	
	----------------- REG B MUX -------------------
	signal reg_b_mux_sel     : std_logic_vector(1 downto 0);
	signal reg_b_mux_a       : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_mux_b       : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_mux_c       : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_mux_d       : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_mux_output  : std_logic_vector(WIDTH-1 downto 0);
	
	----------------- REG A MUX -------------------
	signal reg_a_mux_sel     : std_logic;
	signal reg_a_mux_a       : std_logic_vector(WIDTH-1 downto 0);
	signal reg_a_mux_b       : std_logic_vector(WIDTH-1 downto 0);
	signal reg_a_mux_output  : std_logic_vector(WIDTH-1 downto 0);
	
	------------------- REG A ---------------------
	signal reg_a_en     : std_logic;
	signal reg_a_input  : std_logic_vector(WIDTH-1 downto 0);
	signal reg_a_output : std_logic_vector(WIDTH-1 downto 0);
	
	------------------- REG B ---------------------
	signal reg_b_en     : std_logic;
	signal reg_b_input  : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_output : std_logic_vector(WIDTH-1 downto 0);
	
	--------------- REGISTER FILE -----------------
	signal reg_file_rd_addr0    : std_logic_vector(4 downto 0);
	signal reg_file_rd_addr1    : std_logic_vector(4 downto 0);
	signal reg_file_wr_addr     : std_logic_vector(4 downto 0);
	signal reg_file_wr_en       : std_logic;
	signal reg_file_wr_data     : std_logic_vector(WIDTH-1 downto 0);
	signal reg_file_JumpAndLink : std_logic;
	signal reg_file_rd_data0    : std_logic_vector(WIDTH-1 downto 0);
	signal reg_file_rd_data1    : std_logic_vector(WIDTH-1 downto 0);
	
	-------------- WRITE REG MUX ------------------
	signal write_reg_mux_sel     : std_logic;
	signal write_reg_mux_a       : std_logic_vector(WIDTH-1 downto 0);
	signal write_reg_mux_b       : std_logic_vector(WIDTH-1 downto 0);
	signal write_reg_mux_output  : std_logic_vector(WIDTH-1 downto 0);
	
	------------- WRITE DATA MUX ------------------
	signal write_data_mux_sel     : std_logic;
	signal write_data_mux_a       : std_logic_vector(WIDTH-1 downto 0);
	signal write_data_mux_b       : std_logic_vector(WIDTH-1 downto 0);
	signal write_data_mux_output  : std_logic_vector(WIDTH-1 downto 0);
	
	------------ MEM DATA REGISTER ----------------
    signal mem_data_reg_en     : std_logic;
    signal mem_data_reg_input  : std_logic_vector(WIDTH-1 downto 0);
    signal mem_data_reg_output : std_logic_vector(WIDTH-1 downto 0);
    
    ----------- INSTRUCTION REGISTER --------------
	signal inst_reg_ir_write  : std_logic;
	signal inst_reg_data      : std_logic_vector(WIDTH-1 downto 0);
	signal inst_reg_out_25_0  : std_logic_vector(25 downto 0);
	signal inst_reg_out_31_26 : std_logic_vector(5 downto 0);
	signal inst_reg_out_25_21 : std_logic_vector(4 downto 0);
	signal inst_reg_out_20_16 : std_logic_vector(4 downto 0);
	signal inst_reg_out_15_11 : std_logic_vector(4 downto 0);
	signal inst_reg_out_15_0  : std_logic_vector(15 downto 0); 
	
	--------------- MEMORY BLOCK ------------------
	signal mem_block_in_port_data    : std_logic_vector(WIDTH-1 downto 0);
	signal mem_block_mem_in          : std_logic_vector(WIDTH-1 downto 0);
	signal mem_block_mem_out         : std_logic_vector(WIDTH-1 downto 0);
	signal mem_block_mem_rd_en       : std_logic;
	signal mem_block_mem_wr_en       : std_logic;
	signal mem_block_user_in_port_en : std_logic;
	signal mem_block_reg_b_data      : std_logic_vector(WIDTH-1 downto 0);
	signal mem_block_out_port        : std_logic_vector(WIDTH-1 downto 0);
	
	------------- MEMORY BLOCK MUX -----------------
	signal mem_block_mux_sel    : std_logic;
	signal mem_block_mux_a      : std_logic_vector(WIDTH-1 downto 0);
	signal mem_block_mux_b      : std_logic_vector(WIDTH-1 downto 0);
	signal mem_block_mux_output : std_logic_vector(WIDTH-1 downto 0);
	
	--------------- SIGN EXTENDED ------------------
	signal sign_extended_en		: std_logic;
	signal sign_extended_input  : std_logic_vector(15 downto 0);
	signal sign_extended_output : std_logic_vector(WIDTH-1 downto 0);
	
	---------------- PC REGISTER -------------------
	signal pc_en      : std_logic;
	signal pc_input   : std_logic_vector(WIDTH-1 downto 0);
	signal pc_output  : std_logic_vector(WIDTH-1 downto 0);
	
	--------------- SHIFT LEFT PC ------------------
	signal shift_left_pc_input   : std_logic_vector(25 downto 0);
	signal shift_left_pc_output  : std_logic_vector(27 downto 0);
	
	---------------- CONCAT PC ---------------------
	signal concat_input  : std_logic_vector(27 downto 0);
	signal concat_pc     : std_logic_vector(3 downto 0);
	signal concat_output : std_logic_vector(WIDTH-1 downto 0);
	
	-------------- SHIFT LEFT SIGN -----------------
	signal shift_left_sign_input  : std_logic_vector(WIDTH-1 downto 0);
	signal shift_left_sign_output : std_logic_vector(WIDTH-1 downto 0);
	
begin
	
	--==================== COMPONENT CONNECTIONS =====================

	
	--========================= STRUCTURAL ===========================
	U_ALU : entity work.ALU
		generic map( 
			IN_WIDTH => WIDTH,
			WIDTH => WIDTH
		)
		port map(
			a            => alu_a,
			b            => alu_b,
			ir_shift     => alu_ir_shift,
			op_select    => alu_op_select,
			branch_taken => alu_branch_taken,
			result       => alu_result,
			result_hi	 => alu_result_hi
		);
		
	U_ALU_OUT_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => alu_out_en,    
			input  => alu_out_input, 
			output => alu_out_output
		);
		
	U_LO_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => lo_en,    
			input  => lo_input, 
			output => lo_output
		);
		
	U_HI_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => hi_en,    
			input  => hi_input, 
			output => hi_output
		);
		
	U_ALU_OUT_MUX : entity work.mux_4x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => alu_out_mux_sel,   
			a      => alu_out_mux_a,   
			b      => alu_out_mux_b,     
			c      => alu_out_mux_c,     
			d      => alu_out_mux_d,     
			output => alu_out_mux_output
		);
		
	U_ALU_CONTROLLER : entity work.ALU_CONTROLLER
		port map(
			ir_r_type => alu_controller_ir_r_type, 
			op_code   => alu_controller_op_code,   
			op_select => alu_controller_op_select, 
			hi_en     => alu_controller_hi_en,     
			lo_en     => alu_controller_lo_en,     
			alu_lo_hi => alu_controller_alu_lo_hi 
		);
		
	U_PC_IN_MUX : entity work.mux_4x1
		generic map(
			WIDTH => WIDTH
		)
		port map (
			sel    => pc_in_mux_sel,  
			a      => pc_in_mux_a,    
			b      => pc_in_mux_b,    
			c      => pc_in_mux_c,    
			d      => pc_in_mux_d,    
			output => pc_in_mux_output
		);
		
	U_REG_B_MUX : entity work.mux_4x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => reg_b_mux_sel,   
			a      => reg_b_mux_a,     
			b      => reg_b_mux_b,     
			c      => reg_b_mux_c,     
			d      => reg_b_mux_d,     
			output => reg_b_mux_output 
		);
		
	U_REG_A_MUX : entity work.mux_2x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => reg_a_mux_sel,
			a      => reg_a_mux_a,
			b      => reg_a_mux_b,
			output => reg_a_mux_output
		);
		
	U_REG_A : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => reg_a_en,
			input  => reg_a_input,
			output => reg_a_output
		);
		
	U_REG_B : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => reg_b_en,
			input  => reg_b_input,
			output => reg_b_output
		);
		
	U_REGISTER_FILE : entity work.register_file
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk         => clk,
			rst         => rst,
			rd_addr0    => reg_file_rd_addr0,
			rd_addr1    => reg_file_rd_addr1,
			wr_addr     => reg_file_wr_addr,
			wr_en       => reg_file_wr_en,
			wr_data     => reg_file_wr_data,
			JumpAndLink => reg_file_JumpAndLink,
			rd_data0    => reg_file_rd_data0,
			rd_data1    => reg_file_rd_data1
		);
		
	U_WRITE_REG_MUX : entity work.mux_2x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => write_reg_mux_sel,
			a      => write_reg_mux_a,
			b      => write_reg_mux_b,
			output => write_reg_mux_output
		);
		
	U_WRITE_DATA_MUX : entity work.mux_2x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => write_data_mux_sel,
			a      => write_data_mux_a,
			b      => write_data_mux_b,
			output => write_data_mux_output
		);
		
	U_MEM_DATA_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => mem_data_reg_en,
			input  => mem_data_reg_input,
			output => mem_data_reg_output
		);
		
	U_INSTRUCTION_REGISTER : entity work.IR
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk       => clk,
			rst       => rst,
			ir_write  => inst_reg_ir_write,
			data      => inst_reg_data,
			out_25_0  => inst_reg_out_25_0,
			out_31_26 => inst_reg_out_31_26,
			out_25_21 => inst_reg_out_25_21,
			out_20_16 => inst_reg_out_20_16,
			out_15_11 => inst_reg_out_15_11,
			out_15_0  => inst_reg_out_15_0
		);
		
	U_MEMORY_BLOCK : entity work.MEMORY_BLOCK
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk             => clk,
			rst             => rst,
			in_port_data    => mem_block_in_port_data,
			mem_in          => mem_block_mem_in,
			mem_out         => mem_block_mem_out,
			mem_rd_en       => mem_block_mem_rd_en,
			mem_wr_en       => mem_block_mem_wr_en,
			user_in_port_en => mem_block_user_in_port_en,
			reg_b_data      => mem_block_reg_b_data,
			out_port        => mem_block_out_port
		);
		
	U_MEMORY_BLOCK_MUX : entity work.mux_2x1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			sel    => mem_block_mux_sel,
			a      => mem_block_mux_a,
			b      => mem_block_mux_b,
			output => mem_block_mux_output
		);
		
	U_SIGN_EXTENDED : entity work.sign_extended
		port map(
			en 	   => sign_extended_en,
			input  => sign_extended_input,
			output => sign_extended_output
		);
		
	U_PC_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => pc_en,
			input  => pc_input,
			output => pc_output
		);
		
	U_SHIFT_LEFT_PC : entity work.SHIFT_LEFT_2_26
		port map(
			input  => shift_left_pc_input,
			output => shift_left_pc_output
		);
		
	U_CONCAT_PC : entity work.CONCAT
		port map(
			input  => concat_input,
			pc     => concat_pc,
			output => concat_output
		);
		
	U_SHIFT_LEFT_SIGN : entity work.SHIFT_LEFT_2_32
		port map(
			input  => shift_left_sign_input,
			output => shift_left_sign_output
		);
		
 	-- DRIVE ALL SIGNAL INPUTS WITH SIGNAL OUTPUTS ------------------------------
 	
 	-------------------- ALU ----------------------
	alu_a          <= reg_a_mux_output;
	alu_b          <= reg_b_mux_output;
	alu_ir_shift   <= inst_reg_out_15_0(10 downto 6);
	alu_op_select  <= alu_controller_op_select;
	
	---------------- ALU OUT REG -----------------
	alu_out_en     <= '1';
	alu_out_input  <= alu_result;
	
	------------------- LO REG -------------------
	lo_en      <= alu_controller_lo_en;
	lo_input   <= alu_result;
	
	------------------- HI REG -------------------
	hi_en      <= alu_controller_hi_en;
	hi_input   <= alu_result_hi;
	
	---------------- ALU OUT MUX -----------------
	alu_out_mux_sel <= alu_controller_alu_lo_hi;
	alu_out_mux_a   <= alu_out_output;
	alu_out_mux_b   <= lo_output;
	alu_out_mux_c   <= hi_output;
	alu_out_mux_d   <= C0;
	
	----------------- PC IN MUX ------------------
	pc_in_mux_sel   <= pcSource;
	pc_in_mux_a     <= alu_result;
	pc_in_mux_b     <= alu_out_output;
	pc_in_mux_c     <= concat_output;
	pc_in_mux_d     <= C0;
	
	---------------- PC REGISTER -----------------
	pc_input <= pc_in_mux_output; 
	pc_en	 <= pcWrite or (pcWriteCond and alu_branch_taken);
	
	--------------- ALU CONTROLLER ---------------
	alu_controller_op_code 		<= aluOp;
	alu_controller_ir_r_type 	<= inst_reg_out_15_0(5 downto 0);
	
	------------------- CONCAT -------------------
	concat_input 	<= shift_left_pc_output;
	concat_pc 		<= pc_output(31 downto 28);
	
	--------------- SHIFT LEFT PC ----------------
	shift_left_pc_input <= inst_reg_out_25_0;
	
	----------------- REG A MUX ------------------
	reg_a_mux_sel 	<= aluSrcA;
	reg_a_mux_a 	<= pc_output;
	reg_a_mux_b 	<= reg_a_output;
	
	---------------- REGISTER A ------------------
	reg_a_en 	<= '1';
	reg_a_input <= reg_file_rd_data0;
	
	----------------- REG B MUX ------------------
	reg_b_mux_sel 	<= aluSrcB;
	reg_b_mux_a		<= reg_b_output;
	reg_b_mux_b		<= C4;
	reg_b_mux_c		<= sign_extended_output;
	reg_b_mux_d 	<= shift_left_sign_output;
	
	----------------- REGISTER B -----------------
	reg_b_en 	<= '1';
	reg_b_input <= reg_file_rd_data1;
	
	-------------- SHIFT LEFT SIGN ---------------
	shift_left_sign_input <= sign_extended_output;
	
	---------------- SIGN EXTEND -----------------
	sign_extended_en 	<= isSigned;
	sign_extended_input <= inst_reg_out_15_0;
	
	--------------- REGISTER FILE ----------------
	reg_file_JumpAndLink 	<= jumpAndLink;
	reg_file_rd_addr0 		<= inst_reg_out_25_21;
	reg_file_rd_addr1 		<= inst_reg_out_20_16;
	reg_file_wr_addr 		<= write_reg_mux_output(4 downto 0);
	reg_file_wr_data 		<= write_data_mux_output;
	reg_file_wr_en 			<= regWrite;
	
	--------------- WRITE REG MUX ----------------
	write_reg_mux_sel 			 <= regDst;
	write_reg_mux_a(4 downto 0)  <= inst_reg_out_20_16; -- make the slice fit
	write_reg_mux_a(31 downto 5) <= (others => '0');
	write_reg_mux_b(4 downto 0)  <= inst_reg_out_15_11; -- make the slice fit
	write_reg_mux_b(31 downto 5) <= (others => '0');
	
	--------------- WRITE DATA MUX ----------------
	write_data_mux_sel 	<= memToReg;
	write_data_mux_a 	<= alu_out_mux_output;
	write_data_mux_b 	<= mem_data_reg_output;
	
	-------------- MEMORY DATA REG ----------------
	mem_data_reg_en 	<= '1';
	mem_data_reg_input 	<= mem_block_mem_out;
	
	------------ INSTRUCTION REGISTER -------------
	inst_reg_ir_write	<= irWrite;
	inst_reg_data 		<= mem_block_mem_out;
	
	--------------- MEMORY BLOCK ------------------
	mem_block_mem_in		  <= mem_block_mux_output;
	mem_block_reg_b_data	  <= reg_b_output;
	mem_block_mem_wr_en		  <= memWrite;
	mem_block_mem_rd_en		  <= memRead;
	mem_block_user_in_port_en <= in_port_sel;
	mem_block_in_port_data 	  <= in_port;
	
	-------------- MEMORY BLOCK MUX ----------------
	mem_block_mux_sel 	<= iOrD;
	mem_block_mux_a		<= pc_output;
	mem_block_mux_b 	<= alu_out_output;
	
	---------------- RESET OUTPUTS -----------------
	process(rst)
	begin
		if (rst = '1') then
			out_port <= (others => '0');
		end if;
	end process;
	
end STR;