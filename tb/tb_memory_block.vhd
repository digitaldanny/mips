library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Author		: Daniel Hamilton
-- Creation 	: 4/2/2019
-- Last Edit 	: 4/2/2019

-- ==========================================================
-- This testbench determines whether the memory block with
-- SRAM, input ports 0/1, and the output port can read and 
-- write data correctly.

-- TESTBENCH DESCRIPTION:
-- Write 0x0A0A0A0A to address 0x00000000
-- Write 0xF0F0F0F0 to address 0x00000004
-- Read from address 0x00000000 to show 0x0A0A0A0A on mem_out
-- Read from address 0x00000001 to show 0x0A0A0A0A on mem_out
-- Read from address 0x00000004 to show 0xF0F0F0F0 on mem_out
-- Read from address 0x00000005 to show 0xF0F0F0F0 on mem_out
-- Write 0x00001111 to the outport
-- Load 0x00010000 on inport 0
-- Load 0x00000001 on inport 1
-- Read from inport 0 to show 0x00010000 on mem_out
-- Read from inport 1 to show 0x00000001 on mem_out
-- ==========================================================

-- ==========================================================
-- UPDATES
-- 3/29/2019	: Testbench initialization.
-- ========================================================== 

entity TB_ALU_MEMORY_BLOCK is
end TB_ALU_MEMORY_BLOCK;

architecture TB of TB_ALU_MEMORY_BLOCK is
	
	constant WIDTH : positive := 32;
	
	signal clk             : std_logic;
	signal rst             : std_logic;
	signal in_port_data    : std_logic_vector(WIDTH-1 downto 0);
	signal mem_in          : std_logic_vector(WIDTH-1 downto 0);
	signal mem_out         : std_logic_vector(WIDTH-1 downto 0);
	signal mem_rd_en       : std_logic;
	signal mem_wr_en       : std_logic;
	signal user_in_port_en : std_logic;
	signal reg_b_data      : std_logic_vector(WIDTH-1 downto 0);
	signal out_port        : std_logic_vector(WIDTH-1 downto 0);
	   
	signal count_unsigned : unsigned(31 downto 0) := X"00000000";
begin
	
	UUT : entity work.MEMORY_BLOCK
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk             => clk,
			rst             => rst,
			in_port_data    => in_port_data,
			mem_in          => mem_in,
			mem_out         => mem_out,
			mem_rd_en       => mem_rd_en,
			mem_wr_en       => mem_wr_en,
			user_in_port_en => user_in_port_en,
			reg_b_data      => reg_b_data,
			out_port        => out_port
		);
		
	-- clock process for the main testbench
	process
	begin
		
		for i in 1 to 1200 loop
			if ( clk = '0' ) then
				clk <= '1';
			else
				clk <= '0';
			end if;
			wait for 10 ns;	
		end loop;
		
		wait;
	end process;
	
	-- main testbench process
	process (clk, count_unsigned)
	begin
		
		-- reset for to correctly initialize the system
		if ( count_unsigned < to_unsigned(10, 32) ) then
			rst <= '1';
			in_port_data <= (others => '0');
			mem_in <= (others => '0');
			reg_b_data <= (others => '0');
			user_in_port_en <= '0';
			mem_wr_en <= '0';
			mem_rd_en <= '0';
		
		-- write to the address (STORE 0x0A0A0A0A to mem(0x00000000))
		elsif ( count_unsigned < to_unsigned(50, 32 ) ) then 
			rst <= '0';
			mem_in <= X"00000000"; 
			reg_b_data <= X"0A0A0A0A";
			mem_wr_en <= '1';
			mem_rd_en <= '0';
		
		-- write to the address (STORE 0xF0F0F0F0 to mem(0x00000004))
		elsif ( count_unsigned < to_unsigned(100, 32 ) ) then 
			mem_in <= X"00000004"; 
			reg_b_data <= X"F0F0F0F0";
			mem_wr_en <= '1';
			mem_rd_en <= '0';
		
		-- test SRAM read functionality (MEM_OUT = 0x0A0A0A0A)
		elsif ( count_unsigned < to_unsigned(150, 32 ) ) then 
			mem_in <= X"00000000";
			mem_rd_en <= '1';
			mem_wr_en <= '0';
		
		-- test SRAM read functionality (MEM_OUT = 0x0A0A0A0A)
		elsif ( count_unsigned < to_unsigned(200, 32 ) ) then 
			mem_in <= X"00000001";
			mem_rd_en <= '1';
			mem_wr_en <= '0';
		
		-- test SRAM read functionality (MEM_OUT = 0xF0F0F0F0)
		elsif ( count_unsigned < to_unsigned(250, 32 ) ) then 
			mem_in <= X"00000004"; 
			mem_rd_en <= '1';
			mem_wr_en <= '0';
		
		-- test SRAM read functionality (MEM_OUT = 0xF0F0F0F0)
		elsif ( count_unsigned < to_unsigned(300, 32 ) ) then 
			mem_in <= X"00000005"; 
			mem_rd_en <= '1';
			mem_wr_en <= '0';
		
		-- write to the outport (STORE 0x00001111 to mem(0x0000FFF8))
		elsif ( count_unsigned < to_unsigned(350, 32 ) ) then 
			mem_in <= X"0000FFFC"; 
			reg_b_data <= X"00001111";
			mem_wr_en <= '1';
			mem_rd_en <= '0';
		
		-- load inport0 with data functionality (LOAD 0x00010000 to INPORT0)
		elsif ( count_unsigned < to_unsigned(400, 32 ) ) then 			
			mem_in <= X"0000FFF8"; 
			user_in_port_en <= '0'; -- choose port 0
			in_port_data <= X"00010000";
			
			-- clear previous signals
			mem_wr_en <= '0';
			reg_b_data <= X"DEADBEEF";
		
		-- load inport1 with data functionality (LOAD 0x00000001 to INPORT1)
		elsif ( count_unsigned < to_unsigned(450, 32 ) ) then 
			mem_in <= X"0000FFFC"; 
			user_in_port_en <= '1'; -- choose port 1
			in_port_data <= X"00000001";
		
		-- read from inport 0 (READ 0x00010000 from INPORT0)
		elsif ( count_unsigned < to_unsigned(500, 32 ) ) then 
			mem_in <= X"0000FFF8"; 
			mem_rd_en <= '1';
			mem_wr_en <= '0';
		
		-- read from inport 0 (READ 0x00010000 from INPORT0)
		elsif ( count_unsigned < to_unsigned(550, 32 ) ) then 
			mem_in <= X"0000FFFC"; 
			mem_rd_en <= '1';
			mem_wr_en <= '0';
		end if;
		
		-- use the clock to count up
		if ( rising_edge(clk) ) then
			count_unsigned <= count_unsigned + to_unsigned(1, 32);
		end if;
		
	end process;
	
end TB;