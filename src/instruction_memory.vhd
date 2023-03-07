library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- a 256x8 ROM memory containing hardcoded instructions for testing
entity instruction_memory is
    Port ( address: in std_logic_vector(31 downto 0); -- the current address(the index of the current instruction)
           data_out: out std_logic_vector(67 downto 0));  -- current instruction, defined on 68 bits
end instruction_memory;

architecture Behavioral of instruction_memory is

type rom_array is array (0 to 255) of std_logic_vector(67 downto 0);

signal rom: rom_array := (
    x"0000000A_00000010_0",             -- add (10, 16) = 26 = 0000001Ah
    x"00000006_0000000A_0",             -- add (6, 10) = 16 = 00000010h 
    x"FFFFFFFA_FFFFFFF0_0",             -- add (-6, -16) = -22 = FFFFFFEAh
    x"7FFFFFFF_6FFFFFFF_0",             -- add (2147483647, 1879048191) = -268435458 = EFFFFFFEh (overflow) 
    x"0000000A_00000010_1",             -- sub (10, 16) = -6 = FFFFFFFAh 
    x"0000000A_00000012_1",             -- sub (10, 18) = -8 = FFFFFFF8h 
    x"80000000_00000002_1",             -- sub (-2147483648, 2) = 2147483646 = 7FFFFFFEh (overflow) 
    x"0000000A_00000000_2",             -- inc (10) = 11 = Bh 
    x"80000002_00000000_2",             -- inc (-2147483646) = -2147483645 = 80000003h 
    x"FFFFFFF8_00000000_3",             -- dec (-8) = -9 = FFFFFFF7h 
    x"80000000_00000000_3",             -- dec (-2147483648) = 2147483647 = 7FFFFFFFh 
    x"0000000A_00000000_4",             -- neg (10) = -10 = FFFFFFF6h 
    x"FFFFFFF6_00000000_4",             -- neg (-10) = 10 = 0000000Ah 
    x"0000000A_00000009_5",             -- and (10, 9) = 8h 
    x"ABC500F1_0A536221_5",             -- and (ABC500F1h, 0A536221h) = 0A410021h 
    x"0000000A_00000009_6",             -- or (10, 9) = 11 = Bh 
    x"ABC500F1_0A536221_6",             -- and (ABC500F1h, 0A536221h) = ABD762F1h 
    x"0000000A_00000000_7",             -- not (10) = -11 = FFFFFFF5h 
    x"FFFFFFF5_00000000_7",             -- not (-11) = 10 = 0000000Ah 
    x"80000000_00000000_8",             -- rot_left (80000000) = 00000001h 
    x"0000000B_00000000_8",             -- rot_left (11) = 22 = 00000016h
    x"00000010_00000000_9",             -- rot_right (16) = 8 = 00000008h
    x"0000000B_00000000_9",             -- rot_right (11) = 80000005h 
    x"0000000A_00000006_A",             -- mul (10, 6) = 60 = 0000003Ch
    x"FFFFFFF6_00000006_A",             -- mul (-10, 6) = -60 = FFFFFFC4h 
    x"0000000A_FFFFFFFA_A",             -- mul (10, -6) = -60 = FFFFFFC4h 
    x"FFFFFFF6_FFFFFFFA_A",             -- mul (-10, -6) = 60 = 0000003Ch 
    x"0000000A_00000000_A",             -- mul (10, 0) = 00000000h 
    x"7FFFFFFF_00000003_A",             -- mul(2147483647, 3) = 7FFFFFFDh (overflow) 
    x"0000000C_00000006_B",             -- div (12, 6) = 00000000200000000h (c = 2, r = 0) 
    x"0000000C_00000005_B",             -- div (12, 5) = 00000000200000002h (c = 2, r = 2)
    x"FFFFFFF4_00000005_B",             -- div (-12, 5) = FFFFFFFEFFFFFFFEh (c = -2, r = -2)
    x"0000000C_FFFFFFFB_B",             -- div (12, -5) = FFFFFFFE00000002h (c = -2, r = 2)
    x"FFFFFFF4_FFFFFFFB_B",             -- div (-12, -5) = 000000002FFFFFFFEh (c = 2, r = -2)
    x"0000000C_00000000_B",             -- div (12, 0) = 00000000000000000h (division by 0)
    others => x"00000000_00000000_0"    -- no operation
);

begin

data_out <= rom(conv_integer(address));

end Behavioral;
