-- Testbench for mux4to1_8bit: walks through all 4 select values.
library ieee;
use ieee.std_logic_1164.all;

entity tb_mux4to1_8bit is
end tb_mux4to1_8bit;

architecture sim of tb_mux4to1_8bit is
    signal d0, d1, d2, d3, y : std_logic_vector(7 downto 0);
    signal s1, s0 : std_logic;
begin
    uut : entity work.mux4to1_8bit
        port map (i_d0 => d0, i_d1 => d1, i_d2 => d2, i_d3 => d3, i_sel1 => s1, i_sel0 => s0, o_y => y);

    process
    begin
        d0 <= "00000000"; d1 <= "00000001"; d2 <= "10000000"; d3 <= "10000001";
        s1 <= '0'; s0 <= '0'; wait for 20 ns;  -- y = 00000000
        s1 <= '0'; s0 <= '1'; wait for 20 ns;  -- y = 00000001
        s1 <= '1'; s0 <= '0'; wait for 20 ns;  -- y = 10000000
        s1 <= '1'; s0 <= '1'; wait for 20 ns;  -- y = 10000001
        wait;
    end process;
end sim;
