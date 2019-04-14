library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity MIPS_CONTROLLER is
	port ( 
	-- controller ports
	clk : in std_logic;
	rst : in std_logic;
	
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
	
	type STATE_T is ( S_GO, S_PROCESS, S_DONE );
	signal state : STATE_T;
	signal next_state : STATE_T;
	
begin  
	
	-- STATE SWITCHING PROCESS ---------------------------------------------
	process(clk, rst)
	begin
		
		if ( rst = '1' ) then
			state <= S_GO;
		elsif ( rising_edge(clk) ) then
			state <= next_state;
		end if;
		
	end process;
	
	-- CONTROLLER STATE MACHINE --------------------------------------------
	process(go, state )
	begin
		
			case state is
				
			when S_GO =>
			
				if (go = '0') then
					next_state <= S_GO;
				else
					next_state <= S_PROCESS;
				end if;
				
			when S_PROCESS =>
				
				if ( x_ne_y = '1' ) then
					next_state <= S_PROCESS;
				else
					next_state <= S_DONE;
				end if;
					
			when S_DONE =>
				
				if (go = '0') then
					next_state <= S_GO;
				else 
					next_state <= S_DONE;
				end if;
				
			end case;
			
	end process;
	
end BHV;