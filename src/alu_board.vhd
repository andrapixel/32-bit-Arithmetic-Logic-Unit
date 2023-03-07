library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_board is
    Port (clk: in std_logic;
          btn: in std_logic_vector(4 downto 0);
          sw: in std_logic_vector(15 downto 0);
          led: out std_logic_vector(15 downto 0);
          an: out std_logic_vector(3 downto 0);
          cat: out std_logic_vector(6 downto 0));
end alu_board;

architecture Structural of alu_board is
-- components region
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

component mpg is
  Port (clk: in std_logic;
        btn: in std_logic;
        en: out std_logic);
end component;

component ssd is
    Port ( digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           clk : in STD_LOGIC;
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal mpg_en : STD_LOGIC := '0';
signal alu_res_high, alu_res_low : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal flags : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
signal res_to_display : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

begin

    mpg_uut: mpg port map (clk => clk, btn => btn(0), en => mpg_en);
    
    alu_instr: alu_top port map (next_instr_en => mpg_en, clk => clk, clr => btn(1), reset => btn(2), start => btn(3), stop => led(15), result_high => alu_res_high, result_low => alu_res_low , flags => flags);

    led(0) <= flags(0);     -- Carry flag
    led(1) <= flags(1);     -- Auxiliary Carry flag
    led(2) <= flags(2);     -- Divide by Zero flag
    led(3) <= flags(3);     -- Zero flag
    led(4) <= flags(4);     -- Parity flag
    led(5) <= flags(5);     -- Overflow flag
    led(6) <= flags(6);     -- Sign flag
    
    res_to_display <= alu_res_low (15 downto 0) when sw(1 downto 0) = "00" else
                      alu_res_low (31 downto 16) when sw(1 downto 0) = "01" else
                      alu_res_high (15 downto 0) when sw(1 downto 0) = "10" else
                      alu_res_high (31 downto 16);
    
    ssd_uut: ssd port map (digit0 => res_to_display (3 downto 0), digit1 => res_to_display (7 downto 4), digit2 => res_to_display (11 downto 8), digit3 => res_to_display (15 downto 12), clk => clk, cat => cat, an => an);
    
end Structural;
