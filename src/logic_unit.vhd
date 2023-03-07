library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 32 bit Logic Unit: Logic AND, OR NOT, Left & Right rotations
entity logic_unit is
    Port (clk: in std_logic;
    x1, x2: in std_logic_vector(31 downto 0);       
    id_op: in std_logic_vector(3 downto 0);    -- operation ID
    left, right: in std_logic;       
    y: out std_logic_vector(31 downto 0);
    flags: out std_logic_vector(6 downto 0));
end logic_unit;

architecture Structural of logic_unit is
-- components region
component logic_and_op is
  Port (x0, x1: in std_logic_vector(31 downto 0);
  y: out std_logic_vector(31 downto 0));
end component;

component logic_or_op is
  Port (x0, x1: in std_logic_vector(31 downto 0);
  y: out std_logic_vector(31 downto 0));
end component;

component logic_not_op is
  Port (x: in std_logic_vector(31 downto 0);
  y: out std_logic_vector(31 downto 0));
end component;

component left_rotation_circuit is
  Port (clk: in std_logic;
  x: in std_logic_vector(31 downto 0);
  left: in std_logic;                   -- control signal that shows that a shift-left operation is being performed
  y: out std_logic_vector(31 downto 0));
end component;

component right_rotation_circuit is
  Port (clk: in std_logic;
  x: in std_logic_vector(31 downto 0);
  right: in std_logic;                   -- control signal that shows that a shift-right operation is being performed
  y: out std_logic_vector(31 downto 0));
end component;

-- 32-bit 5:1 Multiplexer
component mux_5_1 is
  Port (x0, x1, x2, x3, x4: in std_logic_vector(31 downto 0);
  sel: in std_logic_vector(3 downto 0);
  y: out std_logic_vector(31 downto 0));
end component;

-- signals region
signal y_and, y_or, y_not, y_rot_left, y_rot_right: std_logic_vector(31 downto 0) := x"00000000";
signal result_sig: std_logic_vector(31 downto 0) := x"00000000";
signal sign_flag, overflow_flag, parity_flag, zero_flag, div_by_zero_flag, aux_carry_flag, carry_flag: std_logic := '0';

begin
logic_and_circuit: logic_and_op port map (x1, x2, y => y_and);
logic_or_circuit: logic_or_op port map (x1, x2, y_or);
logic_not_circuit: logic_not_op port map (x1, y_not);
left_rot_circuit: left_rotation_circuit port map (clk, x1, left, y_rot_left);
right_rot_circuit: right_rotation_circuit port map (clk, x1, right, y_rot_right);
mux5_1: mux_5_1 port map(y_and, y_or, y_not, y_rot_left, y_rot_right, id_op, result_sig);
    
-- flags computation    
sign_flag <= result_sig(31);
overflow_flag <= '0';
parity_flag <= result_sig(0);
    
zero_flag_proc: process(result_sig) 
begin
case result_sig is
    when x"00000000" =>
        zero_flag <= '1';
    when others =>
        zero_flag <= '0';
end case;
end process;
    
div_by_zero_flag <= '0';
aux_carry_flag <= '0';
carry_flag <= '0';
   
-- output computation    
y <= result_sig;
flags <= sign_flag & overflow_flag & parity_flag & zero_flag & div_by_zero_flag & aux_carry_flag & carry_flag;
    
end Structural;
