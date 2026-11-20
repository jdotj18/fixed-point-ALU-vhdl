-- Testbench for regN (N = 4): reset clears, load stores, load = 0 holds.
library ieee;
use ieee.std_logic_1164.all;

entity tb_regN is
end tb_regN;

architecture sim of tb_regN is
    signal clk : std_logic := '0';
    signal rst, ld : std_logic := '0';
    signal d, q : std_logic_vector(3 downto 0) := "0000";
begin
    clk <= not clk after 5 ns;

    uut : entity work.regN generic map (N => 4)
        port map (i_clock => clk, i_reset => rst, i_load => ld, i_d => d, o_q => q);

    process
    begin
        rst <= '1'; ld <= '1'; d <= "1010"; wait for 20 ns;  -- q = 0000 (reset)
        assert q = "0000" report "reset failed" severity error;
        rst <= '0'; wait for 20 ns;                          -- q = 1010 (load)
        assert q = "1010" report "load failed" severity error;
        ld <= '0'; d <= "0101"; wait for 20 ns;              -- q = 1010 (hold)
        assert q = "1010" report "hold failed" severity error;
        ld <= '1'; wait for 20 ns;                           -- q = 0101 (load)
        assert q = "0101" report "second load failed" severity error;
        rst <= '1'; wait for 20 ns;                          -- q = 0000 (reset)
        assert q = "0000" report "second reset failed" severity error;
        wait;
    end process;
end sim;
