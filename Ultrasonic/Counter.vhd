    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_unsigned.all;

entity Counter is
    generic(n: POSITIVE := 10);
  port (
    clk,enable,reset:in std_logic; --reset is active low
    o:out std_logic_vector(n-1 downto 0)
  ) ;
end Counter ;

architecture Behavioral of Counter is

signal count  : std_logic_vector(n-1 downto 0);

begin

    process( clk, reset )
    begin
        if (reset = '0') then
            count <= (others => '0');
        elsif (rising_edge(clk)) then
            if (enable='1') then
                count <= count + 1;
            end if ;
        end if ;
    end process ; -- 

end architecture ; -- Behavioral