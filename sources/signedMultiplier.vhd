-- signedMultiplier : 4-bit signed multiplier (datapath + control).
-- The product is valid 5 GClock edges after GReset.
library ieee;
use ieee.std_logic_1164.all;

entity signedMultiplier is
    port (
        i_clock, i_reset : in  std_logic;
        i_A, i_B         : in  std_logic_vector(3 downto 0);
        o_product        : out std_logic_vector(7 downto 0);
        o_done           : out std_logic
    );
end signedMultiplier;

architecture structural of signedMultiplier is
    component mult_datapath
        port ( i_clock, i_reset : in std_logic; i_A, i_B : in std_logic_vector(3 downto 0);
               i_load, i_shift, i_loadOut : in std_logic; o_cntLast : out std_logic;
               o_product : out std_logic_vector(7 downto 0) );
    end component;
    component mult_control
        port ( i_clock, i_reset, i_cntLast : in std_logic;
               o_load, o_shift, o_loadOut, o_done : out std_logic );
    end component;
    signal load, shift, loadOut, cntLast : std_logic;
begin
    dp : mult_datapath port map (i_clock, i_reset, i_A, i_B, load, shift, loadOut, cntLast, o_product);
    cp : mult_control  port map (i_clock, i_reset, cntLast, load, shift, loadOut, o_done);
end structural;
