library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zero_extend_circuit is
    Port (data_in: in std_logic_vector(31 downto 0);
          extended_data: out std_logic_vector(63 downto 0));
end zero_extend_circuit;

architecture Behavioral of zero_extend_circuit is
begin

extended_data <= x"00000000" & data_in;

end Behavioral;
