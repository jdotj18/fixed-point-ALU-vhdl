-- clk_divider : counter that outputs a one-clock tick every G_N clocks.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
    generic ( G_N : integer := 100000000 );
    port (
        i_clock : in  std_logic;
        i_reset : in  std_logic;
        o_tick  : out std_logic
    );
end clk_divider;

architecture structural of clk_divider is

    component dFF
        generic ( G_INIT : std_logic );
        port ( i_clock, i_reset, i_enable, i_d : in std_logic; o_q : out std_logic );
    end component;

    constant WIDTH : integer := 27;   -- 2^27 = 134,217,728 > 100,000,000
    constant LAST  : std_logic_vector(WIDTH - 1 downto 0)
                   := std_logic_vector(to_unsigned(G_N - 1, WIDTH));   -- terminal count

    signal q     : std_logic_vector(WIDTH - 1 downto 0);   -- counter register outputs
    signal d     : std_logic_vector(WIDTH - 1 downto 0);   -- counter register inputs
    signal carry : std_logic_vector(WIDTH downto 0);       -- incrementer carry chain
    signal eq    : std_logic_vector(WIDTH - 1 downto 0);   -- bit i of count = bit i of LAST
    signal match : std_logic_vector(WIDTH - 1 downto 0);   -- AND chain of eq
    signal all_match : std_logic;

begin

    carry(0) <= '1';                              -- +1
    match(0) <= eq(0);

    gen_bits : for i in 0 to WIDTH - 1 generate
        carry(i + 1) <= carry(i) and q(i);                        -- incrementer carry
        eq(i)        <= q(i) xnor LAST(i);                        -- bit comparator
        d(i)         <= (q(i) xor carry(i)) and (not all_match);  -- count+1, or 0 at the end
        cnt_ff : dFF generic map (G_INIT => '0')
                     port map (i_clock => i_clock, i_reset => i_reset, i_enable => '1',
                               i_d => d(i), o_q => q(i));
    end generate;

    gen_and : for i in 1 to WIDTH - 1 generate
        match(i) <= match(i - 1) and eq(i);
    end generate;

    all_match <= match(WIDTH - 1);

    tick_ff : dFF generic map (G_INIT => '0')
                  port map (i_clock => i_clock, i_reset => i_reset, i_enable => '1',
                            i_d => all_match, o_q => o_tick);

end structural;
