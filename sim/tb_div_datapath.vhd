-- Testbench for div_datapath: the testbench acts as the control logic
-- (load, 4 shifts, convert, 2 corrections when cond = 1) for 7 / 2 and -7 / 2.
library ieee;
use ieee.std_logic_1164.all;

entity tb_div_datapath is
end tb_div_datapath;

architecture sim of tb_div_datapath is
    signal clk : std_logic := '0';
    signal rst, load, shift, conv, corrStep : std_logic := '0';
    signal corr, cntLast, cond, ovf : std_logic;
    signal a, b, q, r : std_logic_vector(3 downto 0) := "0000";
begin
    clk <= not clk after 10 ns;
    corr <= corrStep and cond;   -- same as the control logic in S3 and S4

    uut : entity work.div_datapath
        port map (i_clock => clk, i_reset => rst, i_IN1 => a, i_IN2 => b,
                  i_load => load, i_shift => shift, i_conv => conv, i_corr => corr,
                  o_cntLast => cntLast, o_cond => cond, o_ovf => ovf,
                  o_remainder => r, o_quotient => q);

    process
        procedure divide is
        begin
            load <= '1'; wait for 20 ns;                 -- S0 : load
            load <= '0'; shift <= '1'; wait for 80 ns;   -- S1 : 4 iterations
            shift <= '0'; conv <= '1'; wait for 20 ns;   -- S2 : convert
            conv <= '0'; corrStep <= '1'; wait for 40 ns; -- S3, S4 : correct
            corrStep <= '0'; wait for 40 ns;
        end procedure;
    begin
        rst <= '1'; wait for 15 ns; rst <= '0';
        a <= "0111"; b <= "0010"; divide;  --  7 / 2 :  q = 3 (0011), r =  1 (0001)
        assert q = "0011" and r = "0001" and ovf = '0' report "7 / 2 failed" severity error;
        a <= "1001"; b <= "0010"; divide;  -- -7 / 2 : q = -3 (1101), r = -1 (1111)
        assert q = "1101" and r = "1111" and ovf = '0' report "-7 / 2 failed" severity error;
        wait;
    end process;
end sim;
