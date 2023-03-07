library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1 bit AND gate
entity and_gate is
  Port (a, b: in std_logic;
  res: out std_logic);          
end and_gate;

architecture Behavioral of and_gate is
begin

res <= a and b;

end Behavioral;
