# Timing constraints for decoder_top core implementation.

# 100 MHz target clock (adjust period to sweep Fmax).
create_clock -name decoder_clk -period 10.000 [get_ports i_clk]

# i_rst_n is an asynchronous reset/control input.
set_false_path -from [get_ports i_rst_n]

# Small guard band for clock tree uncertainty during implementation.
set_clock_uncertainty 0.100 [get_clocks decoder_clk]

# Optional full sign RAM floorplan. Enable with ENABLE_RAM_S_PBLOCK=1 after
# validating site ranges for the selected part.
set enable_ram_s_pblock 0
if {[info exists ::env(ENABLE_RAM_S_PBLOCK)]} {
  set enable_ram_s_pblock $::env(ENABLE_RAM_S_PBLOCK)
}

if {$enable_ram_s_pblock} {
  set ram_s_cells [get_cells -quiet -hierarchical -filter {NAME =~ *u_ram_s*}]
  if {[llength $ram_s_cells] > 0} {
    create_pblock pblock_u_ram_s
    resize_pblock pblock_u_ram_s -add {SLICE_X0Y0:SLICE_X300Y149}
    resize_pblock pblock_u_ram_s -add {RAMB36_X0Y0:RAMB36_X29Y49}
    resize_pblock pblock_u_ram_s -add {RAMB18_X0Y0:RAMB18_X29Y99}
    add_cells_to_pblock pblock_u_ram_s $ram_s_cells
  }
}
