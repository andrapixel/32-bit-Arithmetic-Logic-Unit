library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity logic_not_op is
  Port (x: in std_logic_vector(31 downto 0);
  y: out std_logic_vector(31 downto 0));
end logic_not_op;

architecture Structural of logic_not_op is
-- components region
-- 1 bit NOT gate
component not_gate is
  Port (a: in std_logic;
  res: out std_logic);          
end component;

begin

full_design: for i in 0 to 31 generate
not1: not_gate port map(x(i), y(i));
end generate full_design;

end Structural;
