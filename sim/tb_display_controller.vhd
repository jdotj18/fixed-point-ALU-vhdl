-- Testbench for display_controller: value 13 then FA. AN0 shows the low digit,
-- AN1 the high digit; the digit changes every 32768 clocks (327.68 us).
library ieee;
use ieee.std_logic_1164.all;

entity tb_display_controller is
end tb_display_controller;

architecture sim of tb_display_controller is
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal v : std_logic_vector(7 downto 0) := x"00";
    signal seg : std_logic_vector(6 downto 0);
    signal an  : std_logic_vector(7 downto 0);
begin
    clk <= not clk after 5 ns;

    uut : entity work.display_controller
        port map (i_clk => clk, i_reset => rst, i_value => v, o_seg => seg, o_an => an);

    process
    begin
        rst <= '1'; wait for 10 ns; rst <= '0';
        v <= x"13";
        wait for 100 us;     -- an = FE, seg = 0000110 (3)
        assert an = "11111110" and seg = "0000110" report "digit 3 failed" severity error;
        wait for 327.68 us;  -- an = FD, seg = 1001111 (1)
        assert an = "11111101" and seg = "1001111" report "digit 1 failed" severity error;
        v <= x"FA";
        wait for 327.68 us;  -- an = FE, seg = 0001000 (A)
        assert an = "11111110" and seg = "0001000" report "digit A failed" severity error;
        wait for 327.68 us;  -- an = FD, seg = 0111000 (F)
        assert an = "11111101" and seg = "0111000" report "digit F failed" severity error;
        wait;
    end process;
end sim;
