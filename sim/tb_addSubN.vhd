-- Testbench for addSubN (N = 4, pre-lab): 4 additions and 4 subtractions.
library ieee;
use ieee.std_logic_1164.all;

entity tb_addSubN is
end tb_addSubN;

architecture sim of tb_addSubN is
    signal a, b, s : std_logic_vector(3 downto 0);
    signal sub, cout, ovf : std_logic;
begin
    uut : entity work.addSubN generic map (N => 4)
        port map (i_a => a, i_b => b, i_sub => sub, o_s => s, o_cout => cout, o_ovf => ovf);

    process
    begin
        -- addition (sub = 0)
        sub <= '0';
        a <= "0011"; b <= "0010"; wait for 20 ns;  --  3 +  2 =  5 : s = 0101, cout = 0, ovf = 0
        assert s = "0101" and cout = '0' and ovf = '0' report "3 + 2 failed" severity error;
        a <= "0111"; b <= "0001"; wait for 20 ns;  --  7 +  1 =  8 : s = 1000, cout = 0, ovf = 1
        assert s = "1000" and cout = '0' and ovf = '1' report "7 + 1 failed" severity error;
        a <= "1111"; b <= "0001"; wait for 20 ns;  -- -1 +  1 =  0 : s = 0000, cout = 1, ovf = 0
        assert s = "0000" and cout = '1' and ovf = '0' report "-1 + 1 failed" severity error;
        a <= "1000"; b <= "1111"; wait for 20 ns;  -- -8 + -1 = -9 : s = 0111, cout = 1, ovf = 1
        assert s = "0111" and cout = '1' and ovf = '1' report "-8 + -1 failed" severity error;
        -- subtraction (sub = 1), cout = 1 means no borrow
        sub <= '1';
        a <= "0101"; b <= "0011"; wait for 20 ns;  --  5 -  3 =  2 : s = 0010, cout = 1, ovf = 0
        assert s = "0010" and cout = '1' and ovf = '0' report "5 - 3 failed" severity error;
        a <= "0010"; b <= "0101"; wait for 20 ns;  --  2 -  5 = -3 : s = 1101, cout = 0, ovf = 0
        assert s = "1101" and cout = '0' and ovf = '0' report "2 - 5 failed" severity error;
        a <= "1000"; b <= "0001"; wait for 20 ns;  -- -8 -  1 = -9 : s = 0111, cout = 1, ovf = 1
        assert s = "0111" and cout = '1' and ovf = '1' report "-8 - 1 failed" severity error;
        a <= "0111"; b <= "1111"; wait for 20 ns;  --  7 - -1 =  8 : s = 1000, cout = 0, ovf = 1
        assert s = "1000" and cout = '0' and ovf = '1' report "7 - -1 failed" severity error;
        wait;
    end process;
end sim;
