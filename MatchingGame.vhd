----------------------------------------------------------------------------------
-- 
-- MatchingGame
--
--  This component is a 2 player game where each player has to flip switches
--  that control a 7 segment display. 2 of the displays will show a pattern
--  that the players must match with their display. If the first person to enter
--  is correct, they get a point. If they are not correct, the second player will
--  be checked to see if they are correct and get a point. There is a 16 second
--  timer shown with LEDs. The players must enter their answer before the timer
--  runs out. 
--
--  Designer: Ethan Ellis
--      Also using components designed by Scott Tippens
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.game_package.all;

entity MatchingGame is
    Port ( 
           clock: in std_logic;
           reset: in std_logic;
           plr1Switches: in std_logic_vector(6 downto 0);
           plr2Switches: in std_logic_vector(6 downto 0);
           plr1Raw: in std_logic;
           plr2Raw: in std_logic;
           startRoundRaw: in std_logic;
           sevenSegs: out std_logic_vector(6 downto 0);
           anodes: out std_logic_vector(3 downto 0);
           leds: out std_logic_vector(15 downto 0)
     );
end MatchingGame;

architecture MatchingGame_ARCH of MatchingGame is
    
    -----------------------------------------------Constants
    constant ACTIVE: std_logic := '1';
--    constant SIXTEEN_SEC: integer := 100000000;
    constant SIXTEEN_SEC: integer := 100; -- For Simulation
    constant NONE_FIRST: std_logic_vector := "00";
    constant PLR1_FIRST: std_logic_vector := "01";
    constant PLR2_FIRST: std_logic_vector := "10";
    constant SCORE_DISP: std_logic := '0';
    constant PATT_DISP:  std_logic := '1';
    constant PATT:       std_logic_vector := "0000";
    constant PLR1_PATT:  std_logic_vector := "0001";
    constant PLR2_PATT:  std_logic_vector := "0010";
    
    -------------------------------------------------Signals
    --Button Synchronization signals
    signal plr1Sync:  std_logic;
    signal plr2Sync:  std_logic;
    signal plr1Enter: std_logic;
    signal plr2Enter: std_logic;
    
    signal startRoundSync: std_logic;
    signal startRound:     std_logic;
    
    --Gameplay Signals
    signal startTimer:   std_logic;
    signal plr1Score:    integer;
    signal plr2Score:    integer;
    signal plr1ScoreBCD: std_logic_vector(7 downto 0);
    signal plr2ScoreBCD: std_logic_vector(7 downto 0);
    signal makePattern:  std_logic;
    signal patternSet:   std_logic;
    signal plr1Entered:   std_logic;
    signal plr2Entered:   std_logic;
    signal timerFinished: std_logic;
    signal timerStarted:  std_logic;
    signal stopTimer:     std_logic;
    signal firstPlayer:   std_logic_vector(1 downto 0);
    
    --Scoring
    signal patternsChecked: std_logic;
    signal plr1Correct:     std_logic;
    signal plr2Correct:     std_logic;
    signal plr1Point:       std_logic;
    signal plr2Point:       std_logic;
    signal plr1Add:         std_logic;
    signal plr2Add:         std_logic;
    
    --Display Signals
    signal digit3: std_logic_vector(4 downto 0);
    signal digit2: std_logic_vector(4 downto 0);
    signal digit1: std_logic_vector(4 downto 0);
    signal digit0: std_logic_vector(4 downto 0);
    
    --Sates
    type States_t is (SHOW_SCORE, SET_PATTERN, PLAYER_ROUND, CHECK_PATTERNS);
    signal currentState: States_t;
    signal nextState:    States_t;
    
    
begin
    --Player 1 Sync
	SYNC_PLR1: SynchronizerChain
		generic map (CHAIN_SIZE => 2)
		port map (
			reset => reset,
			clock => clock,
			asyncIn => plr1Raw,
			syncOut => plr1Sync
	   );
    --Player 1 Pulse
	PLR1_ENABLE: LevelDetector 
        port map (
            reset    => reset,
		    clock    => clock,
		    trigger  => plr1Sync,
		    pulseOut => Plr1Enter
	    );
	--Player 2 Sync
	SYNC_PLR2: SynchronizerChain
		generic map (CHAIN_SIZE => 2)
		port map (
			reset => reset,
			clock => clock,
			asyncIn => plr2Raw,
			syncOut => plr2Sync
		);
    --Player 2 Pulse
	PLR2_ENABLE: LevelDetector 
        port map (
            reset    => reset,
            clock    => clock,
            trigger  => plr2Sync,
            pulseOut => plr2Enter
	    );
	--Start Sync
	SYNC_START: SynchronizerChain
		generic map (CHAIN_SIZE => 2)
		port map (
			reset => reset,
			clock => clock,
			asyncIn => startRoundRaw,
			syncOut => startRoundSync
			);
    --Start Pulse
	START_ENABLE: LevelDetector 
        port map (
            reset    => reset,
		    clock    => clock,
		    trigger  => startRoundSync,
		    pulseOut => startRound
	    );
	
	--Gameplay Timer
    LED_TIMER: LedTimer
        generic map (TIMER_LENGTH => SIXTEEN_SEC)
        port map (
            reset => reset,
            clock => clock,
            startTimer => startTimer,
            leds => leds,
            timerFinished => timerFinished,
            timerStarted => timerStarted,
            stopTimer => stopTimer
        );
    
    --Display Driver
    SEGMENTS: SevenSegmentDriver 
        port map (
            reset  => reset,
            clock  => clock,
            digit3 => digit3,
            digit2 => digit2,
            digit1 => digit1,
            digit0 => digit0,
            blank3 => not ACTIVE,
            blank2 => not ACTIVE,
            blank1 => not ACTIVE,
            blank0 => not ACTIVE,
            sevenSegs => sevenSegs,
            anodes    => anodes,
            
            plr1Pattern => plr1Switches,
            plr2Pattern => plr2Switches,
            makePattern => makePattern,
            patternSet => patternSet,
            
            plr1Correct => plr1Correct,
            plr2Correct => plr2Correct
        );
    
    --Player 1 Scoring
    PLR1_ADD: count_to_99(
        reset => reset,
        clock => clock,
        countEn => plr1Add,
        count => plr1Score
    );
    PLR1_SCORE: LevelDetector 
        port map (
            reset    => reset,
		    clock    => clock,
		    trigger  => plr1Point,
		    pulseOut => plr1Add
	   );
    
    --Player 2 Scoring
    PLR2_ADD: count_to_99(
        reset => reset,
        clock => clock,
        countEn => plr2Add,
        count => plr2Score
    );
    PLR2_SCORE: LevelDetector 
        port map (
            reset    => reset,
		    clock    => clock,
		    trigger  => plr2Point,
		    pulseOut => plr2Add
	   );
    --Converting Scores to BCD
    plr1ScoreBCD <= to_bcd_8bit(plr1Score);
    plr2ScoreBCD <= to_bcd_8bit(plr2Score);
    
    ------------------------------------------------------State Machine
    STATE_REGISTER: process(reset, clock)
    begin
        if (reset = ACTIVE) then
            currentState <= SHOW_SCORE;
        elsif (rising_edge(clock)) then
            currentState <= nextState;
        end if;            
    end process;
    STATE_TRANSITION: process(currentState, clock)
    begin
         case currentState is
            when SHOW_SCORE =>
                if (startRound = ACTIVE) then
                    nextState <= SET_PATTERN;
                else
                    nextState <= SHOW_SCORE;
                    stopTimer <= ACTIVE;
                    startTimer <= not ACTIVE;
                    makePattern <= not ACTIVE;
                end if;
            when SET_PATTERN =>
                if (patternSet = ACTIVE and timerStarted = ACTIVE) then
                    nextState <= PLAYER_ROUND;
                else
                    nextState <= SET_PATTERN;
                    stopTimer <= not ACTIVE;
                    makePattern <= ACTIVE;
                    startTimer <= ACTIVE;
                end if;
            when PLAYER_ROUND =>
                if ((plr1Entered = ACTIVE and plr2Entered = ACTIVE) or timerFinished = ACTIVE) then
                    nextState <= CHECK_PATTERNS;
                else
                    nextState <= PLAYER_ROUND;
                    makePattern <= not ACTIVE;
                    startTimer <= not ACTIVE;
                end if;
            when CHECK_PATTERNS =>
                if (patternsChecked = ACTIVE) then
                    nextState <= SHOW_SCORE;
                else
                    nextState <= CHECK_PATTERNS;
                end if;
        end case;
    end process;
    
    --------------------------------------------------------------
    -- Player Enter Control
    -- 
    -- Determines the order in which players entered their answers
    --------------------------------------------------------------
    PLAYER_ENTERING: process(clock, reset)
    begin
        if(reset = ACTIVE) then
            plr1Entered <= not ACTIVE;
            plr2Entered <= not ACTIVE;
        elsif(rising_edge(clock)) then
            if(currentState = PLAYER_ROUND) then
                if(plr1Enter = ACTIVE) then
                    plr1Entered <= ACTIVE;
                    if(plr2Entered = not ACTIVE) then
                        firstPlayer <= PLR1_FIRST;
                    end if;
                end if;
                if(plr2Enter = ACTIVE) then
                    plr2Entered <= ACTIVE;
                    if(plr1Entered = not ACTIVE) then
                        firstPlayer <= PLR2_FIRST;
                    end if;
                end if;
            else
                firstPlayer <= NONE_FIRST;
                plr1Entered <= not ACTIVE;
                plr2Entered <= not ACTIVE;
            end if;
        end if;
    end process;
    
    ---------------------------------------------------------------
    -- Scoring
    --
    -- The first player gets checked first and awarded a point if
    -- correct. If not, the second player gets checked (assuming
    -- they entered as well) and gets awarded a point if correct. 
    ---------------------------------------------------------------
    SCORE: process(clock, reset)
    begin
        if (reset = ACTIVE) then
            plr1Point <= not ACTIVE;
            plr2Point <= not ACTIVE;
        elsif(rising_edge(clock)) then
            if(currentState = CHECK_PATTERNS) then
                case firstPlayer is
                    when PLR1_FIRST =>
                        if(plr1Correct = ACTIVE) then
                            plr1Point <= ACTIVE;
                            plr2Point <= not ACTIVE;
                        elsif(plr2Correct = ACTIVE and plr2Entered = ACTIVE) then
                            plr2Point <= ACTIVE;
                            plr1Point <= not ACTIVE;
                        end if;
                    when PLR2_FIRST =>
                        if(plr2Correct = ACTIVE) then
                            plr2Point <= ACTIVE;
                            plr1Point <= not ACTIVE;
                        elsif(plr1Correct = ACTIVE and plr2Entered = ACTIVE) then
                            plr1Point <= ACTIVE;
                            plr2Point <= not ACTIVE;
                        end if;
                    when others =>
                        plr1Point <= not ACTIVE;
                        plr2Point <= not ACTIVE;
                end case;
                patternsChecked <= ACTIVE;
            else
                patternsChecked <= not ACTIVE;
                plr1Point <= not ACTIVE;
                plr2Point <= not ACTIVE;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------
    -- Display Control
    -- 
    --  Determines what the display will show depending on the 
    --  current state. It will show the pattern while the round
    --  is in progress and the scores otherwise. 
    ----------------------------------------------------------------
    DISPLAY: process(clock, reset)
    begin
        if (reset = ACTIVE) then
        elsif(rising_edge(clock)) then
            case currentState is
                when PLAYER_ROUND =>
                    digit3 <= PATT_DISP & PATT;
                    digit1 <= PATT_DISP & PATT;
                    
                    digit2 <= PATT_DISP & PLR1_PATT;
                    digit0 <= PATT_DISP & PLR2_PATT;
                when others =>
                    digit3 <= SCORE_DISP & plr1ScoreBCD(7 downto 4);
                    digit2 <= SCORE_DISP & plr1ScoreBCD(3 downto 0);
                    digit1 <= SCORE_DISP & plr2ScoreBCD(7 downto 4);
                    digit0 <= SCORE_DISP & plr2ScoreBCD(3 downto 0);
             end case;
                    
        end if;
    end process;
    

end MatchingGame_ARCH;
