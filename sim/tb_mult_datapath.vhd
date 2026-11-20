-- Testbench for mult_datapath: the testbench acts as the control logic
-- (1 load clock, 4 shift clocks with loadOut on the 4th) for 3 x -2 and -8 x -8.
library ieee;
use ieee.std_logic_1164.all;

entity tb_mult_datapath is
end tb_mult_datapath;

architecture sim of tb_mult_datapath is
    signal clk : std_logic := '0';
    signal rst, load, shift, loadOut : std_logic := '0';
    signal a, b : std_logic_vector(3 downto 0) := "0000";
    signal cntLast : std_logic;
    signal p : std_logic_vector(7 downto 0);
begin
    clk <= not clk after 10 ns;

    uut : entity work.mult_datapath
        port map (i_clock => clk, i_reset => rst, i_A => a, i_B => b,
                  i_load => load, i_shift => shift, i_loadOut => loadOut,
                  o_cntLast => cntLast, o_product => p);

    process
        procedure multiply is
        begin
            load <= '1'; wait for 20 ns;                     -- S0 : load
            load <= '0'; shift <= '1'; wait for 60 ns;       -- S1 : 3 iterations
            loadOut <= '1'; wait for 20 ns;                  -- S1 : 4th iteration, P loads
            shift <= '0'; loadOut <= '0'; wait for 40 ns;
        end procedure;
    begin
        rst <= '1'; wait for 15 ns; rst <= '0';
        a <= "0011"; b <= "1110"; multiply;  --  3 x -2 = -6 : p = FA
        assert p = x"FA" report "3 x -2 failed" severity error;
        a <= "1000"; b <= "1000"; multiply;  -- -8 x -8 = 64 : p = 40
        assert p = x"40" report "-8 x -8 failed" severity error;
        wait;
    end process;
end sim;
