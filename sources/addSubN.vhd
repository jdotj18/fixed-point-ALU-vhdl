-- addSubN : N-bit ripple-carry adder/subtractor (pre-lab, Figure 6).
-- sub = 0: s = a + b, sub = 1: s = a - b. ovf = c(N) xor c(N-1).
library ieee;
use ieee.std_logic_1164.all;

entity addSubN is
    generic ( N : integer := 4 );
    port (
        i_a, i_b : in  std_logic_vector(N-1 downto 0);
        i_sub    : in  std_logic;                       -- Add'/Sub control
        o_s      : out std_logic_vector(N-1 downto 0);
        o_cout   : out std_logic;
        o_ovf    : out std_logic
    );
end addSubN;

architecture structural of addSubN is
    component fullAdder
        port ( i_a, i_b, i_cin : in std_logic; o_s, o_cout : out std_logic );
    end component;
    signal b_x : std_logic_vector(N-1 downto 0);        -- b or not b
    signal c   : std_logic_vector(N downto 0);          -- carry chain
begin
    c(0) <= i_sub;
    gen_fa : for i in 0 to N-1 generate
        b_x(i) <= i_b(i) xor i_sub;
        fa : fullAdder port map (i_a => i_a(i), i_b => b_x(i), i_cin => c(i),
                                 o_s => o_s(i), o_cout => c(i+1));
    end generate;
    o_cout <= c(N);
    o_ovf  <= c(N) xor c(N-1);
end structural;
