library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--**********************************************************************************
--*
--*  Name: SynchronizerChain
--*  Designer: Scott Tippens
--*
--*      This component implements a synchronization chain for use with asynchronous 
--*      inputs or clock-domain crossing signals.  The size of the synchronization
--*      chain is determined by the CHAIN_SIZE generic parameter.
--*
--**********************************************************************************
entity SynchronizerChain is
	generic (CHAIN_SIZE: positive);
    port (
    	reset:    in  std_logic;
        clock:    in  std_logic;
    	asyncIn:  in  std_logic;
        syncOut:  out std_logic
    );
end SynchronizerChain;



architecture SynchronizerChain_ARCH of SynchronizerChain is
	constant ACTIVE:  std_logic := '1';
	signal syncChain: std_logic_vector(CHAIN_SIZE-1 downto 0);

begin
	process(reset, clock)
	begin
		if (reset=ACTIVE) then
			syncChain <= (others => '0');
		elsif (rising_edge(clock)) then
			syncChain <= syncChain(syncChain'high-1 downto 0) & asyncIn;
		end if;
	end process;

	syncOut <= syncChain(syncChain'high);

end SynchronizerChain_ARCH;
