-- mult_datapath : Booth multiplier datapath (M, A, Q, Qp, CNT and P registers).
-- A is 5 bits so that A - M cannot overflow when M = -8.
library ieee;
use ieee.std_logic_1164.all;

entity mult_datapath is
    port (
        i_clock, i_reset : in  std_logic;
        i_A, i_B         : in  std_logic_vector(3 downto 0);   -- multiplicand, multiplier
        i_load           : in  std_logic;   -- S0
        i_shift          : in  std_logic;   -- S1
        i_loadOut        : in  std_logic;   -- S1.cntLast
        o_cntLast        : out std_logic;   -- CNT = 3
        o_product        : out std_logic_vector(7 downto 0)
    );
end mult_datapath;

architecture structural of mult_datapath is
    component regN
        generic ( N : integer );
        port ( i_clock, i_reset, i_load : in std_logic;
               i_d : in std_logic_vector(N-1 downto 0); o_q : out std_logic_vector(N-1 downto 0) );
    end component;
    component addSubN
        generic ( N : integer );
        port ( i_a, i_b : in std_logic_vector(N-1 downto 0); i_sub : in std_logic;
               o_s : out std_logic_vector(N-1 downto 0); o_cout, o_ovf : out std_logic );
    end component;
    component dFF
        generic ( G_INIT : std_logic );
        port ( i_clock, i_reset, i_enable, i_d : in std_logic; o_q : out std_logic );
    end component;
    component mux2N
        generic ( N : integer );
        port ( i_a, i_b : in std_logic_vector(N-1 downto 0); i_sel : in std_logic;
               o_y : out std_logic_vector(N-1 downto 0) );
    end component;

    signal M, Q, Q_shift, Q_next         : std_logic_vector(3 downto 0);
    signal A, M_sx, A_sum, A_op          : std_logic_vector(4 downto 0);
    signal A_shift, A_next               : std_logic_vector(4 downto 0);
    signal cnt, cnt_next                 : std_logic_vector(1 downto 0);
    signal P_d                           : std_logic_vector(7 downto 0);
    signal Qp, Qp_next, do_op, en, en_M, en_P, nc1, nc2 : std_logic;
begin
    en   <= i_load or i_shift;
    en_M <= i_load;
    en_P <= i_loadOut;

    -- M register
    reg_M : regN generic map (4) port map (i_clock, i_reset, en_M, i_A, M);

    -- A +/- M (subtract when Q0 = 1)
    M_sx <= M(3) & M;
    as5  : addSubN generic map (5) port map (A, M_sx, Q(0), A_sum, nc1, nc2);
    do_op <= Q(0) xor Qp;                                  -- 01 or 10 -> use the sum
    mx_op : mux2N generic map (5) port map (A, A_sum, do_op, A_op);

    -- arithmetic shift right of A_op : Q : Qp
    A_shift <= A_op(4) & A_op(4 downto 1);
    Q_shift <= A_op(0) & Q(3 downto 1);

    -- load (S0) or shift (S1) values
    mx_A : mux2N generic map (5) port map (A_shift, "00000", i_load, A_next);
    mx_Q : mux2N generic map (4) port map (Q_shift, i_B,     i_load, Q_next);
    Qp_next <= Q(0) and (not i_load);

    reg_A : regN generic map (5)   port map (i_clock, i_reset, en, A_next, A);
    reg_Q : regN generic map (4)   port map (i_clock, i_reset, en, Q_next, Q);
    ff_Qp : dFF  generic map ('0') port map (i_clock, i_reset, en, Qp_next, Qp);

    -- 2-bit iteration counter (cleared in S0, +1 in S1)
    cnt_next(0) <= (not cnt(0)) and (not i_load);
    cnt_next(1) <= (cnt(1) xor cnt(0)) and (not i_load);
    reg_cnt : regN generic map (2) port map (i_clock, i_reset, en, cnt_next, cnt);
    o_cntLast <= cnt(1) and cnt(0);

    -- product register (loads the result of the 4th iteration)
    P_d <= A_next(3 downto 0) & Q_next;
    reg_P : regN generic map (8) port map (i_clock, i_reset, en_P, P_d, o_product);
end structural;
