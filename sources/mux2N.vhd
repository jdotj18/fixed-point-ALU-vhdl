-- mux2N : N-bit 2-to-1 multiplexer (sel = 0 -> a, sel = 1 -> b).
library ieee;
use ieee.std_logic_1164.all;

entity mux2N is
    generic ( N : integer := 4 );
    port (
        i_a, i_b : in  std_logic_vector(N-1 downto 0);
        i_sel    : in  std_logic;
        o_y      : out std_logic_vector(N-1 downto 0)
    );
end mux2N;

architecture structural of mux2N is
begin
    gen_bits : for i in 0 to N-1 generate
        o_y(i) <= (i_a(i) and (not i_sel)) or (i_b(i) and i_sel);
    end generate;
end structural;
