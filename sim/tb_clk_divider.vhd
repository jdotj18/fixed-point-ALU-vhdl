-- Testbench for clk_divider with G_N = 4: o_tick is high for 1 clock every 4 clocks.
library ieee;
use ieee.std_logic_1164.all;

entity tb_clk_divider is
end tb_clk_divider;

architecture sim of tb_clk_divider is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal tick : std_logic;
begin
    clk <= not clk after 5 ns;

    uut : entity work.clk_divider generic map (G_N => 4)
        port map (i_clock => clk, i_reset => rst, o_tick => tick);

    process
    begin
        wait for 20 ns;
        rst <= '0';
        wait for 200 ns;
        wait;
    end process;
end sim;
