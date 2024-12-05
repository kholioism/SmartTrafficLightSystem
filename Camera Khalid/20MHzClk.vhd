library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity clk20 is
  port (
    inclk: in std_logic;
    reset: in std_logic;
    adjustedclk: out std_logic
  ) ;
end clk20 ;

architecture Behavioral of clk20 is

    signal counter : integer := 0;  -- Counter for clock division
    signal clk_reg : std_logic := '0';  -- Internal signal for the output clock

begin

    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= 0;
            clk_reg <= '0';
        elsif rising_edge(clk_in) then
            -- Increment the counter on every rising edge
            if counter = 4 then  -- Divide by 5 (0, 1, 2, 3, 4)
                clk_reg <= not clk_reg;  -- Toggle the clock
                counter <= 0;  -- Reset the counter
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_reg;

end architecture ; -- Behavioral