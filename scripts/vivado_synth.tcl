set build_dir [lindex $argv 0]
if {$build_dir eq ""} {
  set build_dir "build/vivado"
}

set part [expr {[info exists ::env(VIVADO_PART)] ? $::env(VIVADO_PART) : "xc7a35tcpg236-1"}]
set threads [expr {[info exists ::env(VIVADO_THREADS)] ? $::env(VIVADO_THREADS) : "8"}]
set synth_directive [expr {[info exists ::env(VIVADO_SYNTH_DIRECTIVE)] ? $::env(VIVADO_SYNTH_DIRECTIVE) : "Default"}]
set flatten_hierarchy [expr {[info exists ::env(VIVADO_FLATTEN_HIERARCHY)] ? $::env(VIVADO_FLATTEN_HIERARCHY) : "rebuilt"}]
set xdc_file [expr {[info exists ::env(VIVADO_XDC)] ? $::env(VIVADO_XDC) : "constraints/decoder_top.xdc"}]
set top "decoder_top"

file mkdir $build_dir
set_param general.maxThreads $threads
puts "Vivado synthesis threads: $threads"
create_project -in_memory -part $part min_sum_vivado

proc run_step {name command} {
  puts "== $name =="
  puts "Start: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
  if {[catch {uplevel 1 $command} result options]} {
    puts "FATAL: $name failed"
    puts $result
    puts [dict get $options -errorinfo]
    return -code error $result
  }
  puts "End: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
}

set rtl_files [list \
  rtl/bike_pkg.sv \
  rtl/ram_1r1w_sync_read.sv \
  rtl/sign_bit_pack.sv \
  rtl/decoder_top.sv \
  rtl/edge_message_pipe.sv \
  rtl/ram_i.sv \
  rtl/msg_signmag_to_tc.sv \
  rtl/msg_tc_to_signmag_sat.sv \
  rtl/decoder_ctrl.sv \
  rtl/ram_c.sv \
  rtl/ram_m.sv \
  rtl/ram_s.sv \
  rtl/ram_syndrome.sv \
  rtl/ram_t.sv \
  rtl/cnu_a.sv \
  rtl/cnu_b.sv \
  rtl/vnu.sv \
]

run_step "read_verilog" {
  read_verilog -sv $rtl_files
}
set_property include_dirs [list rtl] [current_fileset]

foreach init_file [glob -nocomplain rtl/generated/*.hex] {
  add_files -fileset sources_1 $init_file
}
set ram_i_hex_prefix [file normalize rtl/generated/ram_i]

if {[file exists $xdc_file]} {
  run_step "read_xdc" {
    read_xdc $xdc_file
  }
} else {
  puts "Vivado XDC not found: $xdc_file"
}

run_step "synth_design" {
  synth_design \
    -top $top \
    -part $part \
    -generic "RAM_I_HEX_PREFIX=$ram_i_hex_prefix" \
    -directive $synth_directive \
    -flatten_hierarchy $flatten_hierarchy
}

report_utilization -hierarchical -file [file join $build_dir utilization_hier.rpt]
report_utilization -file [file join $build_dir utilization.rpt]
report_timing_summary -file [file join $build_dir timing_summary.rpt]
report_messages -file [file join $build_dir messages.rpt]
write_checkpoint -force [file join $build_dir post_synth.dcp]
puts "Vivado synthesis completed. Reports written to $build_dir"
