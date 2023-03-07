library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_top is
    Port ( next_instr_en: in std_logic;
           clk: in std_logic;
           clr: in std_logic;
           reset: in std_logic;
           start: in std_logic;
           stop: out std_logic;
           result_high: out std_logic_vector(31 downto 0);
           result_low: out std_logic_vector(31 downto 0);
           flags: out std_logic_vector(6 downto 0));
end alu_top;

architecture Structural of alu_top is

component program_counter is
  Port (clk, en, clear: in std_logic;
  addr: out std_logic_vector(31 downto 0));
end component;

component instruction_memory is
    Port ( address: in std_logic_vector(31 downto 0); -- the current address(the index of the current instruction)
           data_out: out std_logic_vector(67 downto 0));  -- current instruction, defined on 68 bits
end component;

component alu_top_level is
  Port (x1, x2: in std_logic_vector(31 downto 0);
        idop: in std_logic_vector(3 downto 0);
        start: in std_logic;
        clk: in std_logic;
        clr: in std_logic;
        stop: out std_logic;
        flags_word: out std_logic_vector(6 downto 0);
        y: out std_logic_vector(63 downto 0));
end component;

signal addr, x1, x2 : std_logic_vector(31 downto 0) := (others => '0');
signal idop : std_logic_vector(3 downto 0) := (others => '0');
signal instruction : std_logic_vector(67 downto 0) := (others => '0');
signal result : std_logic_vector(63 downto 0) := (others => '0');

begin
    
    counter_uut: program_counter port map (clk => clk, en => next_instr_en, clear => reset, addr => addr);

    instruction_memory_uut: instruction_memory port map (address => addr, data_out => instruction);
    
    x1 <= instruction (67 downto 36);
    x2 <= instruction (35 downto 4);
    idop <= instruction (3 downto 0);
    
    alu_uut: alu_top_level port map (x1 => x1, x2 => x2, idop => idop, start => start, clk => clk, clr => clr, stop => stop, flags_word => flags, y => result);
    
    result_high <= result (63 downto 32);
    result_low <= result (31 downto 0);

end Structural;
