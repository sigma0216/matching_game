----------------------------------------------------------------------------------
-- Basys3_MatchingGame
--
--  Interfaces the MatchingGame component with the Basys3 
--  development board.
--
--  Designer: Ethan Ellis
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Basys3_MatchingGame is
    Port (
        btnD: in std_logic;
        btnL: in std_logic;
        btnR: in std_logic;
        btnC: in std_logic;
        clk: in std_logic;
        sw: in std_logic_vector(15 downto 0);
        seg: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(3 downto 0);
        led: out std_logic_vector(15 downto 0)
    );
end Basys3_MatchingGame;

architecture Basys3_MatchingGame_ARCH of Basys3_MatchingGame is
    component MatchingGame
        port (
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
    end component MatchingGame;
begin
    MY_GAME: MatchingGame port map (
        clock => clk,
        reset => btnC,
        plr1Switches => sw(15 downto 9),
        plr2Switches => sw(6 downto 0),
        plr1Raw => btnL,
        plr2Raw => btnR,
        startRoundRaw => btnD,
        sevenSegs => seg,
        anodes => an,
        leds => led
    );
end Basys3_MatchingGame_ARCH;
