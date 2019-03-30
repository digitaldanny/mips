library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    WIDTH : positive := 8);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    input  : in  std_logic_vector(WIDTH-1 downto 0);
    output : out std_logic_vector(WIDTH-1 downto 0));
end reg;

architecture BHV of reg is
begin
  
  process(clk,rst)
  begin
  	
  	-- default values on reset
    if (rst = '1') then
      output <= (others => '0');     
       
    elsif (clk'event and clk='1') then
      output <= input;
            
    end if;    
  end process;

end BHV;