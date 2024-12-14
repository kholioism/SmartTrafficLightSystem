library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.NUMERIC_STD.ALL; 

 

entity tempsensor is 

 

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

     

            

 Port (   

       clk      : in std_logic;        -- System clock 

       data_pin : inout std_logic;     -- Bidirectional data line 

       valid    : out std_logic;       -- Validity of output data 

        

       Segment_A  : out std_logic; 

       Segment_B  : out std_logic; 

       Segment_C  : out std_logic; 

       Segment_D  : out std_logic; 

       Segment_E  : out std_logic; 

       Segment_F  : out std_logic; 

       Segment_G  : out std_logic; 

       anode      : out std_logic_vector(3 downto 0) ); 

end tempsensor; 

 

architecture Behavioral of tempsensor is 

 

 

    type state_type is (IDLE, START, WAIT_RESPONSE, READ_DATA, DONE); 

    signal state : state_type := IDLE; 

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

    signal clk_counter   : integer; 

    signal clk_counter2  : integer;              

begin 

 

    process(clk) 

    begin 

        if rising_edge(clk) then 

            clk_counter  <= clk_counter + 1; 

            clk_counter2 <= clk_counter2 + 1; 

            if clk_counter = 50 then 

                clk_counter <= 0; 

                clk_1Mhz <= not clk_1Mhz; 

            end if; 

            if (clk_counter2 = 200000) then  

                clk_counter2 <= 0;  

                clk_250hz<= not clk_250hz; 

            end if; 

        end if; 

    end process; 

     

    process (clk_1Mhz) 

    begin 

        

        if rising_edge(clk_1Mhz) then 

             

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

                     

                    if data_pin = '1' and timer > 140 and timer < 180 then –tolerance for 160us 

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

       

    end process; 

     

 --   digit <= 1 when flag_test = '1' else 0; 

  

    seven_segment_mux: process(clk_250hz) 

             begin 

                 if rising_edge(clk_250hz) then 

                     case active_digit is 

                         when 0 => digit <= to_integer(unsigned(temperature)) /10;    anode <=  "0111"; 

                         when 1 => digit <= to_integer(unsigned(temperature)) mod 10; anode <=  "1011"; 

                         when 2 => digit <= to_integer(unsigned(humidity)) /10;       anode <=  "1101"; 

                         when 3 => digit <= to_integer(unsigned(humidity)) mod 10;    anode <=  "1110"; 

                         when others => digit <= 0; 

                     end case; 

                     active_digit <= (active_digit + 1) mod 4; 

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

 