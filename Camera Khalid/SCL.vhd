library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Clock is
    Port (
        clk         : in  std_logic;  -- Input FPGA clock (e.g., 50 MHz)
        reset       : in  std_logic;  -- Asynchronous reset
        scl         : out std_logic   -- I2C clock (SCL)
    );
end I2C_Clock;

architecture Behavioral of I2C_Clock is
    -- Constants
    constant CLK_FREQ      : integer := 100000000;  -- Input clock frequency (50 MHz)
    constant I2C_FREQ      : integer := 100000;    -- Desired SCL frequency (100 kHz)
    constant CLOCK_DIVIDE  : integer := CLK_FREQ / (2 * I2C_FREQ);

    -- Signals
    signal counter : integer := 0;
    signal scl_reg : std_logic := '1';  -- Default HIGH (idle state)
begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            scl_reg <= '1';  -- Reset SCL to idle (HIGH)
        elsif rising_edge(clk) then
            if counter = CLOCK_DIVIDE - 1 then
                scl_reg <= not scl_reg;  -- Toggle SCL
                counter <= 0;            -- Reset counter
            else
                counter <= counter + 1;  -- Increment counter
            end if;
        end if;
    end process;

    -- Assign SCL signal
    scl <= scl_reg;

end Behavioral;
