library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--**********************************************************************************
--*
--*  Name: LevelDetector
--*  Designer: Scott Tippens
--*
--*      This component generates a one-cycle clock pulse whenever the trigger
--*      input goes from a LOW to a HIGH level.  Holding the trigger signal ACTIVE
--*      for extended periods of time will not generate additional pulses.  The
--*      trigger signal must fall low prior to generating another pulse.
--*
--**********************************************************************************
entity LevelDetector is
    port (
    	reset:     in  std_logic;
        clock:     in  std_logic;
    	trigger:   in  std_logic;
        pulseOut:  out std_logic
    );
end LevelDetector;



architecture LevelDetector_ARCH of LevelDetector is

	constant ACTIVE:  std_logic := '1';

begin
	process(reset, clock)
		variable held: std_logic;
	begin
		if (reset=ACTIVE) then
			pulseOut <= not ACTIVE;
			held        := not ACTIVE;
		elsif (rising_edge(clock)) then
			pulseOut <= not ACTIVE;
			if (trigger=ACTIVE) then
				if (held = not ACTIVE) then
					pulseOut <= ACTIVE;
					held        := ACTIVE;
				end if;
			else
				held := not ACTIVE;
			end if;
		end if;
	end process;

end LevelDetector_ARCH;
