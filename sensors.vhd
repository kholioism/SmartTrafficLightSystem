library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sensors is
  port (
    temp: in std_logic_vector(39 downto 0); --8bit humidity integer data + 8bit the Humidity decimal data 
                                            --+8 bit temperature integer data + 8bit fractional temperature data 
                                            --+8 bit parity bit
    ultra_in: in std_logic_vector(3 downto 0);
    ultra_out: out std_logic_vector(3 downto 0)
  ) ;
end sensors;

architecture arch of sensors is

    signal 

begin

    ultrasonic : process( sensitivity_list )
    begin
        
    end process ; -- ultrasonic

end arch ; -- arch