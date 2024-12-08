library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    Port (
        clk         : in  std_logic;   -- System clock (e.g., 100 MHz)
        reset_n     : in  std_logic;   -- Active low reset
        scl         : out std_logic;   -- I2C clock line
        sda         : inout std_logic -- I2C data line
    );
end i2c_master;

architecture Behavioral of i2c_master is

    -- Define I2C clock generation (dividing system clock for ~100kHz)
    constant I2C_CLK_DIV : integer := 499;  -- Adjust based on your FPGA clock
    signal clk_count     : integer range 0 to 499 := 0;
    signal scl_reg       : std_logic := '1'; -- SCL signal
    signal go            : std_logic := '0';
    signal done          : std_logic := '0';
    
    -- I2C states
    type state_type is (
        IDLE, START, SEND_ADDR, SEND_DATA, STOP, WAIT0
    );
    signal state         : state_type := IDLE;
    
    -- Signals for I2C protocol
    signal sda_out       : std_logic := '1'; -- Output for SDA
    signal sda_in_reg    : std_logic := '1'; -- Input from SDA
    signal sda_dir       : std_logic := '1'; -- Direction of SDA (1 = output, 0 = input)
    signal addr_byte     : std_logic_vector(7 downto 0) := "00010010"; -- Example: OV7670 I2C address (write)
    signal data_byte     : std_logic_vector(7 downto 0) := "00001001"; -- Example: Data to send
    signal bit_index     : integer range 0 to 7 := 0;

begin

    -- Generate SCL clock
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_count = I2C_CLK_DIV then
                clk_count <= 0;
                scl_reg <= not scl_reg;
            else
                clk_count <= clk_count + 1;
            end if;
        end if;
    end process;

    scl <= scl_reg;

    -- I2C State Machine
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
            sda_out <= '1';
            sda_dir <= '1';
            done <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if go = '1' then
                        state <= START;
                        sda_out <= '1'; -- SDA idle high
                        done <= '0';
                    end if;

                when START =>
                    sda_out <= '0'; -- Start condition
                    state <= SEND_ADDR;
                    bit_index <= 7;

                when SEND_ADDR =>
                    sda_out <= addr_byte(bit_index);
                    if scl_reg = '0' then
                        if bit_index = 0 then
                            state <= SEND_DATA;
                            bit_index <= 7;
                        else
                            bit_index <= bit_index - 1;
                        end if;
                    end if;

                when SEND_DATA =>
                    sda_out <= data_byte(bit_index);
                    if scl_reg = '0' then
                        if bit_index = 0 then
                            state <= STOP;
                        else
                            bit_index <= bit_index - 1;
                        end if;
                    end if;

                when STOP =>
                    sda_out <= '0'; -- Stop condition
                    if scl_reg = '1' then
                        state <= WAIT0;
                    end if;

                when WAIT0 =>
                    sda_out <= '1';
                    done <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;

            -- Update SDA direction
            if state = IDLE or state = WAIT0 then
                sda_dir <= '0'; -- Release SDA
            else
                sda_dir <= '1'; -- Drive SDA
            end if;
        end if;
    end process;

    process
    begin
        -- Example configuration sequence
        go <= '1'; -- Start I2C transaction
        wait until done = '1';
        go <= '0'; -- Clear start signal
        wait;
    end process;


    -- SDA output assignment
    sda <= sda_out when sda_dir = '1' else 'Z';
    sda_in_reg <= sda; -- Read SDA input

end Behavioral;
