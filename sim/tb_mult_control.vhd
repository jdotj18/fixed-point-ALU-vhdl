-- Testbench for mult_control: S0 -> S1 (4 times) -> S2 and the outputs of each state.
library ieee;
use ieee.std_logic_1164.all;

entity tb_mult_control is
end tb_mult_control;

architecture sim of tb_mult_control is
    signal clk : std_logic := '0';
    signal rst, cntLast : std_logic := '0';
    signal load, shift, loadOut, done : std_logic;
begin
    clk <= not clk after 10 ns;

    uut : entity work.mult_control
        port map (i_clock => clk, i_reset => rst, i_cntLast => cntLast,
                  o_load => load, o_shift => shift, o_loadOut => loadOut, o_done => done);

    process
    begin
        rst <= '1'; wait for 15 ns; rst <= '0';  -- S0 : load = 1
        assert load = '1' report "S0 failed" severity error;
        wait for 20 ns;                          -- S1 : shift = 1 (CNT = 1)
        assert shift = '1' and loadOut = '0' report "S1 failed" severity error;
        wait for 40 ns;                          -- S1 (CNT = 3)
        cntLast <= '1'; wait for 5 ns;           -- shift = 1, loadOut = 1
        assert shift = '1' and loadOut = '1' report "S1 loadOut failed" severity error;
        wait for 15 ns; cntLast <= '0';          -- S2 : done = 1
        assert done = '1' and shift = '0' report "S2 failed" severity error;
        wait for 40 ns;                          -- stays in S2
        assert done = '1' report "S2 hold failed" severity error;
        wait;
    end process;
end sim;
