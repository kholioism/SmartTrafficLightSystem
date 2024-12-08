library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VSYNC is
    Port (
        trigger     : in  std_logic; --Car crossed a red light
        clk         : in  std_logic;  -- Input FPGA clock (e.g., 50 MHz)
        reset       : in  std_logic;  -- Asynchronous reset
        v         : out std_logic   -- VSYNC clock
    );
end VSYNC;

architecture Behavioral of VSYNC is
    -- Constants
    constant CLK_FREQ      : integer := 100000000;  -- Input clock frequency (100 MHz)
    constant VSYNC_FREQ      : integer := 60;    -- Desired VSYNC frequency (60 Hz)
    constant CLOCK_DIVIDE  : integer := CLK_FREQ / (2 * VSYNC_FREQ);

    -- Signals
    signal counter,delay : integer := 0;
    signal vsync_reg : std_logic := '1';  -- Default HIGH (idle state)
    begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            vsync_reg <= '1';  -- Reset v to idle (HIGH)
            if (not (delay=0)) then
                delay <= delay + 1;
                if (delay = CLOCK_DIVIDE - 1) then
                    delay <= 0;
                end if ;
            elsif (rising_edge(clk) and (trigger = '1' or (not(counter = 0) and vsync_reg = '0'))) then
                if counter = CLOCK_DIVIDE - 1 then
                    vsync_reg <= not vsync_reg;  -- Toggle v
                    counter <= 0;            -- Reset counter
                else
                    counter <= counter + 1;  -- Increment counter
                end if;
            end if;
        end if;
    end process;

    delay_process : process( vsync_reg )
    begin
        if (falling_edge(vsync_reg)) then
            delay <= 1;
        end if ;
    end process ; -- delay

    -- Assign vsync signal
    v <= vsync_reg;

end Behavioral;
