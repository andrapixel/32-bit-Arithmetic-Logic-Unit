library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- 32 bit Arithmetic Unit: ADD, SUB, INC, DEC, NEG operations
entity arithmetic_unit is
  Port (x1, x2: in std_logic_vector(31 downto 0);   -- two 32-bit operands
  sel_sub, sel_neg: in std_logic;                   -- selectors for the Subtraction and Negation operations
  y: out std_logic_vector(31 downto 0);             -- the 32-bit result
  flags: out std_logic_vector(6 downto 0));         -- we have 7 possible flags in our Flag Register
end arithmetic_unit;

architecture Structural of arithmetic_unit is
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

-- 1 bit OR gate
component or_gate is
  Port (a, b: in std_logic;
  res: out std_logic);          
end component;

-- 1 bit NOT gate
component not_gate is
  Port (a: in std_logic;
  res: out std_logic);
end component;

-- signals region
signal mux_x1, mux_x2: std_logic_vector(31 downto 0) := x"00000000";
signal inv_x1, inv_x2: std_logic_vector(31 downto 0) := x"00000000";  -- the inverted values of the two operands
signal result_sig: std_logic_vector(31 downto 0) := x"00000000";
signal carry_sig: std_logic_vector(31 downto 0) := x"00000000";
-- flag signals
signal sign_flag, overflow_flag, parity_flag, zero_flag, div_by_zero_flag, aux_carry_flag, carry_flag, borrow_flag: std_logic := '0';
signal ovf, ovf_add, ovf_sub: std_logic := '0';

begin

full_arithmetic_unit: for i in 0 to 31 generate

-- implementation of the first block of the Arithmetic Unit
block0: if i = 0 generate
not1: not_gate port map(x1(i), inv_x1(i));    
not2: not_gate port map(x2(i), inv_x2(i));    
    
mux_sub: mux_2_1 port map(
    x0 => x2(i),
    x1 => inv_x2(i),
    sel => sel_sub,
    y => mux_x2(i));
    
mux_neg: mux_2_1 port map(
    x0 => x1(i),
    x1 => inv_x1(i),
    sel => sel_neg,
    y => mux_x1(i));

adder: full_adder_1bit port map(
    a => mux_x1(i),
    b => mux_x2(i),
    cin => sel_sub,
    result => result_sig(i),
    cout => carry_sig(i));
end generate block0;

-- implementation of the rest of the component blocks of the unit
other_blocks: if i > 0 generate
not1: not_gate port map(x1(i), inv_x1(i));    
not2: not_gate port map(x2(i), inv_x2(i));    
    
mux_sub: mux_2_1 port map(
    x0 => x2(i),
    x1 => inv_x2(i),
    sel => sel_sub,
    y => mux_x2(i));
    
mux_neg: mux_2_1 port map(
    x0 => x1(i),
    x1 => inv_x1(i),
    sel => sel_neg,
    y => mux_x1(i));

adder: full_adder_1bit port map(
    a => mux_x1(i),
    b => mux_x2(i),
    cin => carry_sig(i - 1),
    result => result_sig(i),
    cout => carry_sig(i));
end generate other_blocks; 

end generate full_arithmetic_unit;


-- generating the flags
sign_flag <= result_sig(31);

ovf_add <= (x1(31) and x2(31) and (not result_sig(31))) or ((not x1(31)) and (not x2(31)) and result_sig(31));
ovf_sub <= (x1(31) and (not x2(31)) and (not result_sig(31))) or ((not x1(31)) and x2(31) and result_sig(31));
ovf <= ovf_add when sel_sub = '0' else ovf_sub;
overflow_flag <= '0' when sel_neg = '1' else ovf;

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

div_by_zero_flag <= '0';    -- because we don't perform division in this unit
aux_carry_flag <= carry_sig(3);

-- if during the SUB op, the 2nd operand > 1st operand, we need to borrow 1, 
-- thus activating the borrow flag
borrow_flag_proc: process(x1, x2) 
begin
if signed(x1) < signed(x2) then
    borrow_flag <= '1';
else
    borrow_flag <= '0';
end if;
end process;

carry_flag <= carry_sig(31) when sel_sub = '0' else borrow_flag;


-- Computing Outputs
y <= result_sig;
flags <= sign_flag & overflow_flag & parity_flag & zero_flag & div_by_zero_flag & aux_carry_flag & carry_flag;

end Structural;
