library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_4_1_n_bits is
    Generic (n : integer := 32);
    Port (x1, x2, x3, x4 : in std_logic_vector(n - 1 downto 0);
          sel: in std_logic_vector(1 downto 0);
          y: out std_logic_vector(n - 1 downto 0));
end mux_4_1_n_bits;

architecture Behavioral of mux_4_1_n_bits is
begin
    y <= x1 when sel = "00" else
         x2 when sel = "01" else
         x3 when sel = "10" else
         x4 when sel = "11" else
         (others => '0');
end Behavioral;
