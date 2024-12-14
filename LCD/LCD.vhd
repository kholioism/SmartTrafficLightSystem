library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.NUMERIC_STD.ALL; 

 

entity LCD is 

     

    Port (clk    : in  STD_LOGIC; 

          RS     : out STD_LOGIC; 

          Enable : out  STD_LOGIC; 

          flag   : out  STD_LOGIC; 

          data   : out std_logic_vector(7 downto 0)); 

 

end LCD; 

 

architecture Behavioral of LCD is 

    signal digit           : integer:= 0 ; 

    constant Clear        : std_logic_vector(7 downto 0) := "00000001" ; 

    constant Return_home  : std_logic_vector(7 downto 0) := "00000010" ; 

    constant Display_On   : std_logic_vector(7 downto 0) := "00001100" ; 

    constant Function_set : std_logic_vector(7 downto 0) := "00111000" ; 

  --constant Entry_mode   : std_logic_vector(7 downto 0) := "00000001" ; 

    signal clk_1Mhz        : std_logic := '0';    -- Slower clock to count in µs 

    signal clk_counter     : integer;             -- Slower clock counter 

    signal counter         : integer := 0; 

    signal setup_done      : std_logic := '0';  

 

 

begin 

    process(clk) 

    begin 

        if rising_edge(clk) then 

            if clk_counter = 500 then 

                clk_1Mhz <= not clk_1Mhz; 

            else 

                clk_counter <= clk_counter + 1; 

            end if; 

        end if; 

    end process; 

        

    process(clk_1Mhz) 

        begin 

            if falling_edge(clk_1Mhz)then 

                        Enable <= '0';  

                    end if; 

            if rising_edge(clk_1Mhz) and setup_done= '0' then 

                RS <= '0'; 

                case counter is  

                when 0 => data <= Function_set; 

                when 1 => data <= Clear; 

                when 2 => data <= Return_home; 

                when 3 => data <= Display_On; setup_done <= '1'; counter <= 0; 

                when others => data <= "00000000"; 

                end case; 

                counter <= counter+1; 

                Enable <= '1'; 

                --data <= Display_On;  

            end if; 

            if rising_edge(clk_1Mhz) and setup_done= '1' and counter < 2 then 

                            flag <= '1'; 

                            RS <= '1'; 

                            case counter is  

                            when 0 => data <= "01001000"; -- 'H' 

                            when 1 => data <= "01001001"; -- 'I' 

                            when others => data <= "00000000"; 

                            end case; 

                            counter <= counter+1; 

                            Enable <= '1'; 

                        end if;   

        end process; 

     

        

end Behavioral; 