-- Testbench for mux2to1_8bit.
library ieee;
use ieee.std_logic_1164.all;

entity tb_mux2to1_8bit is
end tb_mux2to1_8bit;

architecture sim of tb_mux2to1_8bit is
    signal a, b, y : std_logic_vector(7 downto 0);
    signal sel : std_logic;
begin
    uut : entity work.mux2to1_8bit port map (i_a => a, i_b => b, i_sel => sel, o_y => y);

    process
    begin
        a <= "00000001"; b <= "11110000";
        sel <= '0'; wait for 20 ns;   -- y = 00000001
        sel <= '1'; wait for 20 ns;   -- y = 11110000
        wait;
    end process;
end sim;
