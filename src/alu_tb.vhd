library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench_alu is
end testbench_alu;

architecture Behavioral of testbench_alu is

component alu_top is
    Port ( next_instr_en: in std_logic;
           clk: in std_logic;
           clr: in std_logic;
           reset: in std_logic;
           start: in std_logic;
           stop: out std_logic;
           result_high: out std_logic_vector(31 downto 0);
           result_low: out std_logic_vector(31 downto 0);
           flags: out std_logic_vector(6 downto 0));
end component;

signal clk : std_logic := '0';
signal next_instr_en : std_logic:= '0';
signal clr : std_logic := '0';
signal reset : std_logic := '0';

signal start : std_logic := '0';
signal stop : std_logic := '0';
signal result_high : std_logic_vector(31 downto 0) := (others => '0');
signal result_low : std_logic_vector(31 downto 0) := (others => '0');
signal flags : std_logic_vector(6 downto 0) := (others => '0');

begin
    uut: alu_top
            port map (
                next_instr_en => next_instr_en,
                clk => clk,
                clr => clr, 
                reset => reset,
                start => start,
                stop => stop,
                result_high => result_high,
                result_low => result_low,
                flags => flags
            );


--    clk <= '0';
--    next_instr_en <= '0';
--    clr <= '0';
--    reset <= '0';
--    start <= '0';
--    stop <= '0';
--    result_high <= (others => '0');
--    result_low <= (others => '0');
--    flags <= (others => '0');

    
    stimulus : process
    begin
--        clk <= '0';
--        next_instr_en <= '0';
--        clr <= '0';
--        reset <= '0';
--        start <= '0';
--        stop <= '0';
--        result_high <= (others => '0');
--        result_low <= (others => '0');
--        flags <= (others => '0');
        
        
        clk <= not clk after 10ns;
        clr <= '1', '0' after 50 ns;
        wait until (clr = '0');
        
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 30 us;
        
        for i in 0 to 40 loop
            next_instr_en <= '1';
            wait for 20 ns;
            next_instr_en <= '0';
            start <= '1';
            wait for 20 ns;
            start <= '0';
            wait for 30 us;
        end loop;
        
        wait;
    end process stimulus;

end Behavioral;
