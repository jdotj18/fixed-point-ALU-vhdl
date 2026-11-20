# Fixed-Point Arithmetic ALU

4-bit signed ALU written in structural VHDL for the Nexys A7 FPGA board. It adds, subtracts, multiplies (Booth's algorithm) and divides (non-restoring), and shows the 8-bit result on the 7-segment display.

| OperationSelect | Operation |
|---|---|
| `00` | A + B |
| `01` | A − B |
| `10` | A × B |
| `11` | A ÷ B (remainder in upper 4 bits, quotient in lower 4) |

## Structure

- `sources/` – design files (top level: `fixedPointALU.vhd`)
- `sim/` – testbenches for each module
- `constraints/` – Nexys A7 pin constraints

## Usage

Add `sources/` and the `.xdc` file to a Vivado project for the Nexys A7, set `fixedPointALU` as the top module, then generate the bitstream. To simulate, add the files in `sim/` and run any testbench.
