library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1 bit NOT gate
entity not_gate is
  Port (a: in std_logic;
  res: out std_logic);
end not_gate;

architecture Behavioral of not_gate is
begin

res <= not a;

end Behavioral;
