library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity logic_or_op is
  Port (x0, x1: in std_logic_vector(31 downto 0);
  y: out std_logic_vector(31 downto 0));
end logic_or_op;

architecture Structural of logic_or_op is
-- components region
-- 1 bit OR gate
component or_gate is
  Port (a, b: in std_logic;
  res: out std_logic);          
end component;

begin

full_design: for i in 0 to 31 generate
or1: or_gate port map(x0(i), x1(i), y(i));
end generate full_design;

end Structural;
