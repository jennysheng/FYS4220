library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab3 is
  port (
    clk       : in  std_logic;
    arst_n    : in  std_logic;          -- external active low reset key0
    ext_ena_n : in  std_logic;          -- external active low enable key1
    led       : out std_logic_vector(9 downto 0);  -- Red LEDs
    sw        : in  std_logic_vector(9 downto 0);  -- Switches
    hex0      : out std_logic_vector(7 downto 0)   -- 7-segment display
    );
end entity lab3;

architecture top_level of lab3 is

  signal counter       : unsigned(3 downto 0);
  -- Internal signal to synchronize and input signal and to perform edge detection
  signal int_ena_n_r   : std_logic;     -- synchronization register 1
  signal int_ena_n_rr  : std_logic;     -- synchronization register 2
  signal int_ena_n_rrr : std_logic;     -- register used for edge detection

  signal ena_falling_edge : std_logic;  -- internal enable signal from falling

  -- Internal signals for the reset handling
  signal arst_n_r : std_logic;
  signal rst_n    : std_logic;

begin

  led <= sw;


  -- The process create an asynchronous assert of the reset
  -- but a synchronous deassert of the reset.
  p_rst_sync : process(arst_n, clk) is
  begin
    if arst_n = '0' then
      arst_n_r <= '0';
      rst_n    <= '0';
    elsif rising_edge(clk) then
      arst_n_r <= '1';
      rst_n    <= arst_n_r;
    end if;
  end process;


  -- Synchronize external asynchronous signal with the clk50 domain.
  -- Third register is used for edge detection
  p_sync : process(clk) is
  begin
    if rising_edge(clk) then
      int_ena_n_r   <= ext_ena_n;
      int_ena_n_rr  <= int_ena_n_r;
      int_ena_n_rrr <= int_ena_n_rr;
    end if;
  end process;

  -- This logic generates a pulse with the duration of one clock period
  -- and can be used to trigger the counter.
  ena_falling_edge <= (not int_ena_n_rr) and int_ena_n_rrr;

  -- Process implementing the counter logic
  p_counter : process(rst_n, clk) is
  begin
    if rst_n = '0' then
      counter <= (others => '0');
    elsif rising_edge(clk) then
      if ena_falling_edge = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;


  --- with sw(3 downto 0) select
  with counter select
    hex0 <= "01000000" when "0000",     --0000
    "01111001"         when "0001",     --1
    "00100100"         when "0010",     --2
    "00110000"         when "0011",     --3
    "00011001"         when "0100",     --4
    "00010010"         when "0101",     --5
    "00000010"         when "0110",     --6
    "01111000"         when "0111",     --7
    "00000000"         when "1000",     --8
    "00010000"         when "1001",     --9
    "00001000"         when "1010",     --A
    "00000011"         when "1011",     --b
    "01000110"         when "1100",     --C
    "00100001"         when "1101",     --d
    "00000110"         when "1110",     --E
    "00001110"         when "1111",     --F
    "01111111"         when others;

end architecture top_level;