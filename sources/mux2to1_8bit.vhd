-- mux2to1_8bit : 8-bit 2-to-1 multiplexer (sel = 0 -> a, sel = 1 -> b).
library ieee;
use ieee.std_logic_1164.all;

entity mux2to1_8bit is
    port (
        i_a   : in  std_logic_vector(7 downto 0);
        i_b   : in  std_logic_vector(7 downto 0);
        i_sel : in  std_logic;
        o_y   : out std_logic_vector(7 downto 0)
    );
end mux2to1_8bit;

architecture structural of mux2to1_8bit is
begin
    gen_bits : for i in 0 to 7 generate
        o_y(i) <= (i_a(i) and (not i_sel)) or (i_b(i) and i_sel);
    end generate;
end structural;
