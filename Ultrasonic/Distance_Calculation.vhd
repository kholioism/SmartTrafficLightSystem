library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity distance_calculation is
  port (
    clk,calcreset,pulse: in std_logic;
    distance: out std_logic_vector(8 downto 0)
  ) ;
end distance_calculation ;

architecture Behavioral of distance_calculation is

    component Counter is
        generic(n: POSITIVE := 10);
      port (
        clk,enable,reset:in std_logic;
        o:out std_logic_vector(n-1 downto 0)
      ) ;
    end component ;

    signal pulse_width: std_logic_vector(21 downto 0);
    signal actualReset: std_logic:=(not calcReset);
begin

    counterPulse : Counter 
                   generic map(22) 
                   port map(clk,pulse,actualReset,pulse_width);

    distance_calculation : process( pulse )

        variable result: integer;
        variable multiplier: std_logic_vector(23 downto 0);
        
    begin  
        if (pulse='0') then 
            multiplier := pulse_width * "11";
            result := to_integer(unsigned(multiplier(23 downto 14)));
            if (result > 458) then
                distance <= "111111111";
            else
                distance <= std_logic_vector(to_unsigned(result,9));
            end if ;
        end if;
    end process ; -- distance_calculation

end architecture ; -- Behavioral