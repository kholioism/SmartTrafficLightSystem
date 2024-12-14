library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 
 
entity TrafficTB is 
end TrafficTB; 
 
architecture Behavioral of TrafficTB is 
 
    component Traffic_System is 
 
    generic( 
 
        ZERO : std_logic_vector(6 downto 0) := "1000000" ; 
        ONE : std_logic_vector(6 downto 0) := "1111001" ; 
        TWO : std_logic_vector(6 downto 0) := "0100100" ; 
        THREE :std_logic_vector(6 downto 0) := "0110000" ; 
        FOUR : std_logic_vector(6 downto 0) := "0011001" ; 
        FIVE : std_logic_vector(6 downto 0) := "0010010" ; 
        SIX : std_logic_vector(6 downto 0) := "0000010" ; 
        SEVEN :std_logic_vector(6 downto 0) := "1111000" ; 
        EIGHT :std_logic_vector(6 downto 0) := "0000000" ; 
        NINE :std_logic_vector(6 downto 0) := "0010000" 
 
    ); 
    
    Port (clk : in STD_LOGIC; 
          trig : out STD_LOGIC; 
          echo : in std_logic_vector (7 downto 0); 
          buzzer : out STD_LOGIC; 
          segment_mode : in std_logic; 
          
          
          data_pin : inout std_logic; -- Bidirectional data line 
          valid : out std_logic; -- Validity of output data 
          
          ABR,ABY,ABG,CDR,CDY,CDG : out std_logic; --Relays 
          
          Segment_A : out std_logic; 
          Segment_B : out std_logic; 
          Segment_C : out std_logic; 
          Segment_D : out std_logic; 
          Segment_E : out std_logic; 
          Segment_F : out std_logic; 
          Segment_G : out std_logic; 
          anode : out std_logic_vector(3 downto 0)); 
    end component; 
 
          signal clk : STD_LOGIC:='0'; 
          signal trig : STD_LOGIC; 
          signal echo : std_logic_vector (7 downto 0):="00000000"; 
          signal buzzer : STD_LOGIC; 
          signal segment_mode : std_logic:='1'; 
          
          
          signal data_pin : std_logic:='0'; -- Bidirectional data line 
          signal valid : std_logic; -- Validity of output data 
          
          signal ABR,ABY,ABG,CDR,CDY,CDG : std_logic; --Relays 
          
          signal Segment_A :  std_logic; 
          signal Segment_B :  std_logic; 
          signal Segment_C :  std_logic; 
          signal Segment_D :  std_logic; 
          signal Segment_E :  std_logic; 
          signal Segment_F :  std_logic; 
          signal Segment_G :  std_logic; 
          signal anode :  std_logic_vector(3 downto 0)); 
 
begin 
 
    uut : Traffic_System   
    port map( clk => clk,trig => trig,echo => echo,buzzer => buzzer,segment_mode => segment_mode,data_pin => data_pin,valid => valid, 
              ABR => ABR,ABY => ABY,ABG => ABG,CDR => CDR,CDY => CDY,CDG => CDG,Segment_A => Segment_A,Segment_B => Segment_B, 
              Segment_C => Segment_C,Segment_D => Segment_D,Segment_E => Segment_E, 
              Segment_F => Segment_F,Segment_G => Segment_G,anode => anode); 
              
    timing : process 
             begin 
              
                clk <= '0'; 
                wait for 1 s; 
                clk <= '1'; 
                wait for 1 s; 
                
    end process; 
                          
    stim : process 
           begin 
            
                wait for 100 ms; 
                echo(3 downto 0) <= "1111"; 
                wait for 100 ms; 
                echo(3 downto 0) <= "0000"; 
                wait for 100 ms; 
                echo(7 downto 6) <= "11"; 
                wait for 100 ms; 
                echo(7 downto 6) <= "00"; 
                wait; 
                
           end process; 
            
end Behavioral; 