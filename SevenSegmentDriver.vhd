library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--*****************************************************************************
--*
--* Name: SevenSegmentDriver
--* Designer: Scott Tippens
--*
--*     This component serves as a numeric driver for a 4 digit seven-segment
--*     display with shared segments and selectable anodes.  It can display
--*     any numeric digit represented by a 4-bit value ('0'-'F') and provides
--*     the ability to selectively blank any digit of the display using
--*     blanking control input signals.
--*
--*     This component is designed to multiplex the 4 seven-segment displays at
--*     a scan rate of 1 kHz.
--*
--*
--*    Note: Added functionality for the Matching Game added by Ethan Ellis
--*
--*****************************************************************************


entity SevenSegmentDriver is
    port(
        reset: in std_logic;
        clock: in std_logic;

        digit3: in std_logic_vector(4 downto 0);    --leftmost digit
        digit2: in std_logic_vector(4 downto 0);    --2nd from left digit
        digit1: in std_logic_vector(4 downto 0);    --3rd from left digit
        digit0: in std_logic_vector(4 downto 0);    --rightmost digit

        blank3: in std_logic;    --leftmost digit
        blank2: in std_logic;    --2nd from left digit
        blank1: in std_logic;    --3rd from left digit
        blank0: in std_logic;    --rightmost digit

        sevenSegs: out std_logic_vector(6 downto 0);    --MSB=g, LSB=a
        anodes:    out std_logic_vector(3 downto 0);    --MSB=leftmost digit
        
        plr1Pattern: in std_logic_vector(6 downto 0);
        plr2Pattern: in std_logic_vector(6 downto 0);
        makePattern: in std_logic;
        patternSet: out std_logic;
        
        plr1Correct: out std_logic;
        plr2Correct: out std_logic
    );
end SevenSegmentDriver;



architecture SevenSegmentDriver_ARCH of SevenSegmentDriver is

    ----general definitions----------------------------------------------CONSTANTS
    constant ACTIVE: std_logic := '1';
--    constant COUNT_1KHZ: integer := (100000000/1000)-1;
    constant COUNT_1KHZ: integer := 100; --For Simulation

    ----anode settings for digit selection-------------------------------CONSTANTS
    constant SELECT_DIGIT_0: std_logic_vector(3 downto 0)   := "1110";
    constant SELECT_DIGIT_1: std_logic_vector(3 downto 0)   := "1101";
    constant SELECT_DIGIT_2: std_logic_vector(3 downto 0)   := "1011";
    constant SELECT_DIGIT_3: std_logic_vector(3 downto 0)   := "0111";
    constant SELECT_NO_DIGITS: std_logic_vector(3 downto 0) := "1111";

    ----normal seven segment display-------------------------------------CONSTANTS
    constant ZERO_7SEG: std_logic_vector(6 downto 0)  := "1000000";
    constant ONE_7SEG: std_logic_vector(6 downto 0)   := "1111001";
    constant TWO_7SEG: std_logic_vector(6 downto 0)   := "0100100";
    constant THREE_7SEG: std_logic_vector(6 downto 0) := "0110000";
    constant FOUR_7SEG: std_logic_vector(6 downto 0)  := "0011001";
    constant FIVE_7SEG: std_logic_vector(6 downto 0)  := "0010010";
    constant SIX_7SEG: std_logic_vector(6 downto 0)   := "0000010";
    constant SEVEN_7SEG: std_logic_vector(6 downto 0) := "1111000";
    constant EIGHT_7SEG: std_logic_vector(6 downto 0) := "0000000";
    constant NINE_7SEG: std_logic_vector(6 downto 0)  := "0011000";
    constant A_7SEG: std_logic_vector(6 downto 0)     := "0001000";
    constant B_7SEG: std_logic_vector(6 downto 0)     := "0000011";
    constant C_7SEG: std_logic_vector(6 downto 0)     := "1000110";
    constant D_7SEG: std_logic_vector(6 downto 0)     := "0100001";
    constant E_7SEG: std_logic_vector(6 downto 0)     := "0000110";
    constant F_7SEG: std_logic_vector(6 downto 0)     := "0001110";

    ----internal connections-----------------------------------------------SIGNALS
    signal enableCount: std_logic;
    signal selectedBlank: std_logic;
    signal selectedDigit: std_logic_vector(4 downto 0);
    signal digitSelect: unsigned(1 downto 0);
    signal pattern: std_logic_vector(6 downto 0);
    
    signal random: integer range 0 to 127;

begin

    --============================================================================
    --  Convert 4-bit binary value into its equivalent 7-segment pattern
    --============================================================================
    BINARY_TO_7SEG: with selectedDigit select
        sevenSegs <= ZERO_7SEG   when "00000",
                     ONE_7SEG    when "00001",
                     TWO_7SEG    when "00010",
                     THREE_7SEG  when "00011",
                     FOUR_7SEG   when "00100",
                     FIVE_7SEG   when "00101",
                     SIX_7SEG    when "00110",
                     SEVEN_7SEG  when "00111",
                     EIGHT_7SEG  when "01000",
                     NINE_7SEG   when "01001",
                     A_7SEG      when "01010",
                     B_7SEG      when "01011",
                     C_7SEG      when "01100",
                     D_7SEG      when "01101",
                     E_7SEG      when "01110",
                     F_7SEG      when "01111",
                     pattern     when "10000",
                     plr1Pattern when "10001",
                     plr2Pattern when others;


    --============================================================================
    --  Select the current digit to display
    --============================================================================
    DIGIT_SELECT: with digitSelect select
        selectedDigit <= digit0 when "00",
                         digit1 when "01",
                         digit2 when "10",
                         digit3 when others;


    --============================================================================
    --  Select the current digit to display
    --============================================================================
    BLANK_SELECT: with digitSelect select
        selectedBlank <= blank0 when "00",
                         blank1 when "01",
                         blank2 when "10",
                         blank3 when others;


    --============================================================================
    --  Select the current digit in the seven-segment display unless the
    --  selectedBlank input is active.
    --============================================================================
    ANODE_SELECT: process(selectedBlank, digitSelect)
    begin
        if (selectedBlank = ACTIVE) then
            anodes <= SELECT_NO_DIGITS;
        else
            case digitSelect is
                when "00" =>    anodes <= SELECT_DIGIT_0;
                when "01" =>    anodes <= SELECT_DIGIT_1;
                when "10" =>    anodes <= SELECT_DIGIT_2;
                when others =>  anodes <= SELECT_DIGIT_3;
            end case;
        end if;
    end process ANODE_SELECT;


    --============================================================================
    --  Set the scan rate for the multiplexed seven-segment displays to 1 kHz.
    --  The enableCount output pulses for one clock cycle at a rate of 1 kHz.
    --============================================================================
    SCAN_RATE: process(reset, clock)
        variable count: integer range 0 to COUNT_1KHZ;
    begin
    	--manage-count-value--------------------------------------------
        if (reset = ACTIVE) then
            count := 0;
        elsif (rising_edge(clock)) then
            if (count = COUNT_1KHZ) then
                count := 0;
            else
                count := count + 1;
            end if;
        end if;
        
        --update-enable-signal-------------------------------------------
        enableCount <= not ACTIVE;  --default value unless count reaches terminal
        if (count=COUNT_1KHZ) then
        	enableCount <= ACTIVE;
        end if;
    end process SCAN_RATE;


    --============================================================================
    --  Generates the digit selection value
    --============================================================================
    DIGIT_COUNT: process(reset, clock)
    begin
        if (reset = ACTIVE) then
            digitSelect <= "00";
        elsif (rising_edge(clock)) then
            if (enableCount = ACTIVE) then
                digitSelect <= digitSelect + 1;
            end if;
        end if;
    end process DIGIT_COUNT;
    
    --============================================================================
    --  Generates the pattern to match
    --============================================================================
    CREATE_PATTERN: process(reset, clock)
--        variable random: unsigned(6 downto 0);
        variable patternMade: std_logic := '0';
    begin
        if (reset = ACTIVE) then
            random <= 0;
        elsif(rising_edge(clock)) then
            if (makePattern = ACTIVE and patternMade = not ACTIVE) then
                pattern <= std_logic_vector(to_unsigned(random, 7));
                patternMade := ACTIVE;
                patternSet <= ACTIVE;
            elsif(makePattern = not ACTIVE) then
                patternSet <= not ACTIVE;
                patternMade := not ACTIVE;
            end if;
            
            random <= random + 1;
            if (random = 127) then
                random <= 0;
            end if;
        end if;
    end process CREATE_PATTERN;
    
    --============================================================================
    --  Determines if the player patterns match the generated pattern.
    --============================================================================
    PATTERN_CHECK: process(reset, clock)
    begin
        if (reset = ACTIVE) then
            plr1Correct <= not ACTIVE;
            plr2Correct <= not ACTIVE;
        else
            if (plr1Pattern = pattern) then
                plr1Correct <= ACTIVE;
            else
                plr1Correct <= not ACTIVE;
            end if;
            if (plr2Pattern = pattern) then
                plr2Correct <= ACTIVE;
            else
                plr2Correct <= not ACTIVE;
            end if;
        end if;
    end process PATTERN_CHECK;  
    
    

end SevenSegmentDriver_ARCH;
