library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

-- PROVIDED BY GREG STITT

-- UPDATES:
-- 1. 	included an enable signal to determine when
-- 		an input should be saved or not.

entity reg is
  generic (
    WIDTH : positive := 8);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en	   : in  std_logic;
    input  : in  std_logic_vector(WIDTH-1 downto 0);
    output : out std_logic_vector(WIDTH-1 downto 0));
end reg;

architecture BHV of reg is
	signal store : std_logic_vector(WIDTH-1 downto 0);
begin
  
  process(clk,rst)
  begin
  	
  	-- default values on reset
    if (rst = '1') then
      store <= (others => '0');     
       
    -- only change the stored value if the 
    -- enable is set.
  	elsif (clk'event and clk='1') then
  		if ( en = '1' ) then
  			store <= input;
  		end if;
            
    end if;    
end process;

	output <= store; -- only updates on rst or on enable

end BHV;