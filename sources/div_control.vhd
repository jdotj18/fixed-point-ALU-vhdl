-- div_control : divider control logic, one FF per state.
-- S0 load -> S1 shift (4 times) -> S2 convert -> S3, S4 correct -> S5 done
library ieee;
use ieee.std_logic_1164.all;

entity div_control is
    port (
        i_clock, i_reset : in  std_logic;
        i_cntLast, i_cond        : in  std_logic;
        o_load, o_shift, o_conv, o_corr, o_done : out std_logic
    );
end div_control;

architecture structural of div_control is
    component dFF
        generic ( G_INIT : std_logic );
        port ( i_clock, i_reset, i_enable, i_d : in std_logic; o_q : out std_logic );
    end component;
    signal s0, s1, s2, s3, s4, s5, d0, d1, d2, d3, d4, d5 : std_logic;
begin
    d0 <= '0';
    d1 <= s0 or (s1 and (not i_cntLast));
    d2 <= s1 and i_cntLast;
    d3 <= s2;
    d4 <= s3;
    d5 <= s4 or s5;

    ff_s0 : dFF generic map ('1') port map (i_clock, i_reset, '1', d0, s0);
    ff_s1 : dFF generic map ('0') port map (i_clock, i_reset, '1', d1, s1);
    ff_s2 : dFF generic map ('0') port map (i_clock, i_reset, '1', d2, s2);
    ff_s3 : dFF generic map ('0') port map (i_clock, i_reset, '1', d3, s3);
    ff_s4 : dFF generic map ('0') port map (i_clock, i_reset, '1', d4, s4);
    ff_s5 : dFF generic map ('0') port map (i_clock, i_reset, '1', d5, s5);

    o_load  <= s0;
    o_shift <= s1;
    o_conv  <= s2;
    o_corr  <= (s3 or s4) and i_cond;
    o_done  <= s5;
end structural;
