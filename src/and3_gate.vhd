library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1 bit AND gate with 3 operands
entity and3_gate is
  Port (a, b, c: in std_logic;
  res: out std_logic);
end and3_gate;

architecture Structural of and3_gate is
-- components region
-- 1 bit AND gate with 2 operands
component and_gate is
  Port (a, b: in std_logic;
  res: out std_logic);          
end component;

-- signals region
signal temp1: std_logic := '0';

begin

-- Compute res = a and b and c
and1: and_gate port map(a, b, temp1);
and2: and_gate port map(temp1, c, res);

end Structural;
