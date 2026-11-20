-- Testbench for dFF: one copy with G_INIT = '0' (like S1..S5), one with G_INIT = '1' (like S0).
library ieee;
use ieee.std_logic_1164.all;

entity tb_dFF is
end tb_dFF;

architecture sim of tb_dFF is
    signal clk : std_logic := '0';
    signal rst, en, d : std_logic := '0';
    signal q0, q1 : std_logic;
begin
    clk <= not clk after 5 ns;   -- 100 MHz clock

    uut0 : entity work.dFF generic map (G_INIT => '0')
        port map (i_clock => clk, i_reset => rst, i_enable => en, i_d => d, o_q => q0);
    uut1 : entity work.dFF generic map (G_INIT => '1')
        port map (i_clock => clk, i_reset => rst, i_enable => en, i_d => d, o_q => q1);

    process
    begin
        rst <= '1'; wait for 20 ns;          -- q0 = 0, q1 = 1
        rst <= '0';
        d <= '1'; en <= '0'; wait for 20 ns; -- enable off: outputs hold
        en <= '1';           wait for 20 ns; -- enable on: both become 1
        d <= '0';            wait for 20 ns; -- both become 0
        en <= '0'; d <= '1'; wait for 20 ns; -- hold 0
        wait;
    end process;
end sim;
