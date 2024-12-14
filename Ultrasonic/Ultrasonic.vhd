library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.NUMERIC_STD.ALL; 

 

entity hcsr04tofii is 

 

    generic( 

  

        ZERO : std_logic_vector(6 downto 0) := "1000000" ; 

        ONE :  std_logic_vector(6 downto 0) := "1111001" ; 

        TWO :  std_logic_vector(6 downto 0) := "0100100" ; 

        THREE :std_logic_vector(6 downto 0) := "0110000" ; 

        FOUR : std_logic_vector(6 downto 0) := "0011001" ; 

        FIVE : std_logic_vector(6 downto 0) := "0010010" ; 

        SIX :  std_logic_vector(6 downto 0) := "0000010" ; 

        SEVEN :std_logic_vector(6 downto 0) := "1111000" ; 

        EIGHT :std_logic_vector(6 downto 0) := "0000000" ; 

        NINE  :std_logic_vector(6 downto 0) := "0010000"  

 

    ); 

     

    Port (clk    : in  STD_LOGIC; 

          trig   : out STD_LOGIC; 

          echo   : in  STD_LOGIC; 

          output : out STD_LOGIC; 

           

          Segment_A  : out std_logic; 

          Segment_B  : out std_logic; 

          Segment_C  : out std_logic; 

          Segment_D  : out std_logic; 

          Segment_E  : out std_logic; 

          Segment_F  : out std_logic; 

          Segment_G  : out std_logic; 

          anode      : out std_logic_vector(3 downto 0)); 

end hcsr04tofii; 

 

architecture Behavioral of hcsr04tofii is 

    signal Hex_Encoding : std_logic_vector(6 downto 0) := ZERO; 

    signal digit        : integer:= 0 ; 

    signal trig_signal  : std_logic := '0';    -- Trig signal to turn on or off 

    signal trig_time    : integer := 0; 

    signal pulse_time   : integer := 0;        -- Pulse timer 

    signal echo_active  : std_logic := '0';    -- Echo signal active flag 

    signal echo_time    : integer;             -- Echo time counter 

    signal dist         : integer := 100;             -- Distance in mm 

    signal clk_1Mhz     : std_logic := '0';    -- Slower clock to count in µs 

    signal clk_counter  : integer;             -- Slower clock counter 

 

begin 

 

    process(clk) 

    begin 

        if rising_edge(clk) then 

            if clk_counter = 50 then 

                clk_counter <= 0; 

                clk_1Mhz <= not clk_1Mhz; 

            else 

                clk_counter <= clk_counter + 1; 

            end if; 

        end if; 

    end process; 

     

     -- Trigger Module: Generates a 10 µs pulse every 60 ms 

       process(clk_1Mhz) 

       begin 

           if rising_edge(clk_1Mhz) then 

               if trig_time <=60000 then 

                   trig_time <= trig_time + 1; 

               else 

                   trig_time <= 0;  

                   trig_signal <= '1';   

                  end if; 

               if trig_signal = '1' then 

                  pulse_time <= pulse_time + 1; 

                  end if;  

               if  pulse_time = 10 then  -- 10 µs pulse duration 

                   pulse_time <= 0; 

                   trig_signal <= '0'; 

               end if; 

           end if; 

       end process; 

               

           -- Echo Timer: Measures the high duration of the echo signal 

           process(clk_1Mhz,echo) 

           begin 

               if rising_edge(clk_1Mhz) then 

                   if echo = '1' then 

                         echo_active <= '1'; 

                         echo_time <= echo_time + 1; 

                         end if; 

                   if echo = '0' and echo_active = '1' then 

                         echo_active <= '0'; 

                         echo_time <= 0; 

                         dist <= ((echo_time * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                         end if; 

                   end if; 

           end process; 

            

           digit  <= dist/10; 

            

           seven_segment:  process (digit) 

           begin 

               case digit is 

                   when 0 => Hex_Encoding <= ZERO ;  

                   when 1 => Hex_Encoding <= ONE  ;  

                   when 2 => Hex_Encoding <= TWO  ;  

                   when 3 => Hex_Encoding <= THREE;  

                   when 4 => Hex_Encoding <= FOUR ;  

                   when 5 => Hex_Encoding <= FIVE ;  

                   when 6 => Hex_Encoding <= SIX  ;  

                   when 7 => Hex_Encoding <= SEVEN;  

                   when 8 => Hex_Encoding <= EIGHT;  

                   when 9 => Hex_Encoding <= NINE ;  

                   when others => Hex_Encoding <= ZERO; 

               end case; 

           end process seven_segment; 

        

           anode <=  "1110"; 

            

           Segment_A <= Hex_Encoding(6); 

           Segment_B <= Hex_Encoding(5); 

           Segment_C <= Hex_Encoding(4); 

           Segment_D <= Hex_Encoding(3); 

           Segment_E <= Hex_Encoding(2); 

           Segment_F <= Hex_Encoding(1); 

           Segment_G <= Hex_Encoding(0); 

            

           trig <= trig_signal; 

           output <= '1' when dist < 100 else '0'; 

end Behavioral; 