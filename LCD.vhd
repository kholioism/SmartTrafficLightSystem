library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LCD1602_I2C is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        SDA       : inout STD_LOGIC;
        SCL       : out  STD_LOGIC
    );
end LCD1602_I2C;

architecture Behavioral of LCD1602_I2C is

    constant I2C_ADDRESS : STD_LOGIC_VECTOR(6 downto 0) := "0111100";
    constant CMD_PREFIX  : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    constant DATA_PREFIX : STD_LOGIC_VECTOR(7 downto 0) := x"40";

    type state_type is (IDLE, START, ADDRESS, ACK_ADDRESS, CMD, ACK_CMD, DATA, ACK_DATA, STOP);
    signal state : state_type := IDLE;

    signal clk_div     : integer := 0;
    signal scl_toggle  : STD_LOGIC := '0';
    constant CLK_DIV_MAX : integer := 500;

    type message_array_type is array(0 to 15) of std_logic_vector(7 downto 0);
    constant MESSAGE : message_array_type := (
        x"48", -- 'H'
        x"65", -- 'e'
        x"6C", -- 'l'
        x"6C", -- 'l'
        x"6F", -- 'o'
        x"2C", -- ','
        x"20", -- ' '
        x"4C", -- 'L'
        x"43", -- 'C'
        x"44", -- 'D'
        x"31", -- '1'
        x"36", -- '6'
        x"30", -- '0'
        x"32", -- '2'
        x"21", -- '!'
        x"00"  -- Null terminator
    );
    signal char_index : integer range 0 to MESSAGE'length := 0;

    signal SDA_out : STD_LOGIC := '1';
    signal SDA_dir : STD_LOGIC := '1';
    signal SCL_signal: STD_LOGIC;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            clk_div <= 0;
            scl_toggle <= '0';
        elsif rising_edge(clk) then
            if clk_div = CLK_DIV_MAX then
                clk_div <= 0;
                scl_toggle <= not scl_toggle;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    SCL_signal <= scl_toggle;
    SCL <= SCL_signal;

    SDA <= 'Z' when SDA_dir = '1' else SDA_out;

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            SDA_out <= '1';
            SDA_dir <= '1';
            char_index <= 0;
        elsif falling_edge(SCL_signal) then
            case state is
                when IDLE =>
                    state <= START;

                when START =>
                    SDA_dir <= '0';
                    SDA_out <= '0';
                    state <= ADDRESS;

                when ADDRESS =>
                    SDA_out <= I2C_ADDRESS(6 - char_index);
                    if char_index = 6 then
                        char_index <= 0;
                        state <= ACK_ADDRESS;
                    else
                        char_index <= char_index + 1;
                    end if;

                when ACK_ADDRESS =>
                    SDA_dir <= '1';
                    if SDA = '0' then
                        state <= CMD;
                    end if;

                when CMD =>
                    SDA_dir <= '0';
                    SDA_out <= CMD_PREFIX(7 - char_index);
                    if char_index = 7 then
                        char_index <= 0;
                        state <= ACK_CMD;
                    else
                        char_index <= char_index + 1;
                    end if;

                when ACK_CMD =>
                    SDA_dir <= '1';
                    if SDA = '0' then
                        state <= DATA;
                    end if;

                when DATA =>
                    SDA_dir <= '0'; -- Drive SDA
                    SDA_out <= MESSAGE(char_index)(7 - clk_div mod 8); -- Send bit by bit
                    if clk_div mod 8 = 7 then -- After sending all bits of a byte
                        if char_index = MESSAGE'length - 1 then
                            char_index <= 0; -- Reset for next message
                            state <= STOP; -- Go to STOP state
                        else
                            char_index <= char_index + 1; -- Move to next character
                        end if;
                    end if;


                when STOP =>
                    SDA_out <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;
