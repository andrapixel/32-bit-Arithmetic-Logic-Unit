library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1 bit OR gate
entity or_gate is
  Port (a, b: in std_logic;
  res: out std_logic);          
end or_gate;

architecture Behavioral of or_gate is
begin

res <= a or b;

end Behavioral;
