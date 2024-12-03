library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity range is
  port (
    clk,pulse: in std_logic;
    trigger: out std_logic;
    meters,decimeters,centimeters: out std_logic_vector(3 downto 0)
  ) ;
end range ;

architecture Structural of range is

    component distance_calculation is
        port (
          clk,reset,pulse: in std_logic;
          distance: out std_logic_vector(8 downto 0)
        ) ;
      end component ;

      component trigger is
        port (
          clk: in std_logic;
          trigger: out std_logic;
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
    pulse_width: distance_calculation port map(clk,trigOut,pulse,distanceOut);
    BCDConv : BCD_Distance port map(distanceOut,meters,decimeters,centimeters);
    trigger<=trigOut;


end architecture ; -- Structural