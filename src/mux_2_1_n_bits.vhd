library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_1_n_bits is
    Generic (n: integer := 32);
    Port (x1: in std_logic_vector(n - 1 downto 0);
          x2: in std_logic_vector(n - 1 downto 0);
          sel: in std_logic;       
          y: out std_logic_vector(n - 1 downto 0));
end mux_2_1_n_bits;

architecture Behavioral of mux_2_1_n_bits is
begin

y <= x1 when sel = '0' else x2;

end Behavioral;
