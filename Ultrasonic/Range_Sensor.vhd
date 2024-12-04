library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ranger is
  port (
    clk,pulsey: in std_logic;
    triggered,buzzer: out std_logic
  ) ;
end ranger ;

architecture Structural of ranger is

    signal meters,decimeters,centimeters: std_logic_vector(3 downto 0);


    component distance_calculation is
        port (
          clk,calcreset,pulse: in std_logic;
          distance: out std_logic_vector(8 downto 0)
        ) ;
      end component ;

      component trigger is
        port (
          clk: in std_logic;
          trigger: out std_logic
        ) ;
      end component ;
      
      component BCD_Distance is
        port (
          distance: in std_logic_vector(8 downto 0);
          hundreds,tens,unit: out std_logic_vector(3 downto 0)
        ) ;
      end component ;

      signal distanceOut: std_logic_vector(8 downto 0);
      signal trigOut: std_logic;

begin

    trigger_gen : trigger port map(clk,trigOut);
    pulse_width: distance_calculation port map(clk,trigOut,pulsey,distanceOut);
    BCDConv : BCD_Distance port map(distanceOut,meters,decimeters,centimeters);
    triggered<=trigOut;
    
    process(clk)
    begin
        if(decimeters<"0001") then
             buzzer <= '1';
        else buzzer <= '0';
        end if;
    end process;


end architecture ; -- Structural