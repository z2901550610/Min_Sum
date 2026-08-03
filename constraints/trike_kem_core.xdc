# Timing constraints for standalone TRIKE KEM common-core implementation.

set core_clk_port [get_ports i_clk]
set core_rst_port [get_ports i_rst_n]

create_clock -name core_clk -period 10.000 $core_clk_port
set_clock_uncertainty 0.100 [get_clocks core_clk]

# The wrapper synchronizes reset release into core_clk.
set_false_path -from $core_rst_port

# Virtual board-boundary delays keep streaming I/O paths constrained without
# assigning package pins to this implementation-only core wrapper.
set core_data_inputs [remove_from_collection [all_inputs] [get_ports {i_clk i_rst_n}]]
if {[llength $core_data_inputs] > 0} {
  set_input_delay -clock core_clk 2.000 $core_data_inputs
}

set core_data_outputs [all_outputs]
if {[llength $core_data_outputs] > 0} {
  set_output_delay -clock core_clk 2.000 $core_data_outputs
}
