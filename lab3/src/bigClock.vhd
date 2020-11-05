--Library and package part
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bigClock is
generic ( TC:natural:=59; N_bits:natural:=4 );

port (
	   key0:in std_logic;----start counter	
		key1:in std_logic;----reset counter
		clk: in std_logic;----clock
		TC:  out std_logic;----count period
		hex0 :out std_logic_vector (6 downto 0)---led0 		
		);
end bigClock;



architecture top_level of bigClock is
   
	signal counter : std_logic_vector(N_bits-1 downto 0):=(others=>'0');
	
	

begin
	label_counter: process(all)	
	begin
    

	if rising_edge(clk) then
		TC<='0';
	if(key1='1') then ---reset
	counter<=(others=>'0');
	elsif counter=TC then 
	counter<=(others=>'0');
	TC<='1';
	elsif key0='1' then
	
	    counter <= counter+'1';
	
	end if ;
	
  
	end if;
		




end process;

 

With counter select



hex0 <=  "1000000" when "0000" ,  --0
         "1111001" when "0001" ,  --1
         "0100100" when "0010" ,  --2
         "0110000" when "0011" ,  --3
         "0011001" when "0100" ,  --4
         "0010010" when "0101" ,  --5
         "0000010" when "0110" ,  --6
         "1111000" when "0111" ,  --7
         "0000000" when "1000" ,  --8
         "0010000" when "1001" , --9  
			"1111001" when others;
			
			
			
			
			
			
			
	
end architecture  top_level ;
			


