-- regN : N-bit register (N dFFs) with load enable and asynchronous reset.
library ieee;
use ieee.std_logic_1164.all;

entity regN is
    generic ( N : integer := 4 );
    port (
        i_clock : in  std_logic;
        i_reset : in  std_logic;
        i_load  : in  std_logic;
        i_d     : in  std_logic_vector(N-1 downto 0);
        o_q     : out std_logic_vector(N-1 downto 0)
    );
end regN;

architecture structural of regN is
    component dFF
        generic ( G_INIT : std_logic );
        port ( i_clock, i_reset, i_enable, i_d : in std_logic; o_q : out std_logic );
    end component;
begin
    gen_bits : for i in 0 to N-1 generate
        ff : dFF generic map (G_INIT => '0')
                 port map (i_clock => i_clock, i_reset => i_reset, i_enable => i_load,
                           i_d => i_d(i), o_q => o_q(i));
    end generate;
end structural;
