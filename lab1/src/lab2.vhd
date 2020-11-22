--Library and package part
library ieee;
use ieee.std_logic_1164.all;



--entity description
entity lab2 is
  port(
    x:in std_logic_vector(3 downto 0);
    a:out std_logic;
    b:out std_logic;
    c:out std_logic;
    d:out std_logic;
    e:out std_logic;
    f:out std_logic;
    g:out std_logic);
end lab2;
architecture Behavioral of lab2 is 
 begin
 process(x)
 variable decode_data: std_logic_vector(6 down to 0);
 begin
 case x is //hex input
 when "0000" => decode_data :="1111110"   ---0
 when "0001" => decode_data :="0110000"   ---1
 when "0010" => decode_data :="1101101"   ---2
 when "0011" => decode_data :="1111001"   ---3
 when "0100" => decode_data :="0110011"   ---4
 when "0101" => decode_data :="1011011"   ---5
 when "0110" => decode_data :="1011111"   ---6

 when "0111" => decode_data :="1110000"   ---7
 when "1000" => decode_data :="1111111"   ---8
 when "1001" => decode_data :="1111011"   ---9
 when "1010" => decode_data :="1110111"   ---A
 when "1011" => decode_data :="0011111"   ---B
 when "1100" => decode_data :="1001110"   ---C
 when "1101" => decode_data :="0111101"   ---D
 when "1110" => decode_data :="1001111"   ---E
 when "1111" => decode_data :="1000111"   ---F
 when others => decode_data :="0111110"   ----Error 'H'
 end case;
 a<= not decode_data(6);
 b<= not decode_data(5);
 c<= not decode_data(4);
 d<= not decode_data(3);
 e<= not decode_data(2);
 f<= not decode_data(1);
 g<= not decode_data(0);
 end process;
 end Behavioral;   


  
 
  
