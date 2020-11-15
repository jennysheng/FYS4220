library ieee;
use ieee.std_logic_1164.all;

entity i2c_master_tb is
end entity;

architecture tb of i2c_master_tb is

	signal clk       : std_logic;
	signal arst_n    : std_logic;
	signal valid     : std_logic;
	signal addr      : std_logic_vector(6 downto 0);
	signal rnw       : std_logic;
	signal data_wr   : std_logic_vector(7 downto 0);
	signal data_rd   : std_logic_vector(7 downto 0);
	signal busy      : std_logic;
	signal ack_error : std_logic;
   signal sda       : std_logic;
	signal scl       : std_logic;
	 signal state_ena       : std_logic;
	signal scl_high_ena      : std_logic;

   signal clk_ena       : boolean:=false ;
	signal clk_period    : time := 20 ns;

  constant GC_SYSTEM_CLK : integer := 50_000_000;
  constant GC_I2C_CLK    : integer := 200_000;
  constant C_SCL_PERIOD  : time := clk_period*(GC_SYSTEM_CLK/GC_I2C_CLK);

begin
  UUT : entity work.i2c_master
--    generic map (
--		GC_SYSTEM_CLK => GC_SYSTEM_CLK,
--      GC_I2C_CLK    => GC_I2C_CLK)
    port map (
      clk       => clk,
		clk_ena   => clk_ena,
      arst_n    => arst_n,
      valid     => valid,
      addr      => addr,
      rnw       => rnw,
      data_wr   => data_wr,
      data_rd   => data_rd,
      busy      => busy,
      ack_error => ack_error,
      sda       => sda,
      scl       => scl,
		state_ena  => state_ena  ,
		scl_high_ena=>scl_high_ena
		
		
		);

--create clk
  clk <= not clk after clk_period/2 when clk_ena else '0';

-- sequencer
  p_seq : process
  begin
    -- Start clk
    clk_ena <= true;
    arst_n <= '1';
    -- Reset circuit
    wait until clk = '1';
    arst_n <= '0';
    wait for clk_period*5;
    arst_n <= '1';
    wait for C_SCL_PERIOD*2;
    clk_ena <= false;
    wait;
  end process;
end architecture tb;