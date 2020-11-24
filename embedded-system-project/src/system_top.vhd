LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
ENTITY system_top IS
    PORT (

        clk : IN STD_LOGIC; --system clock
        arst_n : IN STD_LOGIC;--	asynchronous active low reset(key0)
        ext_ena_n : IN STD_LOGIC; --DE10-Lite push buttons (key1)
        sw : IN STD_LOGIC_VECTOR(9 DOWNTO 0); --DE10-Lite slide switches   width 10 
        led : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); --DE1-SoC LEDs (output data)
        sda : INOUT STD_LOGIC; --bidirectional serial I2C data
        scl : INOUT STD_LOGIC; --bidirectional serial I2C clock
        adxl345_irq_n : IN STD_LOGIC_VECTOR(1 DOWNTO 0);--interrupt lines from adxl345
        adxl345_alt_addr : OUT STD_LOGIC; --Hardwire to '0' to set ADXL345 I2C address to 0x53
        adxl345_cs_n : OUT STD_LOGIC --Hardwire to '1' to set ADXL345 serial mode to I2C

    );

END ENTITY system_top;
ARCHITECTURE top_level OF system_top IS
    SIGNAL irq_n_r, irq_n_rr : STD_LOGIC_VECTOR(2 DOWNTO 0);

    COMPONENT nios2_system IS
        PORT (
            clk_clk : IN STD_LOGIC := 'X'; -- clk
            sw_pio_external_connection_export : IN STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => 'X'); -- export
            led_pio_external_connection_export : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- export
            interrupt_pio_external_connection_export : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => 'X'); -- export
            reset_reset_n : IN STD_LOGIC := 'X'; -- reset_n
            i2c_avalon_mm_if_conduit_end_sda_export : INOUT STD_LOGIC := 'X'; -- export
            i2c_avalon_mm_if_conduit_end_scl_export : INOUT STD_LOGIC := 'X' -- export
        );
    END COMPONENT nios2_system;
BEGIN
    --  sda <= 'Z';
    --  scl <= 'Z';

    --set adxl345's i2c address to 0x53;

    adxl345_alt_addr <= '0';

    --set ADXL345's mode to I2C;

    adxl345_cs_n <= '1';
    p_sync : PROCESS (clk) IS
    BEGIN
        IF rising_edge(clk) THEN
            irq_n_r <= adxl345_irq_n & ext_ena_n;
            irq_n_rr <= irq_n_r;

        END IF;
    END PROCESS;

    u0 : COMPONENT nios2_system
        PORT MAP(
            clk_clk => clk, --                               clk.clk
            sw_pio_external_connection_export => sw, --        sw_pio_external_connection.export
            led_pio_external_connection_export => led, --       led_pio_external_connection.export
            interrupt_pio_external_connection_export => irq_n_rr, -- interrupt_pio_external_connection.export
            reset_reset_n => arst_n, --                             reset.reset_n
            i2c_avalon_mm_if_conduit_end_sda_export => sda, --  i2c_avalon_mm_if_conduit_end_sda.export
            i2c_avalon_mm_if_conduit_end_scl_export => scl --  i2c_avalon_mm_if_conduit_end_scl.export
        );

    END ARCHITECTURE;