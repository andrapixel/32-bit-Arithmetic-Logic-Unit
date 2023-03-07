library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 32-bit 5:1 Multiplexer
entity mux_5_1 is
  Port (x0, x1, x2, x3, x4: in std_logic_vector(31 downto 0);
  sel: in std_logic_vector(3 downto 0);
  y: out std_logic_vector(31 downto 0));
end mux_5_1;

architecture Behavioral of mux_5_1 is
begin

mux_proc: process(sel)
begin

case sel is
    when "0101" =>
        y <= x0;
    when "0110" =>
        y <= x1;
    when "0111" =>
        y <= x2;
    when "1000" =>
        y <= x3;
    when "1001" =>
        y <= x4;
    when others =>
        y <= x"00000000";
end case;

end process;

end Behavioral;
