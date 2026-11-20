-- mux4to1_8bit : 8-bit 4-to-1 multiplexer made of three 2-to-1 muxes.
-- sel = 00 -> d0, 01 -> d1, 10 -> d2, 11 -> d3
library ieee;
use ieee.std_logic_1164.all;

entity mux4to1_8bit is
    port (
        i_d0, i_d1, i_d2, i_d3 : in  std_logic_vector(7 downto 0);
        i_sel1, i_sel0         : in  std_logic;
        o_y                    : out std_logic_vector(7 downto 0)
    );
end mux4to1_8bit;

architecture structural of mux4to1_8bit is
    component mux2to1_8bit
        port ( i_a, i_b : in std_logic_vector(7 downto 0);
               i_sel    : in std_logic;
               o_y      : out std_logic_vector(7 downto 0) );
    end component;
    signal low_out, high_out : std_logic_vector(7 downto 0);
begin
    -- first level: sel0 picks between d0/d1 and between d2/d3
    mux_low  : mux2to1_8bit port map (i_a => i_d0, i_b => i_d1, i_sel => i_sel0, o_y => low_out);
    mux_high : mux2to1_8bit port map (i_a => i_d2, i_b => i_d3, i_sel => i_sel0, o_y => high_out);
    -- second level: sel1 picks the final result
    mux_out  : mux2to1_8bit port map (i_a => low_out, i_b => high_out, i_sel => i_sel1, o_y => o_y);
end structural;
