-- Testbench for debouncer (G_N = 50, one sample every 500 ns): 2 bouncing presses,
-- each press must give one clean edge.
library ieee;
use ieee.std_logic_1164.all;

entity tb_debouncer is
end tb_debouncer;

architecture sim of tb_debouncer is
    signal clk : std_logic := '0';
    signal rst, btn, clean : std_logic := '0';
begin
    clk <= not clk after 5 ns;

    uut : entity work.debouncer generic map (G_N => 50)
        port map (i_clk => clk, i_reset => rst, i_button => btn, o_clean => clean);

    process
        procedure bounce (v : std_logic) is   -- 5 bounces of 40 ns, then settle at v
        begin
            for k in 1 to 5 loop
                btn <= v; wait for 20 ns; btn <= not v; wait for 20 ns;
            end loop;
            btn <= v;
        end procedure;
    begin
        rst <= '1'; wait for 20 ns; rst <= '0';
        for p in 1 to 2 loop
            bounce('1'); wait for 2 us;       -- clean = 1 (one rising edge)
            assert clean = '1' report "press not seen" severity error;
            bounce('0'); wait for 2 us;       -- clean = 0
            assert clean = '0' report "release not seen" severity error;
        end loop;
        wait;
    end process;
end sim;
