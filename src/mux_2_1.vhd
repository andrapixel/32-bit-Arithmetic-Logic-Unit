library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 2:1 Multiplexer
entity mux_2_1 is
  Port (x0, x1, sel: in std_logic;
  y: out std_logic);
end mux_2_1;

architecture Behavioral of mux_2_1 is
begin

mux: process (sel, x0, x1)
begin

case sel is
    when '0' =>
        y <= x0;
    when others =>
        y <= x1;
end case;

end process;

end Behavioral;
