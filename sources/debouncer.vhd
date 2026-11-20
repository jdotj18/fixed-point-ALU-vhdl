-- debouncer : samples BTNC once every G_N clocks (10 ms) so each press
-- gives exactly one clean GClock edge.
library ieee;
use ieee.std_logic_1164.all;

entity debouncer is
    generic ( G_N : integer := 1000000 );          -- 1,000,000 x 10 ns = 10 ms
    port (
        i_clk    : in  std_logic;                  -- CLK100MHZ
        i_reset  : in  std_logic;                  -- GReset
        i_button : in  std_logic;                  -- raw BTNC
        o_clean  : out std_logic                   -- debounced GClock
    );
end debouncer;

architecture structural of debouncer is
    component clk_divider
        generic ( G_N : integer );
        port ( i_clock, i_reset : in std_logic; o_tick : out std_logic );
    end component;
    component dFF
        generic ( G_INIT : std_logic );
        port ( i_clock, i_reset, i_enable, i_d : in std_logic; o_q : out std_logic );
    end component;
    signal tick, s1 : std_logic;
begin
    u_tick : clk_divider generic map (G_N => G_N) port map (i_clk, i_reset, tick);
    ff_s1  : dFF generic map ('0') port map (i_clk, i_reset, tick, i_button, s1);   -- sample
    ff_s2  : dFF generic map ('0') port map (i_clk, i_reset, tick, s1, o_clean);    -- clean output
end structural;
