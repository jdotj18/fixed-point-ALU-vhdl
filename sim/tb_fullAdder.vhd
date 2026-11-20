-- Testbench for fullAdder: all 8 input combinations (Table 2).
library ieee;
use ieee.std_logic_1164.all;

entity tb_fullAdder is
end tb_fullAdder;

architecture sim of tb_fullAdder is
    signal a, b, cin, s, cout : std_logic;
begin
    uut : entity work.fullAdder port map (i_a => a, i_b => b, i_cin => cin, o_s => s, o_cout => cout);

    process
    begin
        a <= '0'; b <= '0'; cin <= '0'; wait for 10 ns;  -- s = 0, cout = 0
        assert s = '0' and cout = '0' report "000 failed" severity error;
        a <= '0'; b <= '0'; cin <= '1'; wait for 10 ns;  -- s = 1, cout = 0
        assert s = '1' and cout = '0' report "001 failed" severity error;
        a <= '0'; b <= '1'; cin <= '0'; wait for 10 ns;  -- s = 1, cout = 0
        assert s = '1' and cout = '0' report "010 failed" severity error;
        a <= '0'; b <= '1'; cin <= '1'; wait for 10 ns;  -- s = 0, cout = 1
        assert s = '0' and cout = '1' report "011 failed" severity error;
        a <= '1'; b <= '0'; cin <= '0'; wait for 10 ns;  -- s = 1, cout = 0
        assert s = '1' and cout = '0' report "100 failed" severity error;
        a <= '1'; b <= '0'; cin <= '1'; wait for 10 ns;  -- s = 0, cout = 1
        assert s = '0' and cout = '1' report "101 failed" severity error;
        a <= '1'; b <= '1'; cin <= '0'; wait for 10 ns;  -- s = 0, cout = 1
        assert s = '0' and cout = '1' report "110 failed" severity error;
        a <= '1'; b <= '1'; cin <= '1'; wait for 10 ns;  -- s = 1, cout = 1
        assert s = '1' and cout = '1' report "111 failed" severity error;
        wait;
    end process;
end sim;
