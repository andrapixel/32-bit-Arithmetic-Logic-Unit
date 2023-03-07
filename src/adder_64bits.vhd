library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder_64bits is
    Port (x1, x2: in std_logic_vector(63 downto 0);
          sub: in std_logic;
          cout: out std_logic;
          y: out std_logic_vector(63 downto 0));
end adder_64bits;

architecture Structural of adder_64bits is
-- components region
-- 1 bit Full Adder
component full_adder_1bit is
  Port(a, b, cin: in std_logic;
  result, cout: out std_logic);
end component;

-- 2:1 Multiplexer
component mux_2_1 is
  Port (x0, x1, sel: in std_logic;
  y: out std_logic);
end component;

-- 1 bit NOT gate
component not_gate is
  Port (a: in std_logic;
  res: out std_logic);
end component;

signal carry: std_logic_vector(63 downto 0) := x"0000000000000000";
signal inv: std_logic_vector(63 downto 0) := x"0000000000000000";
signal mux: std_logic_vector(63 downto 0) := x"0000000000000000";
signal result: std_logic_vector(63 downto 0) := x"0000000000000000";

begin
    
outerloop: for i in 0 to 63 generate
    innerloop1: if i = 0 generate
        sum: full_adder_1bit port map(a => x1(i), b => mux(i), cin => sub, result => result(i), cout => carry(i));
        not2: not_gate port map(a => x2(i), res => inv(i));
        mux_sub: mux_2_1 port map(x0 => x2(i), x1 => inv(i), sel => sub, y => mux(i)); 
    end generate innerloop1;
        
    innerloop2: if i > 0 generate
        sum: full_adder_1bit port map(a => x1(i), b => mux(i), cin => carry(i - 1), result => result(i), cout => carry(i));
        not2: not_gate port map(a => x2(i), res => inv(i));
        mux_sub: mux_2_1 port map(x0 => x2(i), x1 => inv(i), sel => sub, y => mux(i));
    end generate innerloop2;    
end generate outerloop;
    
cout <= carry(63);
y <= result;

end Structural;
