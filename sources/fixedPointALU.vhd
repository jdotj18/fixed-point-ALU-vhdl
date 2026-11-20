-- fixedPointALU : top level, 4-bit signed ALU (Tables 3, 4 and 5).
-- GClock is debounced on the board; G_DEBOUNCE = 0 bypasses it in simulation.
library ieee;
use ieee.std_logic_1164.all;

entity fixedPointALU is
    generic ( G_DEBOUNCE : integer := 1000000 );
    port (
        GClock          : in  std_logic;
        GReset          : in  std_logic;
        CLK100MHZ       : in  std_logic;
        OperandA        : in  std_logic_vector(3 downto 0);
        OperandB        : in  std_logic_vector(3 downto 0);
        OperationSelect : in  std_logic_vector(1 downto 0);
        MuxOut          : out std_logic_vector(7 downto 0);
        CarryOut        : out std_logic;
        ZeroOut         : out std_logic;
        OverflowOut     : out std_logic;
        seg             : out std_logic_vector(6 downto 0);
        an              : out std_logic_vector(7 downto 0)
    );
end fixedPointALU;

architecture structural of fixedPointALU is
    component addSubN
        generic ( N : integer );
        port ( i_a, i_b : in std_logic_vector(N-1 downto 0); i_sub : in std_logic;
               o_s : out std_logic_vector(N-1 downto 0); o_cout, o_ovf : out std_logic );
    end component;
    component regN
        generic ( N : integer );
        port ( i_clock, i_reset, i_load : in std_logic;
               i_d : in std_logic_vector(N-1 downto 0); o_q : out std_logic_vector(N-1 downto 0) );
    end component;
    component signedMultiplier
        port ( i_clock, i_reset : in std_logic; i_A, i_B : in std_logic_vector(3 downto 0);
               o_product : out std_logic_vector(7 downto 0); o_done : out std_logic );
    end component;
    component signedDivider
        port ( i_clock, i_reset : in std_logic; i_A, i_B : in std_logic_vector(3 downto 0);
               o_quotient, o_remainder : out std_logic_vector(3 downto 0); o_done, o_ovf : out std_logic );
    end component;
    component mux4to1_8bit
        port ( i_d0, i_d1, i_d2, i_d3 : in std_logic_vector(7 downto 0);
               i_sel1, i_sel0 : in std_logic; o_y : out std_logic_vector(7 downto 0) );
    end component;
    component debouncer
        generic ( G_N : integer );
        port ( i_clk, i_reset, i_button : in std_logic; o_clean : out std_logic );
    end component;
    component display_controller
        port ( i_clk, i_reset : in std_logic; i_value : in std_logic_vector(7 downto 0);
               o_seg : out std_logic_vector(6 downto 0); o_an : out std_logic_vector(7 downto 0) );
    end component;

    signal sum_d, diff_d : std_logic_vector(3 downto 0);
    signal add_c, add_v, sub_c, sub_v : std_logic;
    signal add_d, sub_d, add_q, sub_q : std_logic_vector(5 downto 0);
    signal SumOut, DifferenceOut, QuotientOut, RemainderOut : std_logic_vector(3 downto 0);
    signal ProductOut, in00, in01, in11, result : std_logic_vector(7 downto 0);
    signal mul_done, div_done, div_ovf, as_carry, as_ovf : std_logic;
    signal gclk : std_logic;
begin
    -- GClock debouncer (board) or direct GClock (simulation)
    gen_db : if G_DEBOUNCE > 0 generate
        u_db : debouncer generic map (G_N => G_DEBOUNCE) port map (CLK100MHZ, GReset, GClock, gclk);
    end generate;
    gen_nodb : if G_DEBOUNCE = 0 generate
        gclk <= GClock;
    end generate;

    -- adder and subtractor, registered on GClock
    u_add : addSubN generic map (4) port map (OperandA, OperandB, '0', sum_d,  add_c, add_v);
    u_sub : addSubN generic map (4) port map (OperandA, OperandB, '1', diff_d, sub_c, sub_v);
    add_d <= add_c & add_v & sum_d;
    sub_d <= (not sub_c) & sub_v & diff_d;                 -- borrow out = not c4
    u_addreg : regN generic map (6) port map (gclk, GReset, '1', add_d, add_q);
    u_subreg : regN generic map (6) port map (gclk, GReset, '1', sub_d, sub_q);
    SumOut        <= add_q(3 downto 0);
    DifferenceOut <= sub_q(3 downto 0);

    -- signed multiplier and divider
    u_mult : signedMultiplier port map (gclk, GReset, OperandA, OperandB, ProductOut, mul_done);
    u_div  : signedDivider    port map (gclk, GReset, OperandA, OperandB, QuotientOut, RemainderOut,
                                        div_done, div_ovf);

    -- output multiplexer (Table 4)
    in00 <= "0000" & SumOut;
    in01 <= "0000" & DifferenceOut;
    in11 <= RemainderOut & QuotientOut;
    u_mux : mux4to1_8bit port map (in00, in01, ProductOut, in11,
                                   OperationSelect(1), OperationSelect(0), result);
    MuxOut <= result;

    -- status signals
    as_carry <= (add_q(5) and (not OperationSelect(0))) or (sub_q(5) and OperationSelect(0));
    as_ovf   <= (add_q(4) and (not OperationSelect(0))) or (sub_q(4) and OperationSelect(0));
    CarryOut    <= as_carry and (not OperationSelect(1));
    ZeroOut     <= not (result(7) or result(6) or result(5) or result(4) or
                        result(3) or result(2) or result(1) or result(0));
    OverflowOut <= (as_ovf and (not OperationSelect(1))) or
                   (div_ovf and OperationSelect(1) and OperationSelect(0));

    -- seven-segment display
    u_disp : display_controller port map (CLK100MHZ, GReset, result, seg, an);
end structural;
