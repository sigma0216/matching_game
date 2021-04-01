----------------------------------------------------------------------------------
-- LedTimer
--
--  This component uses a string of leds and makes a timer. The length of the
--  timer is determined by the generic TIMER_LENGTH. Note that this number is
--  how long it takes for an LED to turn off, not the full length of the timer.
--
--   Designer: Ethan Ellis
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LedTimer is
    generic (TIMER_LENGTH: integer);
    Port ( 
           leds:  out std_logic_vector(15 downto 0);
           startTimer: in std_logic;
           reset: in   std_logic;
           clock: in   std_logic;
           timerFinished: out std_logic;
           timerStarted: out std_logic;
           stopTimer: in std_logic
    );
end LedTimer;

--------------------------------------------------------------------Architecture
architecture LedTimer_ARCH of LedTimer is
    constant ACTIVE: std_logic := '1';
    constant FINISHED: unsigned(15 downto 0) := "0000000000000000";
    signal timer: unsigned(15 downto 0);
begin
    process(reset, clock)
        variable count: integer;
    begin
        if(reset = ACTIVE) then
            timer <= (others => not ACTIVE);
            leds <= (others => not ACTIVE);
            count := 0;
        elsif(rising_edge(clock)) then
            if(startTimer = ACTIVE) then
                timer <= (others => ACTIVE);
                timerFinished <= not ACTIVE;
                timerStarted <= ACTIVE;
            elsif(stopTimer = ACTIVE or timer = FINISHED) then
                timer <= FINISHED;
                timerFinished <= ACTIVE;
                timerStarted <= not ACTIVE;
            elsif(count = TIMER_LENGTH) then
                timer <= shift_left(timer, 1);
                count := 0;
            else
                count := count + 1;
            end if;
            leds <= std_logic_vector(timer);
        end if;
    end process;
end LedTimer_ARCH;
