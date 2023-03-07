library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity alu_top_level is
  Port (x1, x2: in std_logic_vector(31 downto 0);
        idop: in std_logic_vector(3 downto 0);
        start: in std_logic;
        clk: in std_logic;
        clr: in std_logic;
        stop: out std_logic;
        flags_word: out std_logic_vector(6 downto 0);
        y: out std_logic_vector(63 downto 0));
end alu_top_level;

architecture Structural of alu_top_level is
-- components region
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

component control_unit is
    Port (idop: in std_logic_vector(3 downto 0);
          clk: in std_logic;
          start: in std_logic;
          clr: in std_logic;
          clr_div: in std_logic;
          clr_mul: in std_logic;
          i0: in std_logic; -- pentru inmultire (inmultitor(0))
          dn: in std_logic; -- pentru impartite (deimpartit(31))
          zero: in std_logic;
          -- control signals for arithmetic and logical operations
          sub: out std_logic;
          neg: out std_logic;
          left: out std_logic;
          right: out std_logic;
          load_acc: out std_logic;
          load_res_or_op: out std_logic;
          load_rop2: out std_logic;
          load_op2_or_1: out std_logic;
          load_flags: out std_logic;
          stop: out std_logic;
          -- control signals for the fsm_ctrl multiplier
          clr_res_mul: out std_logic;
          ld_res_mul: out std_logic;
          ld_m_mul: out std_logic;
          ld_d_mul: out std_logic;
          right_shift_m_mul: out std_logic;
          left_shift_d_mul: out std_logic;
          -- control signals for the fsm_ctrl divider
          clr_c_div: out std_logic;
          ld_d_div: out std_logic;
          sub_div: out std_logic;
          ld_d2_div: out std_logic;
          q0: out std_logic;
          right_shift_d2_div: out std_logic;
          left_shift_c_div: out std_logic;
          res_sel: out std_logic_vector(1 downto 0));
end component;

component execution_unit is
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
end component;

component mux_2_1_n_bits is
    Generic (n: integer := 32);
    Port (x1: in std_logic_vector(n - 1 downto 0);
          x2: in std_logic_vector(n - 1 downto 0);
          sel: in std_logic;       
          y: out std_logic_vector(n - 1 downto 0));
end component;

component sign_extend_circuit is
    Generic (initial_size : integer := 32;
             extended_size : integer := 64);
    Port (data_in: in std_logic_vector(initial_size - 1 downto 0);
          extended_data: out std_logic_vector(extended_size - 1 downto 0));
end component;

component zero_detector is
    Port (x: in std_logic_vector(31 downto 0);
          zero: out std_logic);
end component;

-- signals region
-- control signals for arithmetic and logic operations
signal sub, neg, left, right, load_acc, load_res_or_op, load_rop2, load_op2_or_1, load_flags : std_logic := '0';

-- control signals for multiplication
signal clr_res_mul, ld_res_mul, ld_i_mul, ld_d_mul, right_shift_i_mul, left_shift_d_mul, i0 : std_logic := '0';

-- control signals for division
signal clr_c_div, ld_d_div, sub_div, ld_i_div, c0, right_shift_i_div, left_shift_c_div, dn, zero : std_logic := '0';

-- control signal for result selection
signal res_sel : std_logic_vector(1 downto 0) := "00";

-- flags
signal flags : std_logic_vector(6 downto 0) := "0000000";

-- result
signal eu_res : std_logic_vector(63 downto 0) := (others => '0');

-- extended first operand
signal ext_x1 : std_logic_vector(63 downto 0) := (others => '0');

-- accumulator register in/out
signal acc_in, acc_out : std_logic_vector(63 downto 0) := (others => '0');

-- register for second operand in/out
signal reg_op2_in, reg_op2_out : std_logic_vector(31 downto 0) := (others => '0');

begin
-- port map region
    cu: control_unit port map
        (
            idop => idop,
            clk => clk,
            start => start,
            clr => clr,
            clr_div => '0',
            clr_mul => '0',
            i0 => i0,
            dn => dn,
            zero => zero,
            sub => sub,
            neg => neg,
            left => left,
            right => right,
            load_acc => load_acc,
            load_res_or_op => load_res_or_op,
            load_rop2 => load_rop2,
            load_op2_or_1 => load_op2_or_1,
            load_flags => load_flags,
            stop => stop,
            clr_res_mul => clr_res_mul,
            ld_res_mul => ld_res_mul,
            ld_m_mul => ld_i_mul,
            ld_d_mul => ld_d_mul, 
            right_shift_m_mul => right_shift_i_mul,
            left_shift_d_mul => left_shift_d_mul,
            clr_c_div => clr_c_div,
            ld_d_div => ld_d_div,
            sub_div => sub_div,
            ld_d2_div => ld_i_div,
            q0 => c0,
            right_shift_d2_div => right_shift_i_div,
            left_shift_c_div => left_shift_c_div,
            res_sel => res_sel
        );
    
    eu: execution_unit port map
        (
            x1 => acc_out (31 downto 0),
            x2 => reg_op2_out,
            clk => clk,
            clr => clr,
            res_sel => res_sel,
            idop => idop,
            sub => sub,
            neg => neg,
            left => left,
            right => right,
            clr_res_mul => clr_res_mul,
            ld_res_mul => ld_res_mul,
            ld_m_mul => ld_i_mul,
            ld_d_mul => ld_d_mul,
            right_shift_m_mul => right_shift_i_mul,
            left_shift_d_mul => left_shift_d_mul,
            clr_c_div => clr_c_div,
            ld_d_div => ld_d_div,
            sub_div => sub_div,
            ld_d2_div => ld_i_div,
            q0 => c0,
            right_shift_d2_div => right_shift_i_div,
            left_shift_c_div => left_shift_c_div,
            dn => dn,
            i0 => i0,
            flags => flags,
            y => eu_res
        );

    ext_unit_x1: sign_extend_circuit generic map (initial_size => 32, extended_size => 64) port map (data_in => x1, extended_data => ext_x1);

    mux_acc: mux_2_1_n_bits generic map (n => 64) port map (x1 => ext_x1, x2 => eu_res, sel => load_res_or_op, y => acc_in);
    
    acc_reg: register_n_bits generic map (N => 64) port map (data_in => acc_in, left => '0', right => '0', load => load_acc, clr => clr, serial_in => '0', clk => clk, data_out => acc_out);
    
    mux_op2: mux_2_1_n_bits generic map (n => 32) port map (x1 => x2, x2 => x"00000001", sel => load_op2_or_1, y => reg_op2_in); 
    
    reg_op2: register_n_bits generic map (N => 32) port map (data_in => reg_op2_in, left => '0', right => '0', load => load_rop2, clr => clr, serial_in => '0', clk => clk, data_out => reg_op2_out);
    
    status_register: register_n_bits generic map (N => 7) port map (data_in => flags, left => '0', right => '0', load => load_flags, clr => clr, serial_in => '0', clk => clk, data_out => flags_word);

    zero_det: zero_detector port map (x => reg_op2_out, zero => zero);

    y <= acc_out;

end Structural;
