LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY i2c_avalon_mm_if IS
    PORT (
        clk : IN STD_LOGIC; -- system clock of your design
        reset_n : IN STD_LOGIC; -- system reset of your design.
        read : IN STD_LOGIC; -- indicates read transaction on Avalon busy
        write : IN STD_LOGIC; -- indicates write transaction on Avalon busy
        chipselect : IN STD_LOGIC; -- Enable access to Avalon modules
        address : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Address of i2c_avalon_mm_if registers
        writedata : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to be written to Avalon module
        readdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data read back from Avalon module
        sda : INOUT STD_LOGIC; -- I2C data line to interface ADXL345 accelerometer
        scl : INOUT STD_LOGIC); -- I2C clock line to interface ADXL345 accelerometer

END i2c_avalon_mm_if;

--Write the process that will used the input port signals chipselect, write, read, and address to allow write 
--and read access to the registers listed below. Label the process p_mm_if. Notice that read_reg is a 64-bit wide
-- register but that the read/write access split in two. This allows for multi-byte read transactions of up to 8-bytes. 

ARCHITECTURE memoryRW OF i2c_avalon_mm_if IS

    -- GC_SYSTEM_CLK : INTEGER := 50_000_000;
    --  SIGNAL GC_I2C_CLK : INTEGER := 200_000;

    ---ctrl_reg-----------------------------

    SIGNAL ctrl_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);-- ctlr_reg	0x0	32	RW	Command and control register
    ALIAS mm_if_busy : STD_LOGIC IS ctrl_reg(7);--mm_if_busy	Indicates that i2c_avalon_mm_if module is busy (mm_if_busy <= mm_if_busy_state)
    ALIAS busy : STD_LOGIC IS ctrl_reg(6); --busy	Register busy signal from I2C master module (busy <= i2c_busy)
    ALIAS i2c_ack_error : STD_LOGIC IS ctrl_reg(5);--ack_error	Register ack_error from I2C master module (ack_error <= i2c_ack_error)
    ALIAS cmd : STD_LOGIC IS ctrl_reg(0);--	if '1': Starts I2C transactions. Automatically reset after one system clock cycle
    ALIAS rnw : STD_LOGIC IS ctrl_reg(1);--	if '0': I2C read transactions, if '1': I2C write transaction
    ALIAS no_bytes : STD_LOGIC_VECTOR(2 DOWNTO 0) IS ctrl_reg(4 DOWNTO 2);--Specifies number of bytes to read or write
    ----addr_reg------------------------------
    SIGNAL addr_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);-- addr_reg	0x1	32	RW	I2C device and internal register addressable
    ALIAS i2c_device_addr : STD_LOGIC_VECTOR IS addr_reg(6 DOWNTO 0);
    ALIAS i2c_int_addr : STD_LOGIC_VECTOR IS addr_reg(15 DOWNTO 8);--?? address
    -------slave comminication variable--------------------------------------------------
    SIGNAL write_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);-- write_reg	0x2	32	RW	Data to be written to I2C device
    SIGNAL read_reg : STD_LOGIC_VECTOR(63 DOWNTO 0);-- read_reg(31 downto 0)	0x3	32	R	Data read from I2C device
    --ALIAS read_reg : STD_LOGIC_VECTOR(63 DOWNTO 32);-- read_reg(63 downto 32)	0x4	32	R	Data read from I2C device
    SIGNAL valid, cmd_rst, arst_n, mm_if_busy_state : STD_LOGIC;
    SIGNAL addr : STD_LOGIC_VECTOR (6 DOWNTO 0);
    SIGNAL data_wr : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_rd : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL i2c_busy_sc : STD_LOGIC;

    ---state machine variable-----------------------------------------------------------------
    TYPE state_type IS (sIDLE, sADDR, sWAIT_DATA, sWAIT_STOP, sWRITE_DATA);
    SIGNAL state : state_type;
    -- BEGIN
    --     UUT : PORT MAP(
    --         clk => clk,
    --         arst_n => reset_n,
    --         addr => i2c_device_addr,
    --         write => data_wr,
    --         read => data_rd,
    --         busy => busy,
    --         cmd => chipselect,
    --         ack_error => i2c_ack_error,
    --         sda => sda,
    --         scl => scl);
BEGIN
    submodel : ENTITY work.i2c_master

        PORT MAP(
            clk => clk,
            arst_n => reset_n,
            valid => valid,
            addr => i2c_device_addr,
            rnw => rnw,
            data_wr => data_wr,
            data_rd => data_rd,
            busy => busy,
            ack_error => i2c_ack_error,
            sda => sda,
            scl => scl

        );
    --general register interface
    p_mm_if : PROCESS (clk, arst_n)
    BEGIN

        IF arst_n = '0' THEN
            ctrl_reg <= (OTHERS => '0');
            addr_reg <= (OTHERS => '0');
            write_reg <= (OTHERS => '0');
            read_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN

            mm_if_busy <= mm_if_busy_state; -- Indicates that i2c_avalon_mm_if module is busy

            -- Write data from CPU interface
            IF chipselect = '1' AND write = '1' THEN
                CASE address IS
                    WHEN "000" =>
                        ctrl_reg(4 DOWNTO 0) <= writedata(4 DOWNTO 0);
                    WHEN "001" =>
                        addr_reg (15 DOWNTO 8) <= writedata(7 DOWNTO 0);
                    WHEN "010" =>
                        write_reg (4 DOWNTO 0) <= writedata(4 DOWNTO 0);
                    WHEN OTHERS =>
                        NULL;
                END CASE;
              

                -- Read data to CPU interface
            ELSIF chipselect = '1' AND read = '1' THEN
                CASE address IS
                    WHEN "000" =>
                        readdata <= ctrl_reg;
                    WHEN "001" =>
                        readdata <= addr_reg;
                    WHEN "010" =>
                        readdata <= write_reg;
                    WHEN "011" =>
                        readdata <= read_reg(31 DOWNTO 0);
                    WHEN "100" =>
                        readdata <= read_reg(63 DOWNTO 32);
                    WHEN OTHERS =>
                        NULL;
                END CASE;

            END IF;
        END IF;

    END PROCESS;

    -- The i2c_busy signal is used as a "handshake" signal by the state machine process. 
    -- This signal is high when the I2C master module performing an operation and not ready to recieve new commands. 
    -- A rising and falling edge on this signal indicates when the I2C master module starts an operation and
    --  when it completes an operation respectively. These conditions are therefore used to trigger the
    --   state transitions ofthe state machine in 88, except for the sIDLE state. Since the i2c_busy signal 
    --   is not a dedicated clock signal, the edge detection needs to be implemented using custom logic. 
    --   (rising_edge() and falling_edge() are reserved for dedicated clock signals only). Similar to 
    --   what was implemented for the push button signal in the last part of the introductory assignment
    --    (except for the synchronization which is not needed for the i2c_busy since it already is generated
    --     from the same clock domain). Since the i2c_busy signal is registered to the busy position of the control register,
    --  these to signals can easily be used to implement the edge detection functionality.

    p_mm_if_state : PROCESS (clk, arst_n)

        VARIABLE byte_count : INTEGER RANGE 0 TO 7;
    BEGIN

        IF arst_n = '0' THEN
            state <= sIDLE;
            byte_count := 0;
            cmd_rst <= '0';
            rnw <= '0';
        ELSIF rising_edge(clk) THEN
            busy <= busy;
            cmd_rst <= '0';
            i2c_busy_sc <= busy;

            CASE state IS

                WHEN sIDLE =>
                    busy <= '0';
                    i2c_busy_sc <= '0';
                    valid <= '0';

                    mm_if_busy_state <= '0';----difference from i2c_busy????

                    IF cmd = '1' THEN
                        byte_count := to_integer(unsigned(no_bytes));
                        cmd_rst <= '1';
                        state <= sADDR;
                        i2c_busy_sc <= '1';

                    ELSE
                        state <= sIDLE;
                        cmd_rst <= '0';
                        i2c_busy_sc <= '0';
                    END IF;

                WHEN sADDR =>
                    mm_if_busy_state <= '1';

                    data_wr <= i2c_int_addr;
                    addr <= i2c_device_addr;
                    rnw <= rnw;
                    valid <= '1';

                    IF (busy = '0' AND i2c_busy_sc = '1') THEN--rising edge busy
                        state <= sWAIT_DATA;
                        i2c_busy_sc <= '0';
                    END IF;

                WHEN sWAIT_DATA =>
                    mm_if_busy_state <= '1';
                    IF (busy = '1' AND i2c_busy_sc = '0') THEN--falling edge busy
                        IF rnw = '1' THEN
                            read_reg(((8 * byte_count) - 1) DOWNTO (8 * (byte_count - 1))) <= data_rd;
                            byte_count := byte_count - 1;
                            IF byte_count = 0 THEN
                                state <= sWAIT_STOP;
                            ELSE
                                state <= sWAIT_DATA;
                            END IF;
                        ELSE
                            IF byte_count = 0 THEN
                                state <= sWAIT_STOP;
                            ELSE
                                state <= sWRITE_DATA;
                            END IF;

                        END IF;
                    END IF;

                WHEN sWAIT_STOP =>
                    mm_if_busy_state <= '1';
                    valid <= '0';
                    IF (busy = '1'AND i2c_busy_sc = '0') THEN--falling edge busy
                        state <= sIDLE;
                    END IF;
                WHEN sWRITE_DATA =>
                    mm_if_busy_state <= '1';
                    data_wr <= write_reg(((8 * byte_count) - 1) DOWNTO (8 * (byte_count - 1)));
                    IF (busy = '1'AND i2c_busy_sc = '0') THEN--falling edge busy
                        byte_count := (byte_count - 1);
                        state <= sWAIT_DATA;
                    END IF;
                WHEN OTHERS =>
                    state <= sIDLE;
            END CASE;

        END IF;
    END PROCESS;
END ARCHITECTURE;