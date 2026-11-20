-- Testbench for signedDivider: GReset, then GClock; the result is ready on the 8th edge.
library ieee;
use ieee.std_logic_1164.all;

entity tb_signedDivider is
end tb_signedDivider;

architecture sim of tb_signedDivider is
    signal GClock : std_logic := '0';
    signal GReset, done, ovf : std_logic := '0';
    signal A, B, quotient, remainder : std_logic_vector(3 downto 0) := "0000";
begin
    GClock <= not GClock after 10 ns;

    uut : entity work.signedDivider
        port map (i_clock => GClock, i_reset => GReset, i_A => A, i_B => B,
                  o_quotient => quotient, o_remainder => remainder, o_done => done, o_ovf => ovf);

    process
        procedure run (a_in, b_in : std_logic_vector(3 downto 0)) is
        begin
            A <= a_in; B <= b_in;
            GReset <= '1'; wait for 20 ns; GReset <= '0';
            wait for 200 ns;   -- 10 GClock edges (8 needed)
        end procedure;
    begin
        run("0111", "0010");  --  7 /  2 :  Q = 3 (0011), R =  1 (0001)
        assert done = '1' and quotient = "0011" and remainder = "0001" and ovf = '0' report "7 / 2 failed" severity error;
        run("1001", "0010");  -- -7 /  2 : Q = -3 (1101), R = -1 (1111)
        assert done = '1' and quotient = "1101" and remainder = "1111" and ovf = '0' report "-7 / 2 failed" severity error;
        run("0111", "1110");  --  7 / -2 : Q = -3 (1101), R =  1 (0001)
        assert done = '1' and quotient = "1101" and remainder = "0001" and ovf = '0' report "7 / -2 failed" severity error;
        run("1010", "1101");  -- -6 / -3 :  Q = 2 (0010), R =  0 (0000)
        assert done = '1' and quotient = "0010" and remainder = "0000" and ovf = '0' report "-6 / -3 failed" severity error;
        run("1000", "1111");  -- -8 / -1 = 8 does not fit in 4 bits : ovf = 1
        assert done = '1' and ovf = '1' report "-8 / -1 failed" severity error;
        run("0101", "0000");  --  5 /  0 : ovf = 1
        assert done = '1' and ovf = '1' report "5 / 0 failed" severity error;
        wait;
    end process;
end sim;
