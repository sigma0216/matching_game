----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2020 03:06:25 PM
-- Design Name: 
-- Module Name: MatchingGame_TB - MatchingGame_TB_ARCH
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MatchingGame_TB is
end MatchingGame_TB;

architecture MatchingGame_TB_ARCH of MatchingGame_TB is
    component MatchingGame
        port(
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
     end component;
        constant FINISHED: std_logic_vector := "0000000000000000";
     
        signal clock:  std_logic;
        signal reset:  std_logic;
        signal plr1Switches:  std_logic_vector(6 downto 0);
        signal plr2Switches:  std_logic_vector(6 downto 0);
        signal plr1Raw:  std_logic;
        signal plr2Raw:  std_logic;
        signal startRoundRaw:  std_logic;
        signal sevenSegs:  std_logic_vector(6 downto 0);
        signal anodes:  std_logic_vector(3 downto 0);
        signal leds:  std_logic_vector(15 downto 0);
     
begin

    --unit-under-test---------------------------------------UUT
    UUT: MatchingGame port map (
        clock => clock,
        reset => reset,
        plr1Switches => plr1Switches,
        plr2Switches => plr2Switches,
        plr1Raw => plr1Raw,
        plr2Raw => plr2Raw,
        startRoundRaw => startRoundRaw,
        sevenSegs => sevenSegs,
        anodes => anodes,
        leds => leds
    );
    -------------------------------------------------------Reset
    RESET_DRIVER: process
    begin
        reset <= '1';
        wait for 10 ps;
        reset <= '0';
        wait;
    end process;
    --------------------------------------------------------Clock
    CLOCK_DRIVER: process
    begin
        clock <= '1';
        wait for 5 ps;
        clock <= '0';
        wait for 5 ps;
    end process;
    
    -----------------------------------------------------Round Start
    START: process
    begin
        startRoundRaw <= '0';
        wait for 5 ns;
        startRoundRaw <= '1';
        wait for 5 ns;
        startRoundRaw <= '0';
        wait for 10 ns;
    end process;
    
    ----------------------------------------------------Switch Control
    SWITCH: process
    begin
        plr1Switches <= sevenSegs;
        plr2Switches <= sevenSegs;
        wait until anodes(1) = '1';
    end process;
    
    -----------------------------------------------------Pattern Entering
    ENTER: process
    begin
        plr1Raw <= '0';
        plr2Raw <= '0';
        wait until (leds(0) = '1');
        plr1Raw <= '1';
        wait until (leds(2) = '0');
        plr1Raw <= '0';
        wait until (leds(3) = '0');
        plr2Raw <= '1';
        wait until (leds(5) = '0');
        plr2Raw <= '0';
        wait for 10 ns;
        wait until (leds(0) = '1');
        plr2Raw <= '1';
        wait until (leds(2) = '0');
        plr2Raw <= '0';
        wait until (leds(3) = '0');
        plr1Raw <= '1';
        wait until (leds(5) = '0');
        plr1Raw <= '0';
        wait for 10 ns;
        wait until leds = FINISHED;
    end process;
    
    

end MatchingGame_TB_ARCH;
