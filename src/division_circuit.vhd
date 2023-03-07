library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity division_circuit is
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
end division_circuit;

architecture Structural of division_circuit is
-- components region
-- Adder on 64 bits
component adder_64bits is
    Port (x1, x2: in std_logic_vector(63 downto 0);
          sub: in std_logic;
          cout: out std_logic;
          y: out std_logic_vector(63 downto 0));
end component;

component register_n_bits is
    Generic (N : integer := 32);
    Port (data_in : in std_logic_vector(n - 1 downto 0);       -- parallel input
          left : in std_logic;                                  -- shift left enable
          right : in std_logic;                                 -- shift right enable
          load : in std_logic;                                  -- load enable
          clr : in std_logic;                                   -- reset
          serial_in : in std_logic;                             -- serial input
          clk : in std_logic;
          data_out : out std_logic_vector(n - 1 downto 0));    
end component;

-- 2 to 1 Multiplexer on n bits
component mux_2_1_n_bits is
    Generic (n: integer := 32);
    Port (x1: in std_logic_vector(n - 1 downto 0);
          x2: in std_logic_vector(n - 1 downto 0);
          sel: in std_logic;       
          y: out std_logic_vector(n - 1 downto 0));
end component;

-- signals region
signal dividend : std_logic_vector(63 downto 0) := (others => '0');
signal sum_out : std_logic_vector(63 downto 0) := (others => '0');
signal divisor : std_logic_vector(63 downto 0) := (others => '0');
signal mux_out : std_logic_vector(63 downto 0) := (others => '0');
signal ext_x1, ext_x2 : std_logic_vector(63 downto 0) := (others => '0');
signal q, r : std_logic_vector(31 downto 0) := (others => '0');
signal cout : std_logic := '0';
signal carry_flag, aux_carry_flag, overflow_flag, zero_flag, parity_flag, sign_flag, div_by_zero_flag : std_logic := '0';

begin

    ext_x1 <= x"00000000" & x1;
    ext_x2 <= x2 & x"00000000";
    
    mux: mux_2_1_n_bits generic map (n => 64) port map (x1 => sum_out, x2 => ext_x1, sel => ld_d2_div, y => mux_out);

    d2_register: register_n_bits generic map (N => 64) port map (data_in => ext_x2, left => '0', right => right_shift_d2_div,
    load => ld_d2_div, clr => clr, serial_in => '0', clk => clk, data_out => divisor);

    d_register: register_n_bits generic map (N => 64) port map (data_in => mux_out, left => '0', right => '0', load => ld_d_div, 
    clr => clr, serial_in => '0', clk => clk, data_out => dividend);
    
    q_register: register_n_bits generic map (N => 32) port map (data_in => x"00000000", left => left_shift_q_div, right => '0', 
    load => '0', clr => clr_c_div, serial_in => q0, clk => clk, data_out => q);
    
    adder: adder_64bits port map (x1 => dividend, x2 => divisor, sub => sub_div, cout => cout, y => sum_out);
    
    dn <= dividend(63);
    r <= dividend(31 downto 0);
    y <= q & r;
    
    carry_flag <= '0';
    aux_carry_flag <= '0';
    parity_flag <= q(0);
    sign_flag <= q(31);
    overflow_flag <= '0';
    
    divide_by_zero_proc: process (x2)
    begin
        if x2 = x"00000000" then
            div_by_zero_flag <= '1';
        else
            div_by_zero_flag <= '0';
        end if;
    end process divide_by_zero_proc;
            
    zero_flag_proc: process (q)
    begin
        if q = x"00000000" then
            zero_flag <= '1';
        else
            zero_flag <= '0';
        end if;
    end process zero_flag_proc;
      
    flags <= sign_flag & overflow_flag & parity_flag & zero_flag & div_by_zero_flag & aux_carry_flag & carry_flag;

end Structural;
