library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ALU Control Unit
entity control_unit is
    Port (idop: in std_logic_vector(3 downto 0);
          clk: in std_logic;
          start: in std_logic;
          clr: in std_logic;
          clr_div: in std_logic;
          clr_mul: in std_logic;
          i0: in std_logic; -- for multiplication (multiplie(0))
          dn: in std_logic; -- for division (divident(31))
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
end control_unit;

architecture Behavioral of control_unit is

type state_type is (
    start_state,
    load_op_add,
    add_ex,
    load_op_sub,
    sub_ex,
    load_op_inc,
    inc_ex,
    load_op_dec,
    dec_ex,
    load_op_neg,
    neg_ex,
    load_op_and,
    and_ex,
    load_op_or,
    or_ex,
    load_op_not,
    not_ex,
    load_op_rot_left,
    init_rot_left,
    rot_left_ex,
    load_op_rot_right,
    init_rot_right,
    rot_right_ex,
    load_res_alu,
    load_op_mul,
    init_mul,
    test_i01,
    add_mul,
    left_shift_d_mult,
    right_shift_m_mult,
    test_n10,
    load_res_mul,
    load_op_div,
    test_div0,
    init_div,
    sub_div_state,
    test_d_neg,
    left_shift_c1,
    add_div_state,
    left_shift_q0,
    right_shift_d2_division,
    test_n20,
    load_res_div,
    stop_state
);


signal state : state_type := start_state;
signal n1 : integer range 0 to 32 := 0;
signal n2 : integer range 0 to 33 := 0;
signal stop_aux : std_logic := '0';

begin

    next_state: process (clk)
    variable wait_time : integer := 10;
    begin
        if rising_edge(clk) then
            if clr = '1' then
                state <= start_state;
            else 
                case state is
                    when start_state =>
                        if start = '1' then
                            case idop is
                                when "0000" => state <= load_op_add; res_sel <= "00"; 
                                when "0001" => state <= load_op_sub; res_sel <= "00";
                                when "0010" => state <= load_op_inc; res_sel <= "00"; 
                                when "0011" => state <= load_op_dec; res_sel <= "00"; 
                                when "0100" => state <= load_op_neg; res_sel <= "00"; 
                                when "0101" => state <= load_op_and; res_sel <= "01"; 
                                when "0110" => state <= load_op_or; res_sel <= "01"; 
                                when "0111" => state <= load_op_not; res_sel <= "01";
                                when "1000" => state <= load_op_rot_left; res_sel <= "01";
                                when "1001" => state <= load_op_rot_right; res_sel <= "01"; 
                                when "1010" => state <= load_op_mul; res_sel <= "10";
                                when "1011" => state <= load_op_div; res_sel <= "11"; 
                                when others => state <= start_state;
                            end case;
                        else
                            state <= start_state;
                        end if;
                    when load_op_add => state <= add_ex;
                    when add_ex => state <= stop_state; 
                    when load_res_alu =>
                        state <= stop_state;
                    when load_op_sub => state <= sub_ex;
                    when sub_ex => state <= stop_state; 
                    when load_op_inc => state <= inc_ex;
                    when inc_ex => state <= stop_state; 
                    when load_op_dec => state <= dec_ex;
                    when dec_ex => state <= stop_state; 
                    when load_op_neg => state <= neg_ex;
                    when neg_ex => state <= stop_state; 
                    when load_op_and => state <= and_ex;
                    when and_ex => state <= stop_state; 
                    when load_op_or => state <= or_ex;
                    when or_ex => state <= stop_state; 
                    when load_op_not => state <= not_ex;
                    when not_ex => state <= stop_state; 
                    when load_op_rot_left => state <= init_rot_left;
                    when init_rot_left => state <= rot_left_ex;
                    when rot_left_ex => state <= load_res_alu;
                    when load_op_rot_right => state <= init_rot_right;
                    when init_rot_right => state <= rot_right_ex;
                    when rot_right_ex => state <= load_res_alu;
                    when load_op_mul => state <= init_mul;
                    when init_mul =>
                        n1 <= 32;
                        state <= test_i01;
                    when test_i01 =>
                        if i0 = '1' then
                            state <= add_mul;
                        else
                            state <= left_shift_d_mult;
                        end if;
                    when add_mul => state <= left_shift_d_mult;
                    when left_shift_d_mult => state <= right_shift_m_mult;
                    when right_shift_m_mult => 
                        n1 <= n1 - 1;
                        state <= test_n10;
                    when test_n10 =>
                        if n1 = 0 then
                            state <= load_res_mul;
                        else 
                            state <= test_i01;
                        end if;
                    when load_res_mul =>
                        state <= stop_state;
                        --stop <= '1';
                    when load_op_div => state <= test_div0;
                    when test_div0 =>
                        if zero = '1' then
                            state <= load_res_div;
                        else
                            state <= init_div;
                        end if;
                    when init_div =>
                        n2 <= 33;
                        state <= sub_div_state;
                    when sub_div_state => 
                        state <= test_d_neg;
                    when test_d_neg =>
                        if dn = '1' then
                            state <= add_div_state;
                        else
                            state <= left_shift_c1;
                        end if;
                    when add_div_state => state <= left_shift_q0;
                    when left_shift_c1 => state <= right_shift_d2_division;
                    when left_shift_q0 => state <= right_shift_d2_division;
                    when right_shift_d2_division =>
                        n2 <= n2 - 1;
                        state <= test_n20;
                    when test_n20 =>
                        if n2 = 0 then
                            state <= load_res_div;
                        else
                            state <= sub_div_state;
                        end if;
                    when load_res_div => 
                        state <= stop_state;
                    when stop_state => state <= start_state; stop_aux <= '1';
                    when others => null;
                end case;
            end if;
        end if;
    end process;
    
    stop <= stop_aux;
    
    control_signals: process(state)
    begin
        -- control signals 
        sub <= '0';
        neg <= '0';
        left <= '0';
        right <= '0';
        load_acc <= '0';
        load_res_or_op <= '0';
        load_rop2 <= '0';
        load_op2_or_1 <= '0';
        load_flags <= '0';
           
        -- multiplier control signals    
        clr_res_mul <= '0';
        ld_res_mul <= '0';
        ld_m_mul <= '0';
        ld_d_mul <= '0';
        right_shift_m_mul <= '0';
        left_shift_d_mul <= '0';
               
        -- divider control signals
        clr_c_div <= '0';
        ld_d_div <= '0';
        sub_div <= '0';
        ld_d2_div <= '0';
        q0 <= '0';
        right_shift_d2_div <= '0';
        left_shift_c_div <= '0';
        
        case state is
            when load_op_add =>
                load_acc <= '1';
                load_rop2 <= '1';
            when add_ex =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_res_alu =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_sub =>
                load_acc <= '1';
                load_rop2 <= '1';
            when sub_ex =>
                sub <= '1';
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_inc =>
                load_acc <= '1';
                load_rop2 <= '1';
                load_op2_or_1 <= '1';
            when inc_ex =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_dec =>
                load_acc <= '1';
                load_rop2 <= '1';
                load_op2_or_1 <= '1';
            when dec_ex =>
                sub <= '1';
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_neg =>
                load_acc <= '1';
                load_rop2 <= '1';
                load_op2_or_1 <= '1';
            when neg_ex =>
                neg <= '1';
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_and =>
                load_acc <= '1';
                load_rop2 <= '1';
            when and_ex =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when or_ex =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when not_ex =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_or =>
                load_acc <= '1';
                load_rop2 <= '1';
            when load_op_not =>
                load_acc <= '1';
            when load_op_rot_left =>
                load_acc <= '1';
            when rot_left_ex =>
                left <= '1';
            when load_op_rot_right =>
                load_acc <= '1';
            when rot_right_ex =>
                right <= '1';
            when load_op_mul =>
                load_acc <= '1';
                load_rop2 <= '1';
            when init_mul =>
                clr_res_mul <= '1';
                ld_d_mul <= '1';
                ld_m_mul <= '1';
            when add_mul =>
                ld_res_mul <= '1';
            when left_shift_d_mult =>
                left_shift_d_mul <= '1';
            when right_shift_m_mult =>
                right_shift_m_mul <= '1';
            when load_res_mul =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when load_op_div =>
                load_acc <= '1';
                load_rop2 <= '1';
            when init_div =>
                clr_c_div <= '1';
                ld_d_div <= '1';
                ld_d2_div <= '1';
            when sub_div_state =>
                sub_div <= '1';
                ld_d_div <= '1';
            when add_div_state =>
                sub_div <= '0';
                ld_d_div <= '1';
            when left_shift_q0 =>
                q0 <= '0';
                left_shift_c_div <= '1';
            when left_shift_c1 =>
                q0 <= '1';
                left_shift_c_div <= '1';
            when right_shift_d2_division =>
                right_shift_d2_div <= '1';
            when load_res_div =>
                load_acc <= '1';
                load_res_or_op <= '1';
                load_flags <= '1';
            when others => null;
        end case;    
    end process control_signals;
  
end Behavioral;
