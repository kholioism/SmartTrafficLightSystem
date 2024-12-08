library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RGB is
    Port( Din  : in		STD_LOGIC_VECTOR (7 downto 0);	
		  pclk : in     std_logic;
		  href : in     std_logic;
          R    : out	STD_LOGIC_VECTOR (4 downto 0);
		  G    : out	STD_LOGIC_VECTOR (5 downto 0);
		  B    : out	STD_LOGIC_VECTOR (4 downto 0)
		);
end RGB;

architecture Behavioral of RGB is

	signal first: std_logic:='1';
	signal bits: std_logic_vector(15 downto 0);

begin

	write : process( pclk )
	begin
		if (rising_edge(pclk)) then
			if (href = '1') then
				if (first = '1') then
					bits(7 downto 0) <= Din;
					first <= '0';
				else
					bits(15 downto 8) <= Din;
					first <= '1';
				end if ;
			end if ;
		end if ;
	end process ; -- write
	
		R <= bits(15 downto 11);
		G <= bits(10 downto 5);
		B <= bits(4 downto 0);

end Behavioral;

