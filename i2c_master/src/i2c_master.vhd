LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

Entity i2c_master IS
    GENERIC (
        GC_SYSTEM_CLK : INTEGER:=500000000 ;
        GC_I2C_CLK : INTEGER:=200000
    );

    PORT (
        clk : IN STD_LOGIC;--system clock     
        arst_n : IN STD_LOGIC;--asynchronous active low reset
        valid : IN STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        rnw : IN STD_LOGIC;
        data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_rd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        busy : OUT STD_LOGIC;
        ack_error : OUT STD_LOGIC;
        sda : INOUT STD_LOGIC;--bidirectional serial i2c data
        scl : INOUT STD_LOGIC--bidirectional serial i2c clock
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
    -- Start by declaring the type and signal to be used for the state machine.
    TYPE state_type IS (sIDLE, sSTART, sADDR, sACK1, sWRITE, sACK2, sREAD, sMACK, sSTOP);
    SIGNAL state : state_type;
    SIGNAL ack_error_i : STD_LOGIC; --Internal ack. error flag (ack_error <= ack_error_i)--HOW TO MAKE WIDTH=1???
    SIGNAL sda_i : STD_LOGIC; --interal sda signal
    SIGNAL addr_rnw_i : STD_LOGIC_VECTOR(7 DOWNTO 0); --internally stored value of address and Read/nWrite bit
    SIGNAL data_tx : STD_LOGIC_VECTOR(7 DOWNTO 0);--internally stored data to be sent to slave
    SIGNAL data_rx : STD_LOGIC_VECTOR(7 DOWNTO 0); --internally stored data from slave
    SIGNAL bit_cnt : INTEGER RANGE 0 TO 7 := 0; --counter to keep track of data bit
    SIGNAL scl_oe : STD_LOGIC; --output enable for scl
    -- To improve the readability an alias called rnw_i will be used to access the least significant bit of the internal signal addr_rnw_i.
    ALIAS rnw_i : STD_LOGIC IS addr_rnw_i(0);--????

    -------------------------------------------1.create internal SCL clock---------------------------------------------------------------------
    --The scl_clk is derived from the 50 MHz system clock GC_SYSTEM_CLK.
    -- Use the internal variable cnt to control the correct timing of the scl_clk.
    --scl_clk will be low for the first half part of its period and high for the second part of its period.
BEGIN
    p_sclk : PROCESS (clk, arst_n)

        VARIABLE cnt : INTEGER RANGE 0 TO C_SCL_PERIOD; -- internal continuous running i2c clk signal

    BEGIN

        IF arst_n = '0' THEN
            cnt := 0;
            SCL_CLK <= '0';
        ELSIF rising_edge(clk) THEN

            cnt := cnt + 1;
            IF cnt = C_SCL_PERIOD THEN
                cnt := 0;
            END IF;

            IF cnt <= C_SCL_HALF_PERIOD THEN
                SCL_CLK <= '0';
            ELSIF cnt < C_SCL_PERIOD THEN
                SCL_CLK <= '1';

            END IF;
        END IF;

    END PROCESS;
    -------------------------------------------2.Create the internal trigger/timing enable signals---------------------------------

    --The scl_high_ena signal will be used to trigger the sampling of the SDA line during a read transaction or acknowledge condition, and to trigger the START and STOP conditions.
    --The scl_high_ena signal should therefore be active for one period of the system clock cycle at some point during the high state of SCL. This is the correct timing of when a START and STOP condition will be generated as well as when the data one the SDA line will be sampled. Activate the scl_high_ena signal in the middle of the SCL high state.
    --The state_ena signal will be used to trigger the transition of the state machine and should be generate at the center point of the low state of SCL. That is, the state machine process itself will run on the 50 MHz system clock, but the state_ena signal will be used to step the state machine to its next state.
    -- sequencer
    p_ctrl : PROCESS (clk, arst_n)
        VARIABLE cnt : INTEGER RANGE 0 TO C_SCL_PERIOD; -- internal continuous running i2c clk signal

    BEGIN

        IF arst_n = '0' THEN
            cnt := 0;
            state_ena <= '0';
            scl_high_ena <= '0';

        ELSIF rising_edge(clk) THEN
            state_ena <= '0';
            scl_high_ena <= '0';
            cnt := cnt + 1;

            IF (cnt = C_SCL_PERIOD) THEN
                cnt := 0;
            END IF;

            IF (cnt = C_STATE_TRIGGER) THEN

                state_ena <= '1';

            ELSIF (cnt = C_SCL_TRIGGER) THEN
                scl_high_ena <= '1';
            END IF;
        END IF;

    END PROCESS;

    ---------------------------------------------------------3.state machine------------------------------------------------------------------
    -- Create the skeleton of the synchronous process that will control the transitions of the state machine. 
    --Label the process using the name p_state.
    p_state : PROCESS (arst_n, clk)
    BEGIN
        IF arst_n = '0' THEN
            state <= sIDLE;
        ELSIF rising_edge(clk) THEN
            scl_oe <= '1';
            CASE state IS
                    --   sIDLE : IN this state the state machine waits FOR an event ON the external data valid SIGNAL.
                    -- IF the external SIGNAL `valid = '1' THEN
                    --  the state machine must store/sample the value OF the inputs data_wr, addr AND rnw. 
                    --WHILE data_wr should be stored IN the internal SIGNAL data_tx, the inputs addr AND rnw should be 
                    --concatenated into the 8 - BIT addr_rnw_i. IN this state the sda_i SIGNAL must be high.
                    -- Reset the data BIT counter (bit_cnt = 7).
                    -- IF ack_error was active WHEN entering sIDLE, it should only be reset WHEN valid = '1'.

                WHEN sIDLE =>
                    scl_oe <= '0';
                    busy <= '0';
                    sda_i <= '1';
                    bit_cnt <= 7;
                    ack_error_i <= '1';

                    IF valid = '1' AND state_ena = '1' THEN
                        state <= sSTART;
                        data_tx <= data_wr;
                        addr_rnw_i <= addr & rnw;
                        ack_error_i <= '0';

                    END IF;
                    -- sSTART: The purpose of this state is to generate a START condition on the I2C bus 
                    --at the center of the high period of SCL. When scl_high_ena = '1' then pull sda_i low 
                    ---(center point of SCL high period). See figure 81.
                WHEN sSTART =>
                    busy <= '1';
                    scl_oe <= '1';
                    IF scl_high_ena = '1'THEN
                        sda_i <= '0';
                    END IF;
                    IF state_ena = '1' THEN
                        state <= sADDR;
                        --   ELSE
                        --   STATE <= sACK1;
                    END IF;

                    -- sADDR: During this state the address bits in addition to the rnw bit will be written to the I2C bus.
                    --  Assign addr_rnw_i(bit_cnt) to sda_i. If bit_cnt is not zero then decrement bit_cnt on every state_ena = '1'. 
                    -- If bit_cnt is zero, assign default value of 7 to bit_cnt and move to next state.

                WHEN sADDR =>
                    busy <= '1';
                    scl_oe <= '1';
                    sda_i <= addr_rnw_i(bit_cnt);
                    IF state_ena = '1' THEN
                        IF bit_cnt /= 0 THEN
                            bit_cnt <= bit_cnt - 1;

                        ELSE
                            bit_cnt <= 7;
                            state <= sACK1;
                        END IF;
                    END IF;

                    -- sACK1: After writing the address to the I2C bus, the corresponding slave should acknowledge by pulling SDA low. 
                    -- The master must therefore release SDA. (Pull sda_i high). When scl_high_ena = '1' then check status of SDA line. 
                    -- If sda /= '0' then set the value of ack_error to '1'.

                WHEN sACK1 =>
                    scl_oe <= '1';
                    busy <= '1';
                    sda_i <= '1';
                    IF scl_high_ena = '1' AND sda /= '0' THEN
                        ack_error_i <= '1';
                    END IF;
                    IF state_ena = '1' THEN
                        IF rnw = '0' THEN
                            state <= sWRITE;
                        ELSE
                            state <= sREAD;
                        END IF;
                    END IF;

                    -- sWRITE: During this state the respective data bits will be written to the I2C bus.
                    --  Assign data_tx(bit_cnt) to sda_i. If bit_cnt is not zero then decrement bit_cnt on every state_ena = '1'.
                    --   If bit_cnt is zero, assign default value of 7 to bit_cnt.

                WHEN sWRITE =>
                    scl_oe <= '1';
                    busy <= '1';
                    sda_i <= data_tx(bit_cnt);
                    IF state_ena = '1' THEN
                        IF bit_cnt /= 0 THEN
                            bit_cnt <= bit_cnt - 1;

                        ELSE
                            bit_cnt <= 7;
                            state <= sACK2;
                        END IF;
                    END IF;

                    -- sACK2: When the master has transferred the 8-data bits, the slave will acknowledge this transfer by pulling 
                    --SDA low during the ninth SCL clock cycle. During this state the master can also accept new commands. 
                    --The master must therefore release the SDA line (pull sda_i high) in addition to pulling busy low. 
                    --If the external data valid signal is kept active (high) at the same time as the external rnw signal is kept low,
                    -- this initiates another byte write transaction and the input data_wr should be sampled into data_tx.
                    -- If the external signal valid is kept high but external rnw is high, this indicates a repeated condition and the
                    -- addr should be sampled in addition to the rnw input. When scl_high_ena = '1' then check status of SDA line.
                    -- If sda /= '0'` then set the value of ack_error to '1'. If the external signal valid is low, this indicates end of
                    -- transactions and sda_i should be pulled low when moving to the sSTOP state to prepare for the stop condition.

                WHEN sACK2 =>
                    scl_oe <= '1';
                    sda_i <= '1';
                    busy <= '0';
                    ---? where to put ????When scl_high_ena = '1' then check status of SDA line.
                    IF scl_high_ena = '1' AND sda /= '0' THEN

                        ack_error_i <= '1';

                    END IF;
                    IF state_ena = '1' THEN
                        IF valid = '1' THEN
                            IF rnw = '0' THEN

                                data_tx <= data_wr;
                                state <= sWRITE;
                            ELSE
                                addr_rnw_i <= addr & rnw;
                                state <= sSTART;
                            END IF;

                        ELSE
                            sda_i <= '0';
                            state <= sSTOP;
                        END IF;
                    END IF;
                    --sREAD: During this state the slave will write data to the I2C bus. 
                    --The master must therefore release the SDA line (Pull sda_i high). If scl_high_ena = '1' then assign sda to data_rx(bit_cnt). 
                    --If bit_cnt is not zero then decrement bit_cnt on every state_ena = '1'. If bit_cnt is zero, assign default value of 7 to bit_cnt.
                    -- When all bits have been sampled the the data_rx is made available on the data_rd port. The latter happens on state_ena = '1'.
                WHEN sREAD =>
                    scl_oe <= '1';
                    busy <= '1';
                    sda_i <= '1';
                    IF scl_high_ena = '1' THEN
                        data_rx(bit_cnt) <= sda;
                    END IF;
                    IF state_ena = '1' THEN
                        IF BIT_CNT = 0 THEN
                            bit_cnt <= 7;
                            state <= sMACK;
                            data_rd <= data_rx;
                        ELSE
                            bit_cnt <= bit_cnt - 1;

                        END IF;
                    END IF;

                    ----sMACK: In the master acknowledge state the master can either ACK (sda_i = '0') 
                    --in order to continue reading data from the slave or it could NACK (sda_i = '1') 
                    --if no more data should be read. If the external data valid signal is kept high
                    -- at the same time as the external rnw signal is kept low, this indicates a restart condition and 
                    --both the input data_wr and addr should be sampled in addition to the rnw input. If during sMACK 
                    --the input signal valid is pulled low, this indicates that the read transaction is completed and no more 
                    --data should be read from the slave. In order to end the transaction, a NACK must be indicated to the slave.
                    -- (Tips: Set default value of sda_i to '1'. sda_i should then be pulled low either if valid = '1' to prepare for the ACK,
                    -- or when (state_ena = '1' and valid = '0') to prepare for a stop condition.).

                WHEN sMACK =>
                    scl_oe <= '1';
                    sda_i <= '1';
                    busy <= '0';
                    IF valid = '1' THEN
                        sda_i <= '0';
                    END IF;
                    IF state_ena = '1' THEN
                        IF valid = '1' THEN
                            IF RNW = '1' THEN
                                state <= sREAD;
                            ELSE
                                data_tx <= data_wr;
                                addr_rnw_i <= addr & rnw;
                                state <= sSTART;
                            END IF;
                        ELSE

                            sda_i <= '0';
                            state <= sSTOP;
                        END IF;

                    END IF;
                    --sSTOP: The purpose of this state is to generate a STOP condition on the I2C bus at the center of 
                    --the high period of the SCL. When scl_high_ena = '1 then pull sda_i high. See figure 81.
                WHEN sSTOP =>
                    busy <= '1';
                    scl_oe <= '1';
                    IF scl_high_ena = '1' THEN
                        sda_i <= '1';
                    END IF;
                    IF state_ena = '1' THEN
                        state <= sIDLE;
                    END IF;
                WHEN OTHERS =>
                    state <= sIDLE;
        END CASE;
        --The busy output port should be active in all states expect the sIDLE, 
        --sACK2 and sMACK states. The scl_oe control signal should be active as long as the state machine is not in the sIDLE state.
   END IF;
    END PROCESS;
    -- Controlling the outputs SDA and SCL
    -- The SDA and SCL lines of the I2C bus are bidirectional where pulling the line to ground is considered 
    --a logic zero while letting the line float (high impedance ’Z’) is a logical one. For the SCL line an internal 
    --output enable signal, scl_oe, is used to control if the internal scl_clk signal or a high impedance value ,’Z’, 
    --is assigned to the output scl.

    -- When scl_clk = '0' and scl_oe = '1' assign '0' to scl, else assign 'Z'. scl_oe is controlled by the state machine 
    --and the scl output should be active as long as the state machine is not in the state sIDLE.

    -- An internal signal, sda_i, is used as an intermediate signal for sda and controlled by the state machine. sda_i can
    -- take the values ’0’ or ’1’.
    -- When sda_i = ’1’ assign ’Z’ to sda, else assign ’0’ to sda.
    -- The assignments to both the sda and scl output should be implemented as purely combinational and concurrent statements.
--    IF state /= sIDLE THEN
--        IF scl_clk = '0' & scl_oe = '1' THEN
--            scl <= '0';
--        ELSE
--            scl <= 'Z';
--        END IF;
--        IF sda_i = '1' THEN
--            sda <= 'Z';
--        ELSE
--            sda <= '0';
--
--        END IF;
--    END IF;
      ack_error <= ack_error_i;
      sda       <= '0' when sda_i = '0' else 'Z';
      scl       <= '0' when (scl_clk = '0' and scl_oe = '1') else 'Z';

END ARCHITECTURE logic;