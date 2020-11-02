--Library and package part
library ieee;
use ieee.std_logic_1164.all;

entity lab2 is

port (sw    :in std_logic_vector  (9 downto 0); 
	

      
      hex0 :out std_logic_vector (6 downto 0);---led0
		hex1 :out std_logic_vector (6 downto 0);---led1
		hex2 :out std_logic_vector (6 downto 0);---led2
      hex3 :out std_logic_vector (6 downto 0);---led3
		hex4 :out std_logic_vector (6 downto 0);---led4
		hex5 :out std_logic_vector (6 downto 0) ---led5
	  
    
		
		);

end lab2;


architecture behavior of lab2 is

begin

 

	 with sw(3 downto 0) select 


hex0 <=  "1000000" when "0000" ,  --0
         "1111001" when "0001" ,  --1
         "0100100" when "0010" ,  --2
         "0110000" when "0011" ,  --3
         "0011001" when "0100" ,  --4
         "0010010" when "0101" ,  --5
         "0000010" when "0110" ,  --6
         "1111000" when "0111" ,  --7
         "0000000" when "1000" ,  --8
         "0010000" when "1001";   --9  
        		
			

			
			
			

 end architecture;
