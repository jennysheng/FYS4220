library IEEE;
use IEEE.std_logic_1164.all;

entity lab3_tb is
end entity lab3_tb;


architecture testbench of lab3_tb is


  -- Signal declarations
  -- The clk related signals is provided as an example
  signal   clk        : std_logic;
  signal   clk_ena    : boolean;
  constant clk_period : time := 20 ns;  -- 50 MHz



  signal arst_n    : std_logic;
  signal ext_ena_n : std_logic;
  signal led       : std_logic_vector(9 downto 0);
  signal sw        : std_logic_vector(9 downto 0);
  signal hex0      : std_logic_vector(7 downto 0);



begin



-- Direct instantiation of lab1 component
  lab3_i : entity work.lab3
    port map (
      clk       => clk,
      arst_n    => arst_n,
      ext_ena_n => ext_ena_n,
      led       => led,
      sw        => sw,
      hex0      => hex0
      );

-- create a 50 MHz clock
-- The clk signal can be disabled or enabled by the clk_ena signal
  clk <= not clk after clk_period/2 when clk_ena else '0';



  stimuli_process : process
  begin
    --set default values
    clk_ena   <= false;
    arst_n    <= '1';
    ext_ena_n <= '1';
    sw        <= "0101010101";

    --enable clk and wait for 3 clk periods
    clk_ena <= true;
    wait for 3*clk_period;

    --assert arst_n for 3 clk periods
    arst_n <= '0';
    wait for 3*clk_period;

    --deassert arst_n for 3 clk periods
    arst_n <= '1';
    wait for 3*clk_period;

    --enable counter and wait for 20 clk_periods
    ext_ena_n <= '0';
    wait for 20*clk_period;

    --disable counter and wait for 5 clk_periods
    ext_ena_n <= '1';
    wait for 5*clk_period;

    --assert arst_n for 3 clk periods
    arst_n <= '0';
    wait for 3*clk_period;

    --deassert arst_n for 10 clk periods
    arst_n <= '1';
    wait for 3*clk_period;

    --disable clk
    clk_ena <= false;

    --end of simulation
    wait;


  end process stimuli_process;


end architecture;