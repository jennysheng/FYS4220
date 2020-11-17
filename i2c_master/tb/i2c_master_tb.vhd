LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

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
    CONSTANT GC_I2C_CLK : INTEGER := 2_000_000;
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
    clk <= NOT clk AFTER clk_period / 2 WHEN clk_ena ELSE
        '0';

    -- sequencer
    p_seq : PROCESS
    BEGIN

        REPORT("start simulation");
        -- set default values
        addr <= (OTHERS => '0');
        rnw <= '0';
        data_wr <= (OTHERS => '0');

        valid <= '0';
        arst_n <= '1';

        -- Start clk

        clk_ena <= true;
        arst_n <= '1';
        -- Reset circuit
        WAIT UNTIL clk = '1';
        arst_n <= '0';--ACTIVE LOW RESET??
        WAIT FOR clk_period * 5;---??? why
        arst_n <= '1';

        ---------------------------------------------------
        -- Write data to register
        ---------------------------------------------------
        addr <= "1010011"; -- i2c address x 53
        rnw <= '0';
        data_wr <= "00110001"; -- address of internal register.
        valid <= '1';

        WAIT UNTIL busy = '1'; -- wait for busy to make sure command is received
        WAIT UNTIL rising_edge(clk);

        -- keep valid active
        WAIT UNTIL busy = '0'; -- wait for ack2
        data_wr <= "00000011"; -- provide data to be written to register x3

        WAIT UNTIL busy = '1'; -- wait for busy to make sure command is received
        valid <= '0'; -- wait for busy ack2 and then stop
        WAIT UNTIL busy = '0';
        WAIT UNTIL busy = '1'; --busy in stop
        WAIT UNTIL busy = '0'; --returned to idle

        WAIT FOR clk_period * 10;

        ---------------------------------------------------
        -- Read data from register
        ---------------------------------------------------
        addr <= "1010011"; -- i2c address
        rnw <= '0';
        data_wr <= "00110001"; -- address of internal register.
        valid <= '1';
        WAIT UNTIL busy = '1'; -- wait for busy to make sure command is received

        WAIT UNTIL busy = '0'; -- wait for ack2
        rnw <= '1'; -- prepare for read
        valid <= '1'; -- keep valid high --> restart
        addr <= "1010011";
        WAIT UNTIL busy = '1'; -- wait for busy to make sure command is received
        WAIT UNTIL busy = '0'; -- wait for sMACK
        valid <= '0'; -- prepare for stop
        WAIT UNTIL busy = '1'; -- wait for busy to make sure command is recieved
        WAIT FOR C_SCL_PERIOD * 10;
        clk_ena <= false;
        WAIT;
    END PROCESS;
END ARCHITECTURE tb;