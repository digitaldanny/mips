library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component instiantiates the mips datapath and controller
-- so they can communicate with each other and be used as a complete
-- CPU.

-- Author		: Daniel Hamilton
-- Creation 	: 4/14/2019
-- Last Edit 	: 4/14/2019

-- UPDATES
-- 4/14/2019	: Component initialization. 

entity MIPS_TOP_LEVEL is
	generic (
		WIDTH : positive := 32
	);
	port (
		clk			: in std_logic;
		rst			: in std_logic;
		
		in_port_en	: in std_logic;
		in_port_sel : in std_logic;
		in_port     : in std_logic_vector(WIDTH-1 downto 0);
		out_port    : out std_logic_vector(WIDTH-1 downto 0)
	);
end MIPS_TOP_LEVEL;

architecture STR of MIPS_TOP_LEVEL is
	
	-- DATAPATH SIGNALS ------------------------------------------
	signal datapath_pcWrite     : std_logic;
	signal datapath_pcWriteCond : std_logic;
	signal datapath_iOrD        : std_logic;
	signal datapath_memRead     : std_logic;
	signal datapath_memWrite    : std_logic;
	signal datapath_memToReg    : std_logic;
	signal datapath_irWrite     : std_logic;
	signal datapath_jumpAndLink : std_logic;
	signal datapath_isSigned    : std_logic;
	signal datapath_pcSource    : std_logic_vector(1 downto 0);
	signal datapath_aluOp       : std_logic_vector(5 downto 0);
	signal datapath_aluSrcA     : std_logic;
	signal datapath_aluSrcB     : std_logic_vector(1 downto 0);
	signal datapath_regWrite    : std_logic;
	signal datapath_regDst      : std_logic;
	signal datapath_op_code     : std_logic_vector(5 downto 0);
	signal datapath_clk         : std_logic;
	signal datapath_rst         : std_logic;
	signal datapath_in_port_en	: std_logic;
	signal datapath_in_port_sel : std_logic;
	signal datapath_in_port     : std_logic_vector(WIDTH-1 downto 0);
	signal datapath_out_port    : std_logic_vector(WIDTH-1 downto 0);
	signal datapath_mem_out_delay : std_logic;
	
	-- CONTROLLER SIGNALS ----------------------------------------
	signal controller_pcWrite     : std_logic;
	signal controller_pcWriteCond : std_logic;
	signal controller_iOrD        : std_logic;
	signal controller_memRead     : std_logic;
	signal controller_memWrite    : std_logic;
	signal controller_memToReg    : std_logic;
	signal controller_irWrite     : std_logic;
	signal controller_jumpAndLink : std_logic;
	signal controller_isSigned    : std_logic;
	signal controller_pcSource    : std_logic_vector(1 downto 0);
	signal controller_aluOp       : std_logic_vector(5 downto 0);
	signal controller_aluSrcA     : std_logic;
	signal controller_aluSrcB     : std_logic_vector(1 downto 0);
	signal controller_regWrite    : std_logic;
	signal controller_regDst      : std_logic;
	signal controller_op_code     : std_logic_vector(5 downto 0);
	signal controller_clk         : std_logic;
	signal controller_rst         : std_logic;
	signal controller_mem_out_delay : std_logic;

begin
	
	U_DATAPATH : entity work.MIPS_DATAPATH
		generic map(
			WIDTH => WIDTH
		)
		port map(
			pcWrite     => datapath_pcWrite,
			pcWriteCond => datapath_pcWriteCond,
			iOrD        => datapath_iOrD,
			memRead     => datapath_memRead,
			memWrite    => datapath_memWrite,
			memToReg    => datapath_memToReg,
			irWrite     => datapath_irWrite,
			jumpAndLink => datapath_jumpAndLink,
			isSigned    => datapath_isSigned,
			pcSource    => datapath_pcSource,
			aluOp       => datapath_aluOp,
			aluSrcA     => datapath_aluSrcA,
			aluSrcB     => datapath_aluSrcB,
			regWrite    => datapath_regWrite,
			regDst      => datapath_regDst,
			op_code     => datapath_op_code,
			clk         => clk,
			rst         => rst,
			in_port_en  => datapath_in_port_en,
			in_port_sel => datapath_in_port_sel,
			in_port     => datapath_in_port,
			out_port    => datapath_out_port,
			mem_out_delay => datapath_mem_out_delay
		);
		
	U_CONTROLLER : entity work.MIPS_CONTROLLER
		port map(
			clk         => clk,
			rst         => rst,
			op_code     => controller_op_code,
			pcWrite     => controller_pcWrite,
			pcWriteCond => controller_pcWriteCond,
			iOrD        => controller_iOrD,
			memRead     => controller_memRead,
			memWrite    => controller_memWrite,
			memToReg    => controller_memToReg,
			irWrite     => controller_irWrite,
			jumpAndLink => controller_jumpAndLink,
			isSigned    => controller_isSigned,
			pcSource    => controller_pcSource,
			aluOp       => controller_aluOp,
			aluSrcA     => controller_aluSrcA,
			aluSrcB     => controller_aluSrcB,
			regWrite    => controller_regWrite,
			regDst      => controller_regDst,
			mem_out_delay => controller_mem_out_delay
		);
		
	-- SIGNAL CONNECTIONS ---------------------------------------------
	datapath_pcWrite     <= controller_pcWrite;
	datapath_pcWriteCond <= controller_pcWriteCond;
	datapath_iOrD        <= controller_iOrD;       
	datapath_memRead     <= controller_memRead;    
	datapath_memWrite    <= controller_memWrite;   
	datapath_memToReg    <= controller_memToReg;   
	datapath_irWrite     <= controller_irWrite;    
	datapath_jumpAndLink <= controller_jumpAndLink;
	datapath_isSigned    <= controller_isSigned;   
	datapath_pcSource    <= controller_pcSource;   
	datapath_aluOp       <= controller_aluOp;      
	datapath_aluSrcA     <= controller_aluSrcA;    
	datapath_aluSrcB     <= controller_aluSrcB;    
	datapath_regWrite    <= controller_regWrite;   
	datapath_regDst      <= controller_regDst;        
	datapath_clk         <= controller_clk;        
	datapath_rst         <= controller_rst;  
	
	controller_op_code   <= datapath_op_code;   
	controller_mem_out_delay <= datapath_mem_out_delay;    
	
	-- TOP LEVEL PORT CONNECTIONS -------------------------------------
	datapath_in_port_en  <= in_port_en;
	datapath_in_port_sel <= in_port_sel;
	datapath_in_port     <= in_port;
	out_port   		 	 <= datapath_out_port;
	
end STR;