# Timing constraints for decoder_top core implementation.

# XDC is declarative; optional Tcl flow control belongs in the build script.
set decoder_clk_port [get_ports i_clk]
set decoder_rst_port [get_ports i_rst_n]

# 100 MHz target clock (adjust period to sweep Fmax).
create_clock -name decoder_clk -period 10.000 $decoder_clk_port

# i_rst_n is an asynchronous reset/control input.
set_false_path -from $decoder_rst_port

# Small guard band for clock tree uncertainty during implementation.
set_clock_uncertainty 0.100 [get_clocks decoder_clk]
