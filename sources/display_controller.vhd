-- display_controller : shows MuxOut as two hex digits, AN1 = upper 4 bits,
-- AN0 = lower 4 bits. seg and an are active-low.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_controller is
    port (
        i_clk   : in  std_logic;
        i_reset : in  std_logic;
        i_value : in  std_logic_vector(7 downto 0);
        o_seg   : out std_logic_vector(6 downto 0);
        o_an    : out std_logic_vector(7 downto 0)
    );
end display_controller;

architecture behavioral of display_controller is
    signal refresh : unsigned(15 downto 0) := (others => '0');
    signal nibble  : std_logic_vector(3 downto 0);
begin
    process (i_clk, i_reset)
    begin
        if i_reset = '1' then
            refresh <= (others => '0');
        elsif rising_edge(i_clk) then
            refresh <= refresh + 1;
        end if;
    end process;

    nibble <= i_value(7 downto 4) when refresh(15) = '1' else i_value(3 downto 0);
    o_an   <= "11111101"          when refresh(15) = '1' else "11111110";

    with nibble select  -- seg = abcdefg, 0 = on
        o_seg <= "0000001" when "0000",                -- 0
                 "1001111" when "0001",                -- 1
                 "0010010" when "0010",                -- 2
                 "0000110" when "0011",                -- 3
                 "1001100" when "0100",                -- 4
                 "0100100" when "0101",                -- 5
                 "0100000" when "0110",                -- 6
                 "0001111" when "0111",                -- 7
                 "0000000" when "1000",                -- 8
                 "0000100" when "1001",                -- 9
                 "0001000" when "1010",                -- A
                 "1100000" when "1011",                -- b
                 "0110001" when "1100",                -- C
                 "1000010" when "1101",                -- d
                 "0110000" when "1110",                -- E
                 "0111000" when others;                -- F
end behavioral;
