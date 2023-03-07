library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Rising Edge D flip-flop
entity D_flip_flop is
  Port (clk, D: in std_logic;
  Q: out std_logic);
end D_flip_flop;

architecture Behavioral of D_flip_flop is
begin

D_ff_proc: process(clk)
begin

if rising_edge(clk) then
    Q <= D;
end if;


end process;

end Behavioral;
