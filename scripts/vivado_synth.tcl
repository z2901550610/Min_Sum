set build_dir [lindex $argv 0]
if {$build_dir eq ""} {
  set build_dir "build/vivado"
}

set part [expr {[info exists ::env(VIVADO_PART)] ? $::env(VIVADO_PART) : "xc7a35tcpg236-1"}]
set top "decoder_top"

file mkdir $build_dir
create_project -in_memory -part $part min_sum_vivado
set_property verilog_define {BIKE_L1_PARAMS} [current_fileset]

set rtl_files [list \
  rtl/bike_pkg.sv \
  rtl/ram_i.sv \
  rtl/h_shift.sv \
  rtl/msg_signmag_to_tc.sv \
  rtl/msg_tc_to_signmag_sat.sv \
  rtl/decoder_ctrl.sv \
  rtl/ram_c.sv \
  rtl/ram_m.sv \
  rtl/ram_s.sv \
  rtl/ram_t.sv \
  rtl/cnu_a.sv \
  rtl/cnu_b.sv \
  rtl/vnu.sv \
  rtl/decoder_top.sv \
]

read_verilog -sv -define BIKE_L1_PARAMS $rtl_files
set_property include_dirs [list rtl] [current_fileset]

foreach init_file [glob -nocomplain rtl/generated/*.hex] {
  add_files -fileset sources_1 $init_file
}

synth_design -top $top -part $part

report_utilization -file [file join $build_dir utilization.rpt]
report_timing_summary -file [file join $build_dir timing_summary.rpt]
write_checkpoint -force [file join $build_dir post_synth.dcp]
