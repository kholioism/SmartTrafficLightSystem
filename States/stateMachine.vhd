library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity fsm is
  port (
    clk : in std_logic;
    eAll : out std_logic
    AB_RED: out STD_LOGIC;
    AB_YELLOW: out STD_LOGIC;
    AB_GREEN: out STD_LOGIC;
    CD_RED: out STD_LOGIC;
    CD_YELLOW: out STD_LOGIC;
    CD_GREEN: out STD_LOGIC;
  ) ;
end fsm ; 

architecture Behavioral of fsm is

    signal counter: integer:=0;
    signal clk_1Hz : std_logic;
    signal second : integer=:0;
    type state : (AllRed1,ABGreen,ABYellow,AllRed2,CDGreen,CDYellow);
    signal eAll_signal:='0';
begin

    clk_divider : process( clk )
    begin
        if (counter<50000000) then
            counter <= counter + 1;
        else
            clk_1Hz <= not clk_1Hz;
        end if ;
    end process ; -- clk_divider

    state_machine : process( clk_1Hz )
    begin
        case( state ) is
        
            when AllRed1 => --count 2 seconds
                if eAll = '1' then 
                    if counter < 2 then
                        AB_RED =
        
            when ABGreen =>
                
            when ABYellow =>
                
            when AllRed2 =>
                
            when CDGreen =>
                
            when CDYellow =>
                        
        end case ;
    end process ; -- state_machine

end architecture ;