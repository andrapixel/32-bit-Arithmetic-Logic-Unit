library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1 bit XOR gate
entity xor_gate is
  Port (a, b: in std_logic;
  res: out std_logic);          
end xor_gate;

architecture Behavioral of xor_gate is
begin

res <= a xor b;

end Behavioral;
