--Library and package part
library ieee;
use ieee.std_logic_1164.all;

entity lab2 is

port (D    :in std_logic_vector  (3 downto 0); 
      hex0 :out std_logic_vector (6 downto 0);---led0
		hex1 :out std_logic_vector (6 downto 0);---led1
		hex2 :out std_logic_vector (6 downto 0);---led2
      hex3 :out std_logic_vector (6 downto 0);---led3
		hex4 :out std_logic_vector (6 downto 0);---led4
		hex5 :out std_logic_vector (6 downto 0)	---led5	
		);

end lab2;


architecture behavior of lab2 is

begin

hex0 <=  "1000000" when D="0000" else  
         "1111001" when D="0001" else  --1
         "0100100" when D="0010" else  --2
         "0110000" when D="0011" else  --3
         "0011001" when D="0100" else  --4
         "0010010" when D="0101" else  --5
         "0000010" when D="0110" else  --6
         "1111000" when D="0111" else  --7
         "0000000" when D="1000" else  --8
         "0010000" ;                   --9
			
hex1 <=  "1000000" when D="0000" else  --0
         "1111001" when D="0001" else  --1
         "0100100" when D="0010" else  --2
         "0110000" when D="0011" else  --3
         "0011001" when D="0100" else  --4
         "0010010" when D="0101" else  --5
         "0000010" when D="0110" else  --6
         "1111000" when D="0111" else  --7
         "0000000" when D="1000" else  --8
         "0010000" ; 
hex2 <= "1000000"  when D="0000" else  
         "1111001" when D="0001" else  
         "0100100" when D="0010" else  
         "0110000" when D="0011" else  
         "0011001" when D="0100" else 
         "0010010" when D="0101" else 
         "0000010" when D="0110" else  
         "1111000" when D="0111" else 
         "0000000" when D="1000" else  
         "0010000" ; 
hex3	<= "1000000" when D="0000" else  
         "1111001" when D="0001" else  
         "0100100" when D="0010" else  
         "0110000" when D="0011" else  
         "0011001" when D="0100" else  
         "0010010" when D="0101" else 
         "0000010" when D="0110" else  
         "1111000" when D="0111" else  
         "0000000" when D="1000" else  
         "0010000" ; 
hex4  <= "1000000" when D="0000" else  
         "1111001" when D="0001" else  
         "0100100" when D="0010" else  
         "0110000" when D="0011" else  
         "0011001" when D="0100" else  
         "0010010" when D="0101" else  
         "0000010" when D="0110" else  
         "1111000" when D="0111" else  
         "0000000" when D="1000" else  
         "0010000" ; 
hex5  <= "1000000" when D="0000" else  
         "1111001" when D="0001" else  
         "0100100" when D="0010" else  
         "0110000" when D="0011" else  
         "0011001" when D="0100" else  
         "0010010" when D="0101" else  
         "0000010" when D="0110" else  
         "1111000" when D="0111" else  
         "0000000" when D="1000" else  
         "0010000" ; 
			
			
			

 end architecture;
