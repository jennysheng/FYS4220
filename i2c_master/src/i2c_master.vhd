LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY i2c_master IS
    GENERIC (
        GC_SYSTEM_CLK : INTEGER := 50_000_000;
        GC_I2C_CLK : INTEGER := 200_000
    );

    PORT (
        clk : IN STD_LOGIC;--system clock     
        arst_n : IN STD_LOGIC;--asynchronous active low reset
        valid : IN STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        rnw : IN STD_LOGIC;
        data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_rd : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        busy : IN STD_LOGIC;
        ack_error : IN STD_LOGIC;
      --  sda : INOUT STD_LOGIC;--bidirectional serial i2c data
      --  scl : INOUT STD_LOGIC--bidirectional serial i2c clock
    );
END i2c_master;

ARCHITECTURE logic OF i2c_master IS

    CONSTANT C_SCL_PERIOD : INTEGER := GC_SYSTEM_CLK/GC_I2C_CLK; -- No. of system clock cycles in one SCL period. Used to indicate the transition point from 1->0 of the SCL signal
    CONSTANT C_SCL_HALF_PERIOD : INTEGER := C_SCL_PERIOD / 2; -- No. of system clock cycles in one half of a SCL period. Used to indicate the transition point from 0->1 of the SCL signal.
    CONSTANT C_STATE_TRIGGER : INTEGER := C_SCL_PERIOD / 4; -- No. of system clock cycles in 1/4 of a SCL period. Used to indicate the transition of the main state machine.
    CONSTANT C_SCL_TRIGGER : INTEGER := C_SCL_PERIOD * 3 / 4; -- No. of system clock cycles in 3/4 of SCL period. Used to indicate the timing of a START and STOP condition as wall as when to SAMPLE the SDA line. 
    SIGNAL scl_clk : STD_LOGIC;
    SIGNAL state_ena : STD_LOGIC; --	enables state transition (duration 1 system clk cycle)
    SIGNAL scl_high_ena : STD_LOGIC; -- enable signal used for START and STOP conditions,data sample, and acknowledge (duration 1 system clk cycle)
    -------1.create internal SCL clock
    --The scl_clk is derived from the 50 MHz system clock GC_SYSTEM_CLK.
    -- Use the internal variable cnt to control the correct timing of the scl_clk.
    --scl_clk will be low for the first half part of its period and high for the second part of its period.
BEGIN
    p_sclk : PROCESS (clk, arst_n)

        VARIABLE cnt : INTEGER RANGE 0 TO C_SCL_PERIOD; -- internal continuous running i2c clk signal

    BEGIN

        IF arst_n = '0' THEN--1if
            cnt := 0;
            SCL_CLK <= '0';
        ELSIF rising_edge(clk) THEN--5if	

            cnt := cnt + 1;
            IF cnt = C_SCL_PERIOD THEN--2if
                cnt := 0;
            END IF;--end2if

            IF cnt <= C_SCL_HALF_PERIOD THEN--3if
                SCL_CLK <= '0';
            ELSIF cnt < C_SCL_PERIOD THEN
                SCL_CLK <= '1';

            END IF;--3IF
        END IF;--end5if

       -- SCL <= SCL_CLK;

    END PROCESS;
    ---2.Create the internal trigger/timing enable signals

    --The scl_high_ena signal will be used to trigger the sampling of the SDA line during a read transaction or acknowledge condition, and to trigger the START and STOP conditions.
    --The scl_high_ena signal should therefore be active for one period of the system clock cycle at some point during the high state of SCL. This is the correct timing of when a START and STOP condition will be generated as well as when the data one the SDA line will be sampled. Activate the scl_high_ena signal in the middle of the SCL high state.
    --The state_ena signal will be used to trigger the transition of the state machine and should be generate at the center point of the low state of SCL. That is, the state machine process itself will run on the 50 MHz system clock, but the state_ena signal will be used to step the state machine to its next state.
    -- sequencer
    p_ctrl : PROCESS (clk, arst_n)
        VARIABLE cnt : INTEGER RANGE 0 TO C_SCL_PERIOD; -- internal continuous running i2c clk signal

    BEGIN

        IF arst_n = '0' THEN--1if
            cnt := 0;
            state_ena <= '0';
            scl_high_ena <= '0';

        ELSIF rising_edge(clk) THEN--5if
            state_ena <= '0';
            scl_high_ena <= '0';
            cnt := cnt + 1;

            IF (cnt = C_SCL_PERIOD) THEN--2if
                cnt := 0;
            END IF;--end2if

            IF (cnt = C_STATE_TRIGGER) THEN--3if

                state_ena <= '1';

            ELSIF (cnt = C_SCL_TRIGGER) THEN--4if
                scl_high_ena <= '1';
            END IF;--end4if
        END IF;--end5if

    END PROCESS;

END ARCHITECTURE logic;