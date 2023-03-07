library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execution_unit is
    Port (x1, x2: in std_logic_vector(31 downto 0);
          clk: in std_logic;
          clr: in std_logic;
          res_sel: in std_logic_vector(1 downto 0);
          idop: in std_logic_vector(3 downto 0);    -- operation id
          sub: in std_logic;
          neg: in std_logic;
          left: in std_logic;
          right: in std_logic;
          -- control signals for the fsm_ctrl multiplier
          clr_res_mul: in std_logic;
          ld_res_mul: in std_logic;
          ld_m_mul: in std_logic;
          ld_d_mul: in std_logic;
          right_shift_m_mul: in std_logic;
          left_shift_d_mul: in std_logic;
          -- control signals for the fsm_ctrl divider
          clr_c_div: in std_logic;
          ld_d_div: in std_logic;
          sub_div: in std_logic;
          ld_d2_div: in std_logic;
          q0: in std_logic;
          right_shift_d2_div: in std_logic;
          left_shift_c_div: in std_logic;
          dn: out std_logic;
          i0: out std_logic;
          flags: out std_logic_vector(6 downto 0);
          y: out std_logic_vector(63 downto 0));  -- result on 64 bits, represented in 2's complement
end execution_unit;

architecture Structural of execution_unit is
-- components region
-- 32 bit Arithmetic Unit: ADD, SUB, INC, DEC, NEG operations
component arithmetic_unit is
  Port (x1, x2: in std_logic_vector(31 downto 0);   -- two 32-bit operands
  sel_sub, sel_neg: in std_logic;                   -- selectors for the Subtraction and Negation operations
  y: out std_logic_vector(31 downto 0);             -- the 32-bit result
  flags: out std_logic_vector(6 downto 0));         -- we have 7 possible flags in our Flag Register
end component;

-- 32 bit Logic Unit: Logic AND, OR NOT, Left & Right rotations
component logic_unit is
    Port (clk: in std_logic;
    x1, x2: in std_logic_vector(31 downto 0);       
    id_op: in std_logic_vector(3 downto 0);    -- operation ID
    left, right: in std_logic;       
    y: out std_logic_vector(31 downto 0);
    flags: out std_logic_vector(6 downto 0));
end component;

-- Multiplication circuit
component multiplication_circuit is
    Port (clk: in std_logic;
          clr: in std_logic;  -- clear signal for resetting the operand registers
          x1, x2: in std_logic_vector(31 downto 0);
          clr_res_mul: in std_logic;  -- reset for the mult. result register
          ld_res_mul: in std_logic;   -- parallel load for the result register
          ld_m_mul: in std_logic;     -- parallel load for the multiplier register
          ld_d_mul: in std_logic;     -- parallel load for the multiplicand register
          right_shift_m_mul: in std_logic;    -- right shift signal for shifting the value of the multiplier reg.
          left_shift_d_mul: in std_logic;     -- --||-- of the multiplicand reg.
          y: out std_logic_vector(63 downto 0);
          i0: out std_logic;  -- stores the least significant bit of the current value of the multiplier
          flags: out std_logic_vector(6 downto 0));
end component;

-- Division circuit
component division_circuit is
    Port (clk: in std_logic;
          clr: in std_logic;
          x1, x2: in std_logic_vector(31 downto 0); 
          clr_c_div: in std_logic;    -- reset for the dividend register
          ld_d_div: in std_logic;     -- parallel load of the divident reg.
          sub_div: in std_logic;      -- control signal that indicates the usage of the subtractor
          ld_d2_div: in std_logic;     -- parallel load of the divider reg.
          q0: in std_logic;       -- least significant bit of the quotient
          right_shift_d2_div: in std_logic;    -- right shift circuit for the value of the divider
          left_shift_q_div: in std_logic;     -- --||-- of the quotient
          y: out std_logic_vector(63 downto 0); 
          flags: out std_logic_vector(6 downto 0);
          dn: out std_logic); -- sign bit of the multiplicand
end component;

component mux_4_1_n_bits is
    Generic (n : integer := 32);
    Port (x1, x2, x3, x4 : in std_logic_vector(n - 1 downto 0);
          sel: in std_logic_vector(1 downto 0);
          y: out std_logic_vector(n - 1 downto 0));
end component;

component mux_2_1_n_bits is
    Generic (n: integer := 32);
    Port (x1: in std_logic_vector(n - 1 downto 0);
          x2: in std_logic_vector(n - 1 downto 0);
          sel: in std_logic;       
          y: out std_logic_vector(n - 1 downto 0));
end component;

-- additional circuits
component complement_circuit is
    Generic (n: integer := 32);
    Port (x: in std_logic_vector(n - 1 downto 0);       
          y: out std_logic_vector(n - 1 downto 0));
end component;

-- used for extending the results of the arithmetic/logic units from 32 bits to 64
component sign_extend_circuit is
    Generic (initial_size : integer := 32;
             extended_size : integer := 64);
    Port (data_in: in std_logic_vector(initial_size - 1 downto 0);
          extended_data: out std_logic_vector(extended_size - 1 downto 0));
end component;

component zero_extend_circuit is
    Port (data_in: in std_logic_vector(31 downto 0);
          extended_data: out std_logic_vector(63 downto 0));
end component;

signal au_out32, lu_out32, div_out32, neg_div_out32, final_div_out32, pos_q32, neg_q32, final_q32, pos_r32, neg_r32, final_r32 : std_logic_vector(31 downto 0) := (others => '0');
signal au_out64, lu_out64, div_out64, final_div64, mul_out64, neg_mul_out64, final_mul64 : std_logic_vector(63 downto 0) := (others => '0'); 
signal au_flags, lu_flags, mul_flags, div_flags : std_logic_vector(6 downto 0) := (others => '0');
signal neg_x1, neg_x2, abs_x1, abs_x2 : std_logic_vector(31 downto 0) := (others => '0');
signal product_quotient_sign, remainder_sign : std_logic := '0';

begin
    au : arithmetic_unit port map (x1 => x1, x2 => x2, sel_sub => sub, sel_neg => neg, y => au_out32, flags => au_flags);
    lu : logic_unit port map (x1 => x1, x2 => x2, id_op => idop, left => left, right => right, clk => clk, y => lu_out32, flags => lu_flags);
    mult : multiplication_circuit port map (clk => clk, clr => clr, x1 => abs_x1, x2 => abs_x2, clr_res_mul => clr_res_mul, ld_res_mul => ld_res_mul, ld_m_mul => ld_m_mul, ld_d_mul => ld_d_mul, right_shift_m_mul => right_shift_m_mul, left_shift_d_mul => left_shift_d_mul, y => mul_out64, i0 => i0, flags => mul_flags);
    division : division_circuit port map (clk => clk, clr => clr, x1 => abs_x1, x2 => abs_x2, clr_c_div => clr_c_div, ld_d_div => ld_d_div, sub_div => sub_div, ld_d2_div => ld_d2_div, q0 => q0, right_shift_d2_div => right_shift_d2_div, left_shift_q_div => left_shift_c_div, y => div_out64, flags => div_flags, dn => dn);

    ccx1 : complement_circuit generic map (n => 32) port map (x => x1, y => neg_x1);
    ccx2 : complement_circuit generic map (n => 32) port map (x => x2, y => neg_x2);
    mux_x1 : mux_2_1_n_bits generic map (n => 32) port map (x1 => x1, x2 => neg_x1, sel => x1(31), y => abs_x1);
    mux_x2 : mux_2_1_n_bits generic map (n => 32) port map (x1 => x2, x2 => neg_x2, sel => x2(31), y => abs_x2);
    product_quotient_sign <= x1(31) xor x2(31);
    
    ccprod : complement_circuit generic map (n => 64) port map (x => mul_out64, y => neg_mul_out64);
    mux_prod : mux_2_1_n_bits generic map (n => 64) port map (x1 => mul_out64, x2 => neg_mul_out64, sel => product_quotient_sign, y => final_mul64);

    ext_au : sign_extend_circuit generic map (initial_size => 32, extended_size => 64) port map (data_in => au_out32, extended_data => au_out64);
    ext_lu : zero_extend_circuit port map (data_in => lu_out32, extended_data => lu_out64);
    pos_q32 <= div_out64(63 downto 32);
    
    ccq : complement_circuit generic map (n => 32) port map (x => div_out64(63 downto 32), y => neg_q32);
    mux_quot : mux_2_1_n_bits generic map (n => 32) port map (x1 => pos_q32, x2 => neg_q32, sel => product_quotient_sign, y => final_q32);
    pos_r32 <= div_out64(31 downto 0);
    remainder_sign <= x1(31);
    
    ccr : complement_circuit generic map (n => 32) port map (x => div_out64(31 downto 0), y => neg_r32);
    mux_r : mux_2_1_n_bits generic map (n => 32) port map (x1 => pos_r32, x2 => neg_r32, sel => remainder_sign, y => final_r32);
    final_div64 <= final_q32 & final_r32;
    
    mux_res : mux_4_1_n_bits generic map (n => 64) port map (x1 => au_out64, x2 => lu_out64, x3 => final_mul64, x4 => final_div64, sel => res_sel, y => y);
    mux_flags : mux_4_1_n_bits generic map (n => 7) port map (x1 => au_flags, x2 => lu_flags, x3 => mul_flags, x4 => div_flags, sel => res_sel, y => flags);

end Structural;
