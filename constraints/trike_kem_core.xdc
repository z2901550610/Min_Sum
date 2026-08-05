# Timing constraints for standalone TRIKE KEM common-core implementation.

set core_clk_port [get_ports i_clk]
set core_rst_port [get_ports i_rst_n]

create_clock -name core_clk -period 10.000 $core_clk_port
set_clock_uncertainty 0.100 [get_clocks core_clk]

# The wrapper synchronizes reset release into core_clk.
set_false_path -from $core_rst_port

# Virtual board-boundary delays keep streaming I/O paths constrained without
# assigning package pins to this implementation-only core wrapper. XDC files
# support collection filters, while general Tcl flow-control commands are not
# accepted by the project-mode XDC reader.
set_input_delay -clock core_clk -max 2.000 \
  [get_ports -filter {DIRECTION == IN && NAME != i_clk && NAME != i_rst_n}]
set_input_delay -clock core_clk -min 0.000 \
  [get_ports -filter {DIRECTION == IN && NAME != i_clk && NAME != i_rst_n}]
set_output_delay -clock core_clk -max 2.000 [get_ports -filter {DIRECTION == OUT}]
set_output_delay -clock core_clk -min 0.000 [get_ports -filter {DIRECTION == OUT}]
