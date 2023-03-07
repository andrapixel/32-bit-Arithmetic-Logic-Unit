library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extend_circuit is
    Generic (initial_size : integer := 32;
             extended_size : integer := 64);
    Port (data_in: in std_logic_vector(initial_size - 1 downto 0);
          extended_data: out std_logic_vector(extended_size - 1 downto 0));
end sign_extend_circuit;

architecture Behavioral of sign_extend_circuit is
begin

extended_data <= std_logic_vector(resize(signed(data_in), extended_data'length));

end Behavioral;
