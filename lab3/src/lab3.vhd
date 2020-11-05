--Library and package part
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lab3 is


port (
	   key0:in std_logic;----start counter	
		key1:in std_logic;----reset counter
		clk: in std_logic;----clock
		TC:  out std_logic;----count period
		hex0 :out std_logic_vector (6 downto 0)---led0 		
		);
end lab3;



architecture top_level of lab3 is
   
 signal TC_PRE_TO_S_COUNTER:std_logic:=(others=>'0');
 signal Count_out_to_output:std_logic_vector(5 downto 0 ):=(others=>'0');
begin

			Prescaler: entity.work.bigClock
			GENERIC MAP(TC=> 500000000,
			N_BITS=>26)
			PORT MAP(
			clk=>clk,
			key0=>'1',
			key1=>key1,
			TC=>TC_PRE_TO_S_COUNTER,
			hex0=>open
			);
			
			
			
			
			Counter_60_s: entity.work.bigClock
			GENERIC MAP(TC=> 60,
			N_BITS=>6)
			PORT MAP(
			clk=>clk,
			key0=>TC_PRE_TO_S_COUNTER,
			key1=>key1,
			TC=>open,
			hex0=>Count_out_to_output,
			);
			
			
	
end  top_level ;
			


