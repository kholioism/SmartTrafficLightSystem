library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.NUMERIC_STD.ALL; 

 

entity Traffic_System is 

 

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

          echo   : in  std_logic_vector (7 downto 0); 

          buzzer : out STD_LOGIC; 

          segment_mode : in std_logic; 

           

           

          data_pin : inout std_logic;     -- Bidirectional data line 

          valid    : out std_logic;       -- Validity of output data 

           

          ABR,ABY,ABG,CDR,CDY,CDG : out std_logic := '0'; --Relays 

           

          Segment_A  : out std_logic; 

          Segment_B  : out std_logic; 

          Segment_C  : out std_logic; 

          Segment_D  : out std_logic; 

          Segment_E  : out std_logic; 

          Segment_F  : out std_logic; 

          Segment_G  : out std_logic; 

          anode      : out std_logic_vector(3 downto 0)); 

end Traffic_System; 

 

architecture Behavioral of Traffic_System is 

 

    type Traffic is (AllRed_1, AB_Green, AB_Yellow, AllRed_2 , CD_Green, CD_Yellow); 

    type Density is (Normal, AB_dense, CD_dense); 

    signal Traffic_state: Traffic := AllRed_1; 

    signal Density_state: Density := Normal; 

    signal Traffic_timer:     integer:=0; 

    signal Buzzer_timer :     integer:=0; 

    signal Density_maxtimeAB: integer:= 30; 

    signal Density_maxtimeCD: integer:= 30; 

    signal buzzer_signal  : std_logic := '0'; 

     

    signal trig_signal  : std_logic := '0';    -- Trig signal to turn on or off 

    signal trig_time    : integer := 0; 

    signal pulse_time   : integer := 0;        -- Pulse timer 

    signal echo_active  : std_logic_vector (7 downto 0);    -- Echo signal active flag 

    signal echo_time0   : integer;             -- Echo time counter 

    signal echo_time1   : integer;             -- Echo time counter 

    signal echo_time2   : integer;             -- Echo time counter 

    signal echo_time3   : integer;             -- Echo time counter 

    signal echo_time4   : integer;             -- Echo time counter 

    signal echo_time5   : integer;             -- Echo time counter 

    signal echo_time6   : integer;             -- Echo time counter 

    signal echo_time7   : integer;             -- Echo time counter 

    signal dist0        : integer := 100;      -- Distance in mm 

    signal dist1        : integer := 100;      -- Distance in mm 

    signal dist2        : integer := 100;      -- Distance in mm 

    signal dist3        : integer := 100;      -- Distance in mm 

    signal dist4        : integer := 100;      -- Distance in mm 

    signal dist5        : integer := 100;      -- Distance in mm 

    signal dist6        : integer := 100;      -- Distance in mm 

    signal dist7        : integer := 100;      -- Distance in mm 

         

     

    type temperature_state is (IDLE, START, WAIT_RESPONSE, READ_DATA, DONE); 

    signal state : temperature_state := IDLE; 

    signal start_signal : std_logic := '1'; 

    signal bit_counter : integer  := 39; 

    signal data_reg : std_logic_vector(39 downto 0); 

    signal flag: std_logic:='0'; 

    signal flag_test: std_logic:='0'; 

    signal intern_data : STD_LOGIC; --internal data 

    signal timer: integer:=0; 

    signal counter: std_logic:='0'; 

    signal temperature         :  std_logic_vector(7 downto 0); 

    signal temperature_decimal :  std_logic_vector(7 downto 0); 

    signal humidity         :  std_logic_vector(7 downto 0); 

    signal humidity_decimal :  std_logic_vector(7 downto 0); 

    signal checksum    :  std_logic_vector(7 downto 0); 

     

    signal Hex_Encoding  : std_logic_vector(6 downto 0) := ZERO; 

    signal digit         : integer   := 0 ; 

    signal active_digit  : integer   := 0 ; 

    signal clk_1Mhz      : std_logic := '0';    -- Slower clock to count in µs 

    signal clk_250hz     : std_logic := '0';    -- Slower 250 Hz clock for seven segment 

    signal clk_1Hz       : std_logic := '0';    -- Slower clock to count in s 

    signal clk_counter   : integer; 

    signal clk_counter2  : integer; 

    signal clk_counter3  : integer;               

 

begin 

 

clock_divider:   process(clk) 

                 begin 

        if rising_edge(clk) then 

            clk_counter  <= clk_counter + 1; 

            clk_counter2 <= clk_counter2 + 1; 

            clk_counter3 <= clk_counter3 + 1; 

            if clk_counter = 50 then 

                clk_counter <= 0; 

                clk_1Mhz <= not clk_1Mhz; 

            end if; 

            if (clk_counter2 = 200000) then  

                clk_counter2 <= 0;  

                clk_250hz<= not clk_250hz; 

            end if; 

            if (clk_counter3 = 50000000) then  

                            clk_counter3 <= 0;  

                            clk_1Hz<= not clk_1Hz; 

            end if; 

        end if; 

    end process clock_divider; 

     

         -- Trigger Module: Generates a 10 µs pulse every 60 ms 

Clk1Mhz_proc:     process(clk_1Mhz) 

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

               

              -- Temperature sensor code: 

                  case state is 

                  when IDLE => 

                      if  start_signal = '1' then -- Trigger signal from master --switch equal 1 

                          intern_data <= '1'; 

                          data_pin<=intern_data; 

                          state <= START;    

                      end if; 

   

                  when START => 

                      -- Hold low for 18ms 

                      if timer < 18000 then 

                          timer <= timer + 1; 

                          intern_data<='0'; 

                          data_pin <= intern_data; 

                           

                      else 

                          timer <= 0; 

                          intern_data<='1'; 

                          data_pin <= intern_data; 

                          state <= WAIT_RESPONSE; 

                      end if; 

   

                  when WAIT_RESPONSE => 

                      timer <= timer + 1; 

                      if timer < 40 then 

                      intern_data<='1'; 

                      data_pin <= intern_data; 

                                           

                      else 

                      data_pin <= '0'; 

                      data_pin <= 'Z'; -- Release line 

                      end if; 

                       

                      if data_pin = '1' and timer > 140 and timer < 180 then  

                      flag<='1';-- Sensor response detected 

                      end if; 

                       

                      if timer>200 and flag ='1' then 

                      timer <= 0; flag<='0';  

                      state <= READ_DATA; 

                      elsif  timer>200 and flag ='0' then 

                      start_signal <= '1'; 

                      timer <= 0; 

                      state <= IDLE;  

                      end if; 

   

                  when READ_DATA => 

     

                      if bit_counter > -1 then 

                          -- Capture data bits based on timing  

                      if data_pin = '1' then 

                          timer <= timer+1; 

                      end if; 

                      if data_pin = '0' then     

                          if (timer>30) then 

                             data_reg(bit_counter) <= '1'; 

                             bit_counter <= bit_counter - 1; 

                          end if; 

                          if (timer<=30 and timer > 0) then  

                             data_reg(bit_counter) <= '0'; 

                             bit_counter <= bit_counter - 1; 

                          end if; 

                          timer <= 0;  

                      end if;                      

                      else 

                          timer <= 0; 

                          state <= DONE; 

                      end if; 

   

                  when DONE => 

                      flag_test <= '1'; 

                      temperature         <= data_reg(23 downto 16); 

                      temperature_decimal <= data_reg(15 downto 8); 

                      humidity            <= data_reg(39 downto 32); 

                      humidity_decimal    <= data_reg(31 downto 24); 

                      checksum            <= data_reg(7 downto 0); 

                      bit_counter <= 39; 

                      timer <= timer +1; 

                      flag<= '0'; 

                      if (timer = 1000000) then 

                      start_signal <= '1';  

                      timer <= 0; 

                      state <= IDLE;  

                      end if; 

                     

              end case; 

 

          end if; 

      end process Clk1Mhz_proc; 

       

      trig <= trig_signal; 

              

          -- Echo Timer: Measures the high duration of the echo signal 

Echo_Proc:        process(clk_1Mhz,echo) 

                  begin 

              if rising_edge(clk_1Mhz) then 

                  if echo(0) = '1' then 

                        echo_active(0) <= '1'; 

                        echo_time0 <= echo_time0 + 1; 

                        end if; 

                  if echo(0) = '0' and echo_active(0) = '1' then 

                        echo_active(0) <= '0'; 

                        echo_time0 <= 0; 

                        dist0 <= ((echo_time0 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                        end if; 

                   

                  if echo(1) = '1' then 

                        echo_active(1) <= '1'; 

                        echo_time1 <= echo_time1 + 1; 

                        end if; 

                  if echo(1) = '0' and echo_active(1) = '1' then 

                        echo_active(1) <= '0'; 

                        echo_time1 <= 0; 

                        dist1 <= ((echo_time1 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                        end if; 

                   

                  if echo(2) = '1' then 

                        echo_active(2) <= '1'; 

                        echo_time2 <= echo_time2 + 1; 

                        end if; 

                  if echo(2) = '0' and echo_active(2) = '1' then 

                        echo_active(2) <= '0'; 

                        echo_time2 <= 0; 

                        dist2 <= ((echo_time2 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                       end if; 

                        

                   if echo(3) = '1' then 

                        echo_active(3) <= '1'; 

                        echo_time3 <= echo_time3 + 1;    

                        end if; 

                   if echo(3) = '0' and echo_active(3) = '1' then 

                       echo_active(3) <= '0'; 

                       echo_time3 <= 0; 

                       dist3 <= ((echo_time3 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                       end if; 

                        

                   if echo(4) = '1' then 

                        echo_active(4) <= '1'; 

                        echo_time4 <= echo_time4 + 1;    

                        end if; 

                   if echo(4) = '0' and echo_active(4) = '1' then 

                        echo_active(4) <= '0'; 

                        echo_time4 <= 0; 

                        dist4 <= ((echo_time4 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                        end if; 

                            

                   if echo(5) = '1' then 

                         echo_active(5) <= '1'; 

                         echo_time5 <= echo_time5 + 1;    

                         end if; 

                    if echo(5) = '0' and echo_active(5) = '1' then 

                         echo_active(5) <= '0'; 

                         echo_time5 <= 0; 

                         dist5 <= ((echo_time5 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                         end if; 

 

                   if echo(6) = '1' then 

                         echo_active(6) <= '1'; 

                         echo_time6 <= echo_time6 + 1;    

                         end if; 

                    if echo(6) = '0' and echo_active(6) = '1' then 

                         echo_active(6) <= '0'; 

                         echo_time6 <= 0; 

                         dist6 <= ((echo_time6 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                         end if; 

 

                   if echo(7) = '1' then 

                         echo_active(7) <= '1'; 

                         echo_time7 <= echo_time7 + 1;    

                         end if; 

                    if echo(7) = '0' and echo_active(7) = '1' then 

                         echo_active(7) <= '0'; 

                         echo_time7 <= 0; 

                         dist7 <= ((echo_time7 * 343) / 1000) / 2 ; -- Convert time to distance (in mm) 

                         end if; 

 

                  end if; 

          end process Echo_Proc; 

           

          buzzer_signal <= '1' when ((dist0 < 100 or dist1 < 100) and  

                              (Traffic_state=AllRed_1 or Traffic_state=AllRed_2 or Traffic_state=AB_Green or Traffic_state=AB_Yellow)) or  

                              

                             ((dist2 < 100 or dist3 <100) and  

                              (Traffic_state=AllRed_1 or Traffic_state=AllRed_2 or Traffic_state=CD_Green or Traffic_state=CD_Yellow))  

                               else '0'; 

          buzzer <= buzzer_signal; 

           

          Density_state <=      AB_dense when (dist4 >= 100 and dist5 >= 100) and (dist6 < 100 or dist7 < 100)  

                           else CD_dense when (dist4 < 100 or dist5 < 100) and (dist6 >= 100 and dist7 >= 100)  

                           else Normal; 

  

 Traffic_proc:    process (clk_1Hz) 

                  begin 

        

                    if rising_edge(clk_1Hz) then 

                        

                       Traffic_timer <= Traffic_timer+1; 

                       --if (buzzer_signal = '1' and buzzer_timer < 2) then 

                           --buzzer_signal end if; 

                       case Density_state is 

                            when Normal =>  

                                Density_maxtimeAB <= 30; 

                                Density_maxtimeCD <= 30; 

                            when AB_dense =>  

                                Density_maxtimeAB <= 45; 

                                Density_maxtimeCD <= 30; 

                            when CD_dense =>  

                                Density_maxtimeAB <= 30; 

                                Density_maxtimeCD <= 45; 

                       end case; 

                        

                       case Traffic_state is 

                       when AllRed_1 => 

                            ABR <= '1'; ABY <= '0'; ABG <= '0'; CDR <= '1'; CDY <= '0'; CDG <= '0'; 

                            if (Traffic_timer =2)  then  

                              Traffic_state <= AB_Green;  Traffic_timer <= 0; end if; 

                       when AB_Green =>  

                            ABR <= '0'; ABY <= '0'; ABG <= '1'; CDR <= '1'; CDY <= '0'; CDG <= '0'; 

                            if (Traffic_timer = Density_maxtimeAB) then 

                              Traffic_state <= AB_Yellow; Traffic_timer <= 0; end if; 

                       when AB_Yellow => 

                            ABR <= '0'; ABY <= '1'; ABG <= '0'; CDR <= '1'; CDY <= '0'; CDG <= '0';  

                            if (Traffic_timer =5)  then 

                              Traffic_state <= AllRed_2; Traffic_timer <= 0; end if; 

                       when AllRed_2 =>  

                            ABR <= '1'; ABY <= '0'; ABG <= '0'; CDR <= '1'; CDY <= '0'; CDG <= '0'; 

                            if (Traffic_timer =2)  then 

                              Traffic_state <= CD_Green; Traffic_timer <= 0; end if; 

                       when CD_Green =>  

                            ABR <= '1'; ABY <= '0'; ABG <= '0'; CDR <= '0'; CDY <= '0'; CDG <= '1'; 

                            if (Traffic_timer = Density_maxtimeCD)  then 

                              Traffic_state <= CD_Yellow; Traffic_timer <= 0; end if; 

                       when CD_Yellow =>  

                            ABR <= '1'; ABY <= '0'; ABG <= '0'; CDR <= '0'; CDY <= '1'; CDG <= '0'; 

                            if (Traffic_timer =5)  then 

                              Traffic_state <= AllRed_1; Traffic_timer <= 0; end if; 

                       end case; 

                    end if; 

       

             end process Traffic_proc; 

     

    seven_segment_mux: process(clk_250hz) 

             begin 

                 if rising_edge(clk_250hz) then 

                  if (segment_mode = '0') then 

                     case active_digit is 

                         when 0 => digit <= to_integer(unsigned(temperature)) /10;    anode <=  "0111"; 

                         when 1 => digit <= to_integer(unsigned(temperature)) mod 10; anode <=  "1011"; 

                         when 2 => digit <= to_integer(unsigned(humidity)) /10;       anode <=  "1101"; 

                         when 3 => digit <= to_integer(unsigned(humidity)) mod 10;    anode <=  "1110"; 

                         when others => digit <= 0; 

                     end case; 

                     active_digit <= (active_digit + 1) mod 4; 

                  else 

                     case active_digit is 

                     when 0 => digit <= 0;                      anode <=  "0111"; 

                     when 1 => digit <= 0;                      anode <=  "1011"; 

                     when 2 => digit <= traffic_timer /10;      anode <=  "1101"; 

                     when 3 => digit <= traffic_timer mod 10;   anode <=  "1110"; 

                     when others => digit <= 0; 

                     end case; 

                     active_digit <= (active_digit + 1) mod 4; 

                  end if; 

                 end if; 

             end process seven_segment_mux; 

              

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

     

    Segment_A <= Hex_Encoding(6); 

    Segment_B <= Hex_Encoding(5); 

    Segment_C <= Hex_Encoding(4); 

    Segment_D <= Hex_Encoding(3); 

    Segment_E <= Hex_Encoding(2); 

    Segment_F <= Hex_Encoding(1); 

    Segment_G <= Hex_Encoding(0); 

     

    valid <= '1' when (unsigned(temperature) + unsigned(humidity) + unsigned(temperature_decimal)+ unsigned(humidity_decimal)  = unsigned(checksum))  

                 else '0'; 

 

end Behavioral; 