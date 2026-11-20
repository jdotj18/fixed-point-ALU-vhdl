-- Testbench for signedMultiplier: GReset, then GClock; the product is ready on the 5th edge.
library ieee;
use ieee.std_logic_1164.all;

entity tb_signedMultiplier is
end tb_signedMultiplier;

architecture sim of tb_signedMultiplier is
    signal GClock : std_logic := '0';
    signal GReset, done : std_logic := '0';
    signal A, B : std_logic_vector(3 downto 0) := "0000";
    signal product : std_logic_vector(7 downto 0);
begin
    GClock <= not GClock after 10 ns;

    uut : entity work.signedMultiplier
        port map (i_clock => GClock, i_reset => GReset, i_A => A, i_B => B,
                  o_product => product, o_done => done);

    process
        procedure run (a_in, b_in : std_logic_vector(3 downto 0)) is
        begin
            A <= a_in; B <= b_in;
            GReset <= '1'; wait for 20 ns; GReset <= '0';
            wait for 120 ns;   -- 6 GClock edges (5 needed)
        end procedure;
    begin
        run("0011", "0010");  --  3 x  2 =   6 : product = 06
        assert done = '1' and product = x"06" report "3 x 2 failed" severity error;
        run("0111", "0111");  --  7 x  7 =  49 : product = 31
        assert done = '1' and product = x"31" report "7 x 7 failed" severity error;
        run("0011", "1110");  --  3 x -2 =  -6 : product = FA
        assert done = '1' and product = x"FA" report "3 x -2 failed" severity error;
        run("1011", "0011");  -- -5 x  3 = -15 : product = F1
        assert done = '1' and product = x"F1" report "-5 x 3 failed" severity error;
        run("1000", "1000");  -- -8 x -8 =  64 : product = 40
        assert done = '1' and product = x"40" report "-8 x -8 failed" severity error;
        wait;
    end process;
end sim;
