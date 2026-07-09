# Timing constraints for decoder_top core implementation.

# 100 MHz target clock (adjust period to sweep Fmax).
create_clock -name decoder_clk -period 10.000 [get_ports i_clk]

# i_rst_n is an asynchronous reset/control input.
set_false_path -from [get_ports i_rst_n]

# Small guard band for clock tree uncertainty during implementation.
set_clock_uncertainty 0.100 [get_clocks decoder_clk]
