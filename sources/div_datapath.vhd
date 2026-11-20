-- div_datapath : signed non-restoring divider datapath (M, SQ, A, Q and CNT registers).
-- Quotient truncates toward zero, remainder has the sign of the dividend.
library ieee;
use ieee.std_logic_1164.all;

entity div_datapath is
    port (
        i_clock, i_reset : in std_logic;
        i_IN1, i_IN2     : in  std_logic_vector(3 downto 0);   -- dividend, divisor
        i_load, i_shift, i_conv, i_corr : in std_logic;
        o_cntLast, o_cond, o_ovf : out std_logic;
        o_remainder      : out std_logic_vector(3 downto 0);
        o_quotient       : out std_logic_vector(3 downto 0)
    );
end div_datapath;

architecture structural of div_datapath is
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

    signal M, Q, Q_sh, Q_pm, Q_mid, Q_next : std_logic_vector(3 downto 0);
    signal A, M_sx, A_sh, X, T, A_ext, A_next : std_logic_vector(4 downto 0);
    signal cnt, cnt_next : std_logic_vector(1 downto 0);
    signal SQ, subOp, addQ, en_load, en_A, en_Q, en_cnt : std_logic;
    signal A_nz, T_z, M_z : std_logic;
    signal nc1, nc2, nc3, nc4 : std_logic;
begin
    en_load <= i_load;
    en_A    <= i_load or i_shift or i_corr;
    en_Q    <= i_load or i_shift or i_conv or i_corr;
    en_cnt  <= i_load or i_shift;

    -- divisor register and dividend sign
    reg_M : regN generic map (4)   port map (i_clock, i_reset, en_load, i_IN2, M);
    ff_SQ : dFF  generic map ('0') port map (i_clock, i_reset, en_load, i_IN1(3), SQ);
    M_sx <= M(3) & M;

    -- adder/subtractor : T = X -/+ M
    A_sh <= A(3 downto 0) & Q(3);                          -- shift A:Q left
    mx_X : mux2N generic map (5) port map (A, A_sh, i_shift, X);
    subOp <= not (X(4) xor M_sx(4));                       -- same sign -> subtract
    as_A : addSubN generic map (5) port map (X, M_sx, subOp, T, nc1, nc2);

    -- A register : sign extension of the dividend (S0) or T (S1, S3/S4)
    A_ext <= i_IN1(3) & i_IN1(3) & i_IN1(3) & i_IN1(3) & i_IN1(3);
    mx_A  : mux2N generic map (5) port map (T, A_ext, i_load, A_next);
    reg_A : regN  generic map (5) port map (i_clock, i_reset, en_A, A_next, A);

    -- Q register : dividend (S0), shift in q (S1) or '1' (S2), Q +/- 1 (S3/S4)
    Q_sh <= Q(2 downto 0) & (subOp or i_conv);
    addQ <= not subOp;                                     -- Q - 1 when the signs differ
    as_Q  : addSubN generic map (4) port map (Q, "0001", addQ, Q_pm, nc3, nc4);
    mx_Q1 : mux2N   generic map (4) port map (Q_sh, Q_pm, i_corr, Q_mid);
    mx_Q2 : mux2N   generic map (4) port map (Q_mid, i_IN1, i_load, Q_next);
    reg_Q : regN    generic map (4) port map (i_clock, i_reset, en_Q, Q_next, Q);

    -- 2-bit iteration counter (cleared in S0, +1 in S1)
    cnt_next(0) <= (not cnt(0)) and (not i_load);
    cnt_next(1) <= (cnt(1) xor cnt(0)) and (not i_load);
    reg_cnt : regN generic map (2) port map (i_clock, i_reset, en_cnt, cnt_next, cnt);
    o_cntLast <= cnt(1) and cnt(0);

    -- comparators / status
    A_nz <= A(4) or A(3) or A(2) or A(1) or A(0);
    T_z  <= not (T(4) or T(3) or T(2) or T(1) or T(0));
    M_z  <= not (M(3) or M(2) or M(1) or M(0));
    o_cond <= A_nz and ((A(4) xor SQ) or T_z);
    o_ovf  <= M_z or ((not (SQ xor M(3))) and Q(3));

    o_remainder <= A(3 downto 0);
    o_quotient  <= Q;
end structural;
