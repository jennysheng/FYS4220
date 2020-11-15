library ieee;
use ieee.std_logic_1164.all;

entity i2c_masterJenny is


port(
  clk       in: std_logic;--system clock
  clk_ena   in: boolean := false;--system clock enable
  clk_period    in: time := 20 ns;--system clock peroid
  arst_n    in: std_logic;--asynchronous active low reset
  
  GSENSOR_CS_n      in: std_logic;--module enable - valid data on input --> start transaction
  GSENSOR_SDO in: std_logic;--address select 1:0x3A w; 0x3B R 0: 0xA6 W; 0xA7 R
  addr    in: std_logic_vector(6 downto 0);--I2C address of target slave select
  
  data_wr   in: std_logic_vector(7 downto 0);--	data to be written to slave
  data_rd   out: std_logic_vector(7 downto 0);--data read from slave
 
  ack_error out: std_logic;--	flagged if no acknowledge from slave
  
  sda       inout: std_logic;--bidirectional serial i2c data
  scl       inout: std_logic;--bidirectional serial i2c clock
 
);

architecture logic of i2c_masterJenny is

	signal clk           : std_logic;
	signal clk_ena       : boolean := false;
	signal clk_period    : time    := 20 ns;	
	signal arst_n        : std_logic;
	
	signal  GSENSOR_CS_n      : std_logic;
	signal  GSENSOR_SDO      : std_logic;
	signal  addr      : std_logic_vector(6 downto 0);

	signal data_wr   : std_logic_vector(7 downto 0);
	signal data_rd   : std_logic_vector(7 downto 0);
	
	signal ack_error : std_logic;
   signal sda       : std_logic;
	signal scl       : std_logic;
	

  

  constant GC_SYSTEM_CLK : integer := 50000000;--system clock in 50 MHz
  constant GC_I2C_CLK    : integer := 200000;--	I2C bus clock in 200k Hz
  constant C_SCL_PERIOD  : time    := clk_period*(GC_SYSTEM_CLK/GC_I2C_CLK);
  
   signal state_ena	 :std_logic;	--	enables state transition (duration 1 system clk cycle)
   signal scl_high_ena:std_logic;	-- enable signal used for START and STOP conditions,data sample, and acknowledge (duration 1 system clk cycle)
   signal scl_clk   : std_logic;--internal continuous running i2c clk signal

	
	
	
	
	
begin
  UUT : entity work.i2c_masterJenny
    generic map (
		GC_SYSTEM_CLK => GC_SYSTEM_CLK,
      GC_I2C_CLK    => GC_I2C_CLK)
    port map (
      clk       => clk,		
      arst_n    => arst_n,
		
      GSENSOR_CS_n  =>GSENSOR_CS_n,
		GSENSOR_SDO=> GSENSOR_SDO,
		
      addr      => addr,     
      data_wr   => data_wr,
      data_rd   => data_rd,
   
      ack_error => ack_error,
      sda       => sda,
      scl       => scl
		);



--create system clk
  clk <= not clk after clk_period/2 when clk_ena else '0';

 -------1.create internal SCL clock
--The scl_clk is derived from the 50 MHz system clock GC_SYSTEM_CLK. Use the internal variable cnt to control the correct timing of the scl_clk.
--scl_clk will be low for the first half part of its period and high for the second part of its period.
   signal scl_clk	    :std_logic_vector(C_SCL_PERIOD  downto 0);	-- internal continuous running i2c clk signal
  

  p_sclk : process(scl_clk, clk, arst_n)
  variable counter:=0;
  begin

    if arst_n = '0' then
	 counter:=0;
    scl_clk<='0';
    elsif rising_edge(clk) then
    counter:=counter+1;
    end if;
	 scl_clk<= not scl_clk after C_SCL_PERIOD/2 when GSENSOR_CS_n else'0';
  end process;
  
---2.Create the internal trigger/timing enable signals
--It is important that the duration of both of these enable signals must correspond to 1 clock cycle of the system clock.
--The scl_high_ena signal will be used to trigger the sampling of the SDA line during a read transaction or acknowledge condition, and to trigger the START and STOP conditions.
--The scl_high_ena signal should therefore be active for one period of the system clock cycle at some point during the high state of SCL. This is the correct timing of when a START and STOP condition will be generated as well as when the data one the SDA line will be sampled. Activate the scl_high_ena signal in the middle of the SCL high state.
--The state_ena signal will be used to trigger the transition of the state machine and should be generate at the center point of the low state of SCL. That is, the state machine process itself will run on the 50 MHz system clock, but the state_ena signal will be used to step the state machine to its next state.
-- sequencer
  p_ctrl : process(scl_high_ena, state_ena,cnt)
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








end i2c_master;