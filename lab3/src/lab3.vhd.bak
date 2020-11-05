--Library and package part
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is

port (
	   key0:in std_logic;----start counter
		clk: in std_logic;
		key1:in std_logic;----reset counter
      hex0 :out std_logic_vector (6 downto 0)---led0 		
		);
end lab3;



architecture top_level of lab3 is
	signal counter : std_logic_vector(3 downto 0):="0000";

begin
	label_counter: process(key0, key1, clk)	
	begin
    
	if(key1='1') then---  reset
	counter <="0000";
	elsif(key0'event and key0='1') then
	if rising_edge(clk) then
      counter <= counter+1;
		end if;
		

end if;


end process;

 

with counter select 



hex0 <=  "1000000" when "0000" ,  --0
         "1111001" when "0001" ,  --1
         "0100100" when "0010" ,  --2
         "0110000" when "0011" ,  --3
         "0011001" when "0100" ,  --4
         "0010010" when "0101" ,  --5
         "0000010" when "0110" ,  --6
         "1111000" when "0111" ,  --7
         "0000000" when "1000" ,  --8
         "0010000" when "1001" ;  --9  
	
end architecture  top_level ;
			


