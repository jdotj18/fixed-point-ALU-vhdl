-- signedDivider : 4-bit signed divider (datapath + control).
-- The result is valid 8 GClock edges after GReset. ovf = divide by 0 or -8 / -1.
library ieee;
use ieee.std_logic_1164.all;

entity signedDivider is
    port (
        i_clock, i_reset : in  std_logic;
        i_A, i_B         : in  std_logic_vector(3 downto 0);   -- dividend, divisor
        o_quotient       : out std_logic_vector(3 downto 0);
        o_remainder      : out std_logic_vector(3 downto 0);
        o_done, o_ovf    : out std_logic
    );
end signedDivider;

architecture structural of signedDivider is
    component div_datapath
        port ( i_clock, i_reset : in std_logic; i_IN1, i_IN2 : in std_logic_vector(3 downto 0);
               i_load, i_shift, i_conv, i_corr : in std_logic;
               o_cntLast, o_cond, o_ovf : out std_logic;
               o_remainder, o_quotient : out std_logic_vector(3 downto 0) );
    end component;
    component div_control
        port ( i_clock, i_reset, i_cntLast, i_cond : in std_logic;
               o_load, o_shift, o_conv, o_corr, o_done : out std_logic );
    end component;
    signal load, shift, conv, corr, done, cntLast, cond, ovf : std_logic;
begin
    dp : div_datapath port map (i_clock, i_reset, i_A, i_B, load, shift, conv, corr,
                                cntLast, cond, ovf, o_remainder, o_quotient);
    cp : div_control  port map (i_clock, i_reset, cntLast, cond,
                                load, shift, conv, corr, done);
    o_done <= done;
    o_ovf  <= done and ovf;
end structural;
