-- Testbench for mux2N (N = 4).
library ieee;
use ieee.std_logic_1164.all;

entity tb_mux2N is
end tb_mux2N;

architecture sim of tb_mux2N is
    signal a, b, y : std_logic_vector(3 downto 0);
    signal sel : std_logic;
begin
    uut : entity work.mux2N generic map (N => 4) port map (i_a => a, i_b => b, i_sel => sel, o_y => y);

    process
    begin
        a <= "0011"; b <= "1100";
        sel <= '0'; wait for 20 ns;   -- y = 0011
        assert y = "0011" report "sel = 0 failed" severity error;
        sel <= '1'; wait for 20 ns;   -- y = 1100
        assert y = "1100" report "sel = 1 failed" severity error;
        wait;
    end process;
end sim;
