# Timing constraints for decoder_top core implementation.

# 100 MHz target clock (adjust period to sweep Fmax).
create_clock -name decoder_clk -period 10.000 [get_ports i_clk]

# i_rst_n is an asynchronous reset/control input.
set_false_path -from [get_ports i_rst_n]

# Small guard band for clock tree uncertainty during implementation.
set_clock_uncertainty 0.100 [get_clocks decoder_clk]

# ---------------------------------------------------------------------------
# SLR floorplan: constrain u_ram_s (sign storage BRAMs) to a single SLR.
#
# The critical path crosses an SLR boundary (~4 ns routing penalty) between
# the address-computation logic in SLR0 and the BRAM enables in SLR1.
# Confining u_ram_s to one SLR eliminates this penalty.
#
# KU115 (xcku115-flva2104) has 3 SLRs stacked vertically:
#   SLR0: Y = 0   .. ~149   (bottom)
#   SLR1: Y = 150 .. ~299   (middle)
#   SLR2: Y = 300 .. ~449   (top)
#
# The exact SLR boundaries vary by device.  After your first implementation
# run, check the actual boundaries with:
#   get_slr_ranges
# and adjust SLICE_Y0 / SLICE_Y1 below if needed.
# ---------------------------------------------------------------------------

# Pblock for u_ram_s: confine to SLR0 (bottom half of the device).
create_pblock pblock_u_ram_s
resize_pblock pblock_u_ram_s -add {SLICE_X0Y0:SLICE_X300Y149}
resize_pblock pblock_u_ram_s -add {RAMB36_X0Y0:RAMB36_X29Y49}
resize_pblock pblock_u_ram_s -add {RAMB18_X0Y0:RAMB18_X29Y99}
add_cells_to_pblock pblock_u_ram_s [get_cells -hierarchical -filter {NAME =~ *u_ram_s*}]
