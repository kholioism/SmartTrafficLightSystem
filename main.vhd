library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity traffic is
  port (
    reset,clk: in std_logic;
  ) ;
end traffic;

architecture arch of traffic is

    type state_type is (NS,NSY,NSL,NSLY,WE,WEY,WEL,WELY);  -- N:north  S:south  W:west  E:east  Y:yellow  L:left

    signal S: state_type;
    signal temp: std_logic_vector(39 downto 0);
    signal ultra_in: in std_logic_vector(3 downto 0);
    signal ultra_out: out std_logic_vector(3 downto 0);
    signal adjusted_clk: 

    component sensors is
      port (
        temp: in std_logic_vector(39 downto 0);
        ultra_in: in std_logic_vector(3 downto 0);
        ultra_out: out std_logic_vector(3 downto 0)
      ) ;
    end component;

begin

    clk_divider : process( clk )
    begin
        
    end process ; -- clk_divider

    traffic_system : process( adjusted_clk )
    begin
        
    end process ; -- traffic_system

    buzzer : process( clk )
    begin
        
    end process ; -- buzzer


end arch ; -- arch