-- Testbench for fixedPointALU (top level): add, subtract, multiply and divide.
-- Each case: set the switches, GReset, then 10 GClock edges (220 ns per case).
library ieee;
use ieee.std_logic_1164.all;

entity tb_fixedPointALU is
end tb_fixedPointALU;

architecture sim of tb_fixedPointALU is
    signal GClock : std_logic := '0';
    signal GReset : std_logic := '0';
    signal OperandA, OperandB : std_logic_vector(3 downto 0) := "0000";
    signal OperationSelect : std_logic_vector(1 downto 0) := "00";
    signal MuxOut : std_logic_vector(7 downto 0);
    signal CarryOut, ZeroOut, OverflowOut : std_logic;
begin
    GClock <= not GClock after 10 ns;

    uut : entity work.fixedPointALU generic map (G_DEBOUNCE => 0)   -- no debouncer in simulation
        port map (GClock => GClock, GReset => GReset, CLK100MHZ => '0',
                  OperandA => OperandA, OperandB => OperandB, OperationSelect => OperationSelect,
                  MuxOut => MuxOut, CarryOut => CarryOut, ZeroOut => ZeroOut,
                  OverflowOut => OverflowOut, seg => open, an => open);

    process
        procedure run (op : std_logic_vector(1 downto 0); a, b : std_logic_vector(3 downto 0)) is
        begin
            OperationSelect <= op; OperandA <= a; OperandB <= b;
            GReset <= '1'; wait for 20 ns; GReset <= '0';
            wait for 200 ns;
        end procedure;
    begin
        -- add (00): MuxOut = 0000 & sum
        run("00", "0011", "0010");  --  3 +  2 =  5 : MuxOut = 05
        assert MuxOut = x"05" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "3 + 2 failed" severity error;
        run("00", "0111", "0001");  --  7 +  1 =  8 : MuxOut = 08, overflow
        assert MuxOut = x"08" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '1' report "7 + 1 failed" severity error;
        run("00", "1111", "0001");  -- -1 +  1 =  0 : MuxOut = 00, carry, zero
        assert MuxOut = x"00" and CarryOut = '1' and ZeroOut = '1' and OverflowOut = '0' report "-1 + 1 failed" severity error;
        -- subtract (01): MuxOut = 0000 & difference, CarryOut = borrow
        run("01", "0010", "0101");  --  2 -  5 = -3 : MuxOut = 0D, borrow
        assert MuxOut = x"0D" and CarryOut = '1' and ZeroOut = '0' and OverflowOut = '0' report "2 - 5 failed" severity error;
        run("01", "1000", "0001");  -- -8 -  1 = -9 : MuxOut = 07, overflow
        assert MuxOut = x"07" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '1' report "-8 - 1 failed" severity error;
        run("01", "0101", "0101");  --  5 -  5 =  0 : MuxOut = 00, zero
        assert MuxOut = x"00" and CarryOut = '0' and ZeroOut = '1' and OverflowOut = '0' report "5 - 5 failed" severity error;
        -- multiply (10): MuxOut = product
        run("10", "0011", "0010");  --  3 x  2 =   6 : MuxOut = 06
        assert MuxOut = x"06" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "3 x 2 failed" severity error;
        run("10", "0111", "0111");  --  7 x  7 =  49 : MuxOut = 31
        assert MuxOut = x"31" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "7 x 7 failed" severity error;
        run("10", "1100", "0011");  -- -4 x  3 = -12 : MuxOut = F4
        assert MuxOut = x"F4" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "-4 x 3 failed" severity error;
        run("10", "1010", "1110");  -- -6 x -2 =  12 : MuxOut = 0C
        assert MuxOut = x"0C" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "-6 x -2 failed" severity error;
        -- divide (11): MuxOut = remainder & quotient
        run("11", "0110", "0011");  --  6 /  3 =  2 R  0 : MuxOut = 02
        assert MuxOut = x"02" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "6 / 3 failed" severity error;
        run("11", "0111", "0010");  --  7 /  2 =  3 R  1 : MuxOut = 13
        assert MuxOut = x"13" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "7 / 2 failed" severity error;
        run("11", "1001", "0010");  -- -7 /  2 = -3 R -1 : MuxOut = FD
        assert MuxOut = x"FD" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "-7 / 2 failed" severity error;
        run("11", "1001", "1110");  -- -7 / -2 =  3 R -1 : MuxOut = F3
        assert MuxOut = x"F3" and CarryOut = '0' and ZeroOut = '0' and OverflowOut = '0' report "-7 / -2 failed" severity error;
        run("11", "1000", "1111");  -- -8 / -1 =  8 (too big) : MuxOut = 08, overflow
        assert MuxOut = x"08" and CarryOut = '0' and OverflowOut = '1' report "-8 / -1 failed" severity error;
        run("11", "0101", "0000");  --  5 /  0 : overflow
        assert CarryOut = '0' and OverflowOut = '1' report "5 / 0 failed" severity error;
        wait;
    end process;
end sim;
