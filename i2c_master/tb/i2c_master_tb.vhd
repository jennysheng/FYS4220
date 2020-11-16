LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

ENTITY i2c_master_tb IS
END ENTITY;

ARCHITECTURE tb OF i2c_master_tb IS

    SIGNAL clk : STD_LOGIC;
    SIGNAL arst_n : STD_LOGIC;
    SIGNAL valid : STD_LOGIC;
    SIGNAL addr : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL rnw : STD_LOGIC;
    SIGNAL data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL data_rd : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL busy : STD_LOGIC;
    SIGNAL ack_error : STD_LOGIC;
    SIGNAL sda : STD_LOGIC;
    SIGNAL scl : STD_LOGIC;
    SIGNAL clk_ena : BOOLEAN := false;
    SIGNAL clk_period : TIME := 20 ns;

    CONSTANT GC_SYSTEM_CLK : INTEGER := 50_000_000;
    CONSTANT GC_I2C_CLK : INTEGER := 200_000;
    CONSTANT C_SCL_PERIOD : TIME := clk_period * (GC_SYSTEM_CLK/GC_I2C_CLK);

BEGIN
    UUT : ENTITY work.i2c_master
        GENERIC MAP(
            GC_SYSTEM_CLK => GC_SYSTEM_CLK,
            GC_I2C_CLK => GC_I2C_CLK)
        PORT MAP(
            clk => clk,
            arst_n => arst_n,
            valid => valid,
            addr => addr,
            rnw => rnw,
            data_wr => data_wr,
            data_rd => data_rd,
            busy => busy,
            ack_error => ack_error,
            sda => sda,
            scl => scl
          
        );

    --create clk
    clk <= NOT clk AFTER clk_period / 2 WHEN clk_ena ELSE   '0';

    -- sequencer
    p_seq : PROCESS
    BEGIN
        -- Start clk
        report("start simulation");
        clk_ena <= true;
        arst_n <= '1';
        -- Reset circuit
        WAIT UNTIL clk = '1';
        arst_n <= '0';--ACTIVE LOW RESET??
        WAIT FOR clk_period * 5;
        arst_n <= '1';
        WAIT FOR C_SCL_PERIOD * 2;
        clk_ena <= false;
        WAIT;
    END PROCESS;
END ARCHITECTURE tb;