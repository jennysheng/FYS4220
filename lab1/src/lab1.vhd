--Library and package part
library ieee;
use ieee.std_logic_1164.all;



--entity description
entity lab1 is
  port(
    sw:in std_logic_vector(9 downto 0);
    led:out std_logic_vector(9 downto 0)
);

  
 end entity lab1;

--architecture
  architecture func of lab1 is
    --declaration area
  begin
    led <= sw;


    
  end architecture;
  
