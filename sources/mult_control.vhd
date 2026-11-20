-- mult_control : multiplier control logic, one FF per state.
-- S0 load -> S1 shift (4 times, loadOut on the 4th) -> S2 done
library ieee;
use ieee.std_logic_1164.all;

entity mult_control is
    port (
        i_clock, i_reset : in  std_logic;
        i_cntLast                : in  std_logic;
        o_load, o_shift, o_loadOut, o_done : out std_logic
    );
end mult_control;

architecture structural of mult_control is
    component dFF
        generic ( G_INIT : std_logic );
        port ( i_clock, i_reset, i_enable, i_d : in std_logic; o_q : out std_logic );
    end component;
    signal s0, s1, s2, d0, d1, d2 : std_logic;
begin
    d0 <= '0';
    d1 <= s0 or (s1 and (not i_cntLast));
    d2 <= (s1 and i_cntLast) or s2;

    ff_s0 : dFF generic map ('1') port map (i_clock, i_reset, '1', d0, s0);
    ff_s1 : dFF generic map ('0') port map (i_clock, i_reset, '1', d1, s1);
    ff_s2 : dFF generic map ('0') port map (i_clock, i_reset, '1', d2, s2);

    o_load    <= s0;
    o_shift   <= s1;
    o_loadOut <= s1 and i_cntLast;
    o_done    <= s2;
end structural;
