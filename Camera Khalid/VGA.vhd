library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
  port (
    sda: inout std_logic;
    trigger: in std_logic;
    din: in std_logic_vector(7 downto 0);
    clk: in std_logic;
    pclk: in std_logic;
    scl: out std_logic;
    v_sync: out std_logic;
    hsync: in std_logic;
    red: out std_logic_vector(4 downto 0);
    green: out std_logic_vector(5 downto 0);
    blue: out std_logic_vector(4 downto 0)
  ) ;
end VGA ;

architecture Structural of VGA is

    component VSYNC is
        Port (
            trigger     : in  std_logic; --Car crossed a red light
            clk         : in  std_logic;  -- Input FPGA clock (e.g., 50 MHz)
            reset       : in  std_logic;  -- Asynchronous reset
            v         : out std_logic   -- VSYNC clock
        );
    end component;

    component RGB is
        Port( Din  : in		STD_LOGIC_VECTOR (7 downto 0);	
              pclk : in     std_logic;
              href : in     std_logic;
              R    : out	STD_LOGIC_VECTOR (4 downto 0);
              G    : out	STD_LOGIC_VECTOR (5 downto 0);
              B    : out	STD_LOGIC_VECTOR (4 downto 0)
            );
    end component;

    component i2c_master is
        Port (
            clk         : in  std_logic;   -- System clock (e.g., 100 MHz)
            reset_n     : in  std_logic;   -- Active low reset
            scl         : out std_logic;   -- I2C clock line
            sda         : inout std_logic -- I2C data line
        );
    end component;

    component clk20 is
        port (
          clk_in: in std_logic;
          reset: in std_logic;
          adjustedclk: out std_logic
        ) ;
      end component ;

    signal clk_20: std_logic;

begin

    xclk : clk20 port map(clk,'0',clk_20);

    reg_comm : i2c_master port map(clk,'1',scl,sda);

    Camera_Outputs : RGB port map(din,pclk,hsync,red,green,blue);

    frame_rate : VSYNC port map(trigger,clk,'0',v_sync);

end architecture ; -- Structural