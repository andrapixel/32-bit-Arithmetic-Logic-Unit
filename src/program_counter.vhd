library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 32 bit counter that returns the address of the current instruction in the instruction memory
entity program_counter is
  Port (clk, en, clear: in std_logic;
  addr: out std_logic_vector(31 downto 0));
end program_counter;

architecture Behavioral of program_counter is
-- signals region
signal cnt: std_logic_vector(31 downto 0) := x"00000000";

begin

counter: process(clk, clear) 
begin 

if clear = '1' then
    cnt <= x"00000000";
else
    if rising_edge(clk) then
        if en = '1' then
            cnt <= cnt + 1;
        end if;
    end if;
end if;

end process;

addr <= cnt;

end Behavioral;
