library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OV7670_to_VGA is
    Port (
        -- Camera Inputs
        clk        : in STD_LOGIC;       -- FPGA Clock (100 MHz)
        reset      : in STD_LOGIC;       -- Active high reset
        VSYNC      : in STD_LOGIC;       -- Vertical sync from OV7670
        HSYNC      : in STD_LOGIC;       -- Horizontal sync from OV7670
        PCLK       : in STD_LOGIC;       -- Pixel clock from OV7670
        HREF       : in STD_LOGIC;       -- Horizontal reference from OV7670
        D0         : in STD_LOGIC;       -- Data bit 0 from OV7670
        D1         : in STD_LOGIC;       -- Data bit 1 from OV7670
        D2         : in STD_LOGIC;       -- Data bit 2 from OV7670
        D3         : in STD_LOGIC;       -- Data bit 3 from OV7670
        D4         : in STD_LOGIC;       -- Data bit 4 from OV7670
        D5         : in STD_LOGIC;       -- Data bit 5 from OV7670
        D6         : in STD_LOGIC;       -- Data bit 6 from OV7670
        D7         : in STD_LOGIC;       -- Data bit 7 from OV7670

        -- VGA Outputs
        VGA_HSYNC  : out STD_LOGIC;      -- Horizontal sync for VGA
        VGA_VSYNC  : out STD_LOGIC;      -- Vertical sync for VGA
        VGA_R      : out STD_LOGIC_VECTOR(3 downto 0); -- Red component of pixel
        VGA_G      : out STD_LOGIC_VECTOR(3 downto 0); -- Green component of pixel
        VGA_B      : out STD_LOGIC_VECTOR(3 downto 0); -- Blue component of pixel
        VGA_CLK    : out STD_LOGIC;      -- VGA pixel clock
        VGA_BLANK  : out STD_LOGIC;      -- VGA blank signal
        VGA_SYNC   : out STD_LOGIC       -- VGA sync signal
    );
end OV7670_to_VGA;
architecture Behavioral of OV7670_to_VGA is
    -- Internal signals for synchronization and pixel data
    signal pclk_reg    : STD_LOGIC := '0';
    signal href_reg    : STD_LOGIC := '0';
    signal vsync_reg   : STD_LOGIC := '0';
    signal hsync_reg   : STD_LOGIC := '0';
    signal pixel_data  : STD_LOGIC_VECTOR(7 downto 0); -- 8-bit pixel data

    -- VGA timing parameters for 640x480 @ 60 Hz
    constant H_SYNC_CYCLES   : integer := 800; -- Total width of horizontal period (800)
    constant H_SYNC_ACTIVE   : integer := 640; -- Active video width (640)
    constant H_SYNC_FRONT    : integer := 16;  -- Front porch (16)
    constant H_SYNC_PULSE    : integer := 96;  -- Sync pulse width (96)
    
    constant V_SYNC_CYCLES   : integer := 525; -- Total height of vertical period (525)
    constant V_SYNC_ACTIVE   : integer := 480; -- Active video height (480)
    constant V_SYNC_FRONT    : integer := 10;  -- Front porch (10)
    constant V_SYNC_PULSE    : integer := 2;   -- Sync pulse width (2)
    
    -- Counters for VGA timing
    signal h_counter        : integer := 0;
    signal v_counter        : integer := 0;
    signal pixel_ready      : STD_LOGIC := '0';

    -- Internal signal for timing management
    signal display_active    : STD_LOGIC := '0';
begin

    -- Process to handle pixel clock and synchronization
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset logic
            h_counter <= 0;
            v_counter <= 0;
            pixel_ready <= '0';
            pclk_reg <= '0';
            href_reg <= '0';
            vsync_reg <= '0';
            hsync_reg <= '0';
        elsif rising_edge(clk) then
            -- Update the pixel clock
            pclk_reg <= PCLK;
            href_reg <= HREF;
            vsync_reg <= VSYNC;
            hsync_reg <= HSYNC;

            -- Pixel capture based on PCLK and HREF
            if pclk_reg = '1' and href_reg = '1' then
                pixel_data <= (D7 & D6 & D5 & D4 & D3 & D2 & D1 & D0);
                pixel_ready <= '1';  -- Data is ready for display
            else
                pixel_ready <= '0';  -- No valid data
            end if;

            -- Horizontal counter logic
            if h_counter = H_SYNC_CYCLES - 1 then
                h_counter <= 0;
                if v_counter = V_SYNC_CYCLES - 1 then
                    v_counter <= 0; -- Reset vertical counter
                else
                    v_counter <= v_counter + 1;
                end if;
            else
                h_counter <= h_counter + 1;
            end if;

            -- VGA synchronization generation
            if h_counter < H_SYNC_PULSE then
                VGA_HSYNC <= '0';  -- Horizontal sync pulse
            else
                VGA_HSYNC <= '1';
            end if;

            if v_counter < V_SYNC_PULSE then
                VGA_VSYNC <= '0';  -- Vertical sync pulse
            else
                VGA_VSYNC <= '1';
            end if;

            -- Generate VGA color signals (simple pass-through for now)
            if h_counter < H_SYNC_ACTIVE and v_counter < V_SYNC_ACTIVE then
                display_active <= '1';
            else
                display_active <= '0';
            end if;

            if display_active = '1' then
                -- Set VGA color output based on pixel data (simple RGB pass-through)
                VGA_R <= pixel_data(7 downto 4);  -- Red channel
                VGA_G <= pixel_data(5 downto 2);  -- Green channel
                VGA_B <= pixel_data(3 downto 0);  -- Blue channel
                VGA_BLANK <= '0';  -- Pixel data is active
            else
                VGA_R <= "0000";  -- No data, blanking
                VGA_G <= "0000";
                VGA_B <= "0000";
                VGA_BLANK <= '1';  -- Blanking
            end if;

            -- VGA Sync signal (combined H/V sync)
            VGA_SYNC <= '0';
        end if;
    end process;
end Behavioral;
