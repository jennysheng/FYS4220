LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY i2c_master IS
    GENERIC (
        CONSTANT GC_SYSTEM_fre : INTEGER := 50_000_000;
        CONSTANT GC_I2C_fre : INTEGER := 20_000

    );

    PORT (
        clk : INOUT STD_LOGIC;--system clock 
        clk_ena : INOUT BOOLEAN:=false; -- I2c communication enable 1
        arst_n : IN STD_LOGIC;--asynchronous active low reset
        valid : IN STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        rnw : IN STD_LOGIC;
        data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_rd : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        busy : IN STD_LOGIC;
        ack_error : IN STD_LOGIC;
        sda : INOUT STD_LOGIC;--bidirectional serial i2c data
        scl : INOUT STD_LOGIC;--bidirectional serial i2c clock
		  state_ena: out std_logic;
		  scl_high_ena : out STD_LOGIC

    );
END i2c_master;

ARCHITECTURE logic OF i2c_master IS

    CONSTANT C_SCL_PERIOD : INTEGER := GC_SYSTEM_fre/GC_I2C_fre; -- No. of system clock cycles in one SCL period. Used to indicate the transition point from 1->0 of the SCL signal
    CONSTANT C_SCL_HALF_PERIOD : INTEGER := C_SCL_PERIOD / 2; -- No. of system clock cycles in one half of a SCL period. Used to indicate the transition point from 0->1 of the SCL signal.
    CONSTANT C_STATE_TRIGGER : INTEGER := C_SCL_PERIOD / 4; -- No. of system clock cycles in 1/4 of a SCL period. Used to indicate the transition of the main state machine.
    CONSTANT C_SCL_TRIGGER : INTEGER := C_SCL_PERIOD * 3 / 4; -- No. of system clock cycles in 3/4 of SCL period. Used to indicate the timing of a START and STOP condition as wall as when to SAMPLE the SDA line. 
    --     
    --	type  state_ena        <= clk; --	enables state transition (duration 1 system clk cycle)
    --   type  scl_high_ena  	is range 0 to clk; -- enable signal used for START and STOP conditions,data sample, and acknowledge (duration 1 system clk cycle)
    --  ?????????
    --	

    SIGNAL scl_clk : STD_LOGIC := '0';
    --SIGNAL state_ena : STD_LOGIC := '0'; --	enables state transition (duration 1 system clk cycle)
   -- SIGNAL scl_high_enable : STD_LOGIC := '0';
    -- enable signal used for START and STOP conditions,data sample, and acknowledge (duration 1 system clk cycle)
    -------1.create internal SCL clock
    --The scl_clk is derived from the 50 MHz system clock GC_SYSTEM_CLK. Use the internal variable cnt to control the correct timing of the scl_clk.
    --scl_clk will be low for the first half part of its period and high for the second part of its period.
BEGIN
    p_sclk : PROCESS (clk, arst_n)

        VARIABLE cnt : INTEGER RANGE 0 TO C_SCL_PERIOD; -- internal continuous running i2c clk signal

    BEGIN
        --create system clk
        
        IF arst_n = '0' THEN--1if
            cnt := 0;

         clk_ena <= false;
        ELSIF rising_edge(clk) THEN--5if	
            clk_ena <= true;
            cnt := cnt + 1;
            IF (cnt = C_SCL_PERIOD) THEN--2if
                cnt := 0;
            END IF;--end2if

            IF (cnt < C_SCL_PERIOD) THEN--3if

                scl <= NOT scl_clk AFTER  20 ns * C_SCL_HALF_PERIOD;
            END IF;--end5if

        END IF;--end3if

    END PROCESS;
    ---2.Create the internal trigger/timing enable signals

    --The scl_high_ena signal will be used to trigger the sampling of the SDA line during a read transaction or acknowledge condition, and to trigger the START and STOP conditions.
    --The scl_high_ena signal should therefore be active for one period of the system clock cycle at some point during the high state of SCL. This is the correct timing of when a START and STOP condition will be generated as well as when the data one the SDA line will be sampled. Activate the scl_high_ena signal in the middle of the SCL high state.
    --The state_ena signal will be used to trigger the transition of the state machine and should be generate at the center point of the low state of SCL. That is, the state machine process itself will run on the 50 MHz system clock, but the state_ena signal will be used to step the state machine to its next state.
    -- sequencer
    p_ctrl : PROCESS (clk, arst_n)
        VARIABLE cnt2 : INTEGER RANGE 0 TO C_SCL_PERIOD; -- internal continuous running i2c clk signal
		 
    BEGIN
      
        IF arst_n = '0' THEN--1if
            cnt2 := 0;
				clk_ena<=false;
            IF rising_edge(clk) THEN--5if
                cnt2 := cnt2 + 1;
					 clk_ena<=true;

                IF (cnt2 = C_SCL_PERIOD) THEN--2if
                    cnt2 := 0;
                END IF;--end2if

                IF (cnt2 = C_STATE_TRIGGER) THEN--3if

                    state_ena <= '1';

                    IF (cnt2 = C_SCL_TRIGGER) THEN--4if
                        scl_high_ena <= '1';
                    END IF;--end4if
                END IF;--end5if

            END IF;--end3if

        END IF;--end1if

    END PROCESS;

END ARCHITECTURE logic;