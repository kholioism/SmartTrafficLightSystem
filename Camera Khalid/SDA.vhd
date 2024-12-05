library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_FSM is
    Port (
        clk         : in  std_logic;      -- Input clock (100 MHz)
        reset       : in  std_logic;      -- Asynchronous reset
        start_comm  : in  std_logic;      -- Start I2C communication signal
        byte_data   : in  std_logic_vector(7 downto 0); -- 8-bit data to send
        sda         : out std_logic;      -- SDA line for data transfer
        scl         : in  std_logic;      -- SCL line (clock)
        ack_received : out std_logic      -- Output ACK/NACK received from slave
    );
end I2C_FSM;

architecture Behavioral of I2C_FSM is
    -- Define state encoding
    type state_type is (IDLE, START, SEND_BYTE, WAIT_ACK, STOP_);
    signal state, next_state : state_type;
    
    -- Internal signal to control bit position in the byte
    signal bit_pos : integer range 0 to 7 := 0;
    
begin
    -- FSM process for controlling SDA pin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            bit_pos <= 0;
            sda <= '1';  -- Default SDA state HIGH
        elsif rising_edge(clk) then
            state <= next_state;  -- Update state
            if state = SEND_BYTE then
                -- Control the SDA line for data transmission
                sda <= byte_data(bit_pos);  -- Place data bit on SDA
            end if;
        end if;
    end process;
    
    -- State transition logic
    process(state, start_comm, ack_received)
    begin
        -- Default to idle state
        next_state <= state;
        case state is
            when IDLE =>
                if start_comm = '1' then
                    next_state <= START;  -- Start communication
                end if;

            when START =>
                next_state <= SEND_BYTE;  -- After start, begin sending data
                
            when SEND_BYTE =>
                if bit_pos = 7 then
                    next_state <= WAIT_ACK;  -- After 8 bits, wait for ACK
                else
                    next_state <= SEND_BYTE;  -- Continue sending byte
                end if;
                
            when WAIT_ACK =>
                if ack_received = '1' then
                    next_state <= STOP_;  -- ACK received, send stop condition
                else
                    next_state <= SEND_BYTE;  -- NACK received, retransmit byte
                end if;

            when STOP_ =>
                next_state <= IDLE;  -- After stop, return to idle
        end case;
    end process;
    
    -- Logic to increment bit_pos after each clock cycle in SEND_BYTE state
    process(state)
    begin
        if state = SEND_BYTE then
            if rising_edge(scl) then
                bit_pos <= bit_pos + 1;  -- Move to next bit in the byte
            end if;
        else
            bit_pos <= 0;  -- Reset bit_pos when not in SEND_BYTE
        end if;
    end process;

end Behavioral;
