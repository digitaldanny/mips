library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mips_lib.all;

-- This component links together a 256 word chunk of RAM 
-- plus 2 32-bit wide input registers and 1 32-bit wide
-- output register.

-- Author		: Daniel Hamilton
-- Creation 	: 4/1/2019
-- Last Edit 	: 4/1/2019

-- UPDATES
-- 3/29/2019	: Component initialization. 
-- 4/1/2019		: Added input/output port registers and mux to determine what
--				: should be output from the memory block based on controller 
--				: signals.

entity MEMORY_BLOCK is
	generic (
		WIDTH : positive := 32
	);
	port (
		clk 		: in std_logic;
		rst 		: in std_logic;

		-- MUX THESE INPUTS
		in_port_data	: in std_logic_vector(WIDTH-1 downto 0);
		mem_in			: in std_logic_vector(WIDTH-1 downto 0); -- only use 9 downto 2 for addressing
		mem_out			: out std_logic_vector(WIDTH-1 downto 0);
		
		mem_rd_en		: in std_logic;
		mem_wr_en		: in std_logic;		
		user_in_port_en : in std_logic;
		
		-- OUTPUT NEW REGB DATA IF OUTPUT PORT ENABLED
		reg_b_data	: in std_logic_vector(WIDTH-1 downto 0); -- data comes from register B		
		out_port	: out std_logic_vector(WIDTH-1 downto 0)
	);
end MEMORY_BLOCK;

architecture BHV of MEMORY_BLOCK is
	signal sram_out 	: std_logic_vector(WIDTH-1 downto 0);
	signal port0_data 	: std_logic_vector(WIDTH-1 downto 0);
	signal port1_data 	: std_logic_vector(WIDTH-1 downto 0);
	signal out_port_en	: std_logic;
	signal sram_wren 	: std_logic;
	signal in_port_en	: std_logic;
	signal in_port_en_n	: std_logic;
begin
	
	U_RAM : entity work.ram
		port map(
			address => mem_in(9 downto 2),
			clock   => clk,
			data    => reg_b_data,
			wren    => sram_wren,
			q       => sram_out
		);
		
	U_PORT0_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => in_port_en_n, -- on low input
			input  => in_port_data,			-- only loaded into register on low select
			output => port0_data
		);
		
	U_PORT1_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => in_port_en,	-- on high select
			input  => in_port_data,		-- only loaded into register on high select
			output => port1_data
		);
		
	U_PORT_OUT_REG : entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk    => clk,
			rst    => rst,
			en     => out_port_en,
			input  => reg_b_data,
			output => out_port
		);
		
	-- COMBIN. LOGIC -----------------------------------------------------------------
	in_port_en 		<= user_in_port_en;
	in_port_en_n 	<= not(user_in_port_en);
		
	-- MEMORY IN WRITE HANDLING ------------------------------------------------------
	process ( mem_in, mem_wr_en )
	begin
		
		-- defaults do not allow memory to be written
		out_port_en <= '0';
		sram_wren <= '0';
		
		-- "FFFC" = outport ( WRITE TO THE OUTPORT )
		if ( mem_wr_en = '1' and unsigned(mem_in) = unsigned(MEM_OUTPORT) ) then
			out_port_en <= '1';
			
		-- "Address range 9 downto 2" = ( WRITE TO THE SRAM )
		elsif ( mem_wr_en = '1' ) then
			sram_wren <= '1';
			
		end if;
		
	end process;
	
	-- MEMORY OUT READ HANDLING -------------------------------------------------------
	process( mem_in, mem_rd_en, sram_out, port0_data, port1_data )
	begin
		
		-- defaults do not allow latches to be inferred for memory output
		mem_out <= X"DEADBEEF";
			
		-- "FFF8" = inport0 ( READ FROM THE INPORT )
		if ( mem_rd_en = '1' and unsigned(mem_in) = unsigned(MEM_INPORT0) ) then
			mem_out <= port0_data;
			
		-- "FFFC" = inport1 ( READ FROM THE INPORT )
		elsif ( mem_rd_en = '1' and unsigned(mem_in) = unsigned(MEM_INPORT1) ) then
			mem_out <= port1_data;
			
		-- "Address range 9 downto 2" = ( READ FROM THE SRAM )
		elsif ( mem_rd_en = '1' ) then
			mem_out <= sram_out;
			
		end if;
		
	end process;
	
end BHV;