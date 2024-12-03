library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity trigger is
  port (
    clk: in std_logic;
    trigger: out std_logic;
  ) ;
end trigger ;

architecture Behavioral of trigger is

    component Counter is
        generic(n: POSITIVE := 10)
      port (
        clk,enable,reset:in std_logic;
        o:out std_logic_vector(n-1 downto 0)
      ) ;
    end component ;
    signal resetCounter: std_logic;
    signal outputCounter: std_logic_vector(24 downto 0);

begin

    trig: Counter generic map(25) port map(clk,'1',resetCounter,outputCounter);

    process( clk )
    begin
        constant ms250 : std_logic_vector(24 downto 0) := "1101111101011110000100000";
        constant ms250and100us : std_logic_vector(24 downto 0) := "1101111101011110000101000";
        if (output_counter>ms250 and output_counter<ms250and100us) then
            trigger <= '1';
        else
            trigger <= '0';
        end if ;
        if (output_counter = ms250and100us or output_counter = "XXXXXXXXXXXXXXXXXXXXXXXXX") then
            reset_counter <= '0';
        else
            reset_counter <= '1';
        end if ;
    end process ;
end architecture ; -- Behavioral