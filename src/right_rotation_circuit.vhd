library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity right_rotation_circuit is
  Port (clk: in std_logic;
  x: in std_logic_vector(31 downto 0);
  right: in std_logic;                   -- control signal that shows that a shift-right operation is being performed
  y: out std_logic_vector(31 downto 0));
end right_rotation_circuit;

architecture Structural of right_rotation_circuit is
-- components region
component D_flip_flop is
  Port (clk, D: in std_logic;
  Q: out std_logic);
end component;

-- 2:1 Multiplexer
component mux_2_1 is
  Port (x0, x1, sel: in std_logic;
  y: out std_logic);
end component;

-- signals region
signal mux_sig, q_sig: std_logic_vector(31 downto 0) := x"00000000";
begin

full_circuit: for i in 0 to 31 generate
block0: if i = 31 generate
mux1: mux_2_1 port map(x(i), q_sig(0), right, mux_sig(i));
d_ff_1: D_flip_flop port map(clk, mux_sig(i), q_sig(i));
end generate block0;

other_blocks: if i < 31 generate
mux2: mux_2_1 port map(x(i), q_sig(i + 1), right, mux_sig(i));
d_ff_2: D_flip_flop port map(clk, mux_sig(i), q_sig(i));
end generate other_blocks;
end generate full_circuit;


y <= q_sig;

end Structural;
