set build_dir [lindex $argv 0]
if {$build_dir eq ""} {
  set build_dir "build/vivado"
}

set part [expr {[info exists ::env(VIVADO_PART)] ? $::env(VIVADO_PART) : "xc7a35tcpg236-1"}]
set threads [expr {[info exists ::env(VIVADO_THREADS)] ? $::env(VIVADO_THREADS) : "8"}]
set synth_directive [expr {[info exists ::env(VIVADO_SYNTH_DIRECTIVE)] ? $::env(VIVADO_SYNTH_DIRECTIVE) : "Default"}]
set flatten_hierarchy [expr {[info exists ::env(VIVADO_FLATTEN_HIERARCHY)] ? $::env(VIVADO_FLATTEN_HIERARCHY) : "rebuilt"}]
set xdc_file [expr {[info exists ::env(VIVADO_XDC)] ? $::env(VIVADO_XDC) : "constraints/decoder_top.xdc"}]
set parallel_l [expr {[info exists ::env(BIKE_PARALLEL_L)] ? $::env(BIKE_PARALLEL_L) : "8"}]
set c_tile [expr {[info exists ::env(BIKE_C_TILE)] ? $::env(BIKE_C_TILE) : "288"}]
set param_define [expr {[info exists ::env(BIKE_PARAM_DEFINE)] ? $::env(BIKE_PARAM_DEFINE) : "BIKE_128_PARAMS"}]
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
  rtl/reset_sync.sv \
  rtl/h_matrix_mem.sv \
  rtl/edge_addr_gen.sv \
  rtl/tile_scheduler.sv \
  rtl/check_state_ram.sv \
  rtl/msg_sign_ram.sv \
  rtl/tile_accum_ram.sv \
  rtl/c2v_cache_ram.sv \
  rtl/vnu_update.sv \
  rtl/decision_ram.sv \
  rtl/decoder_top.sv \
]

run_step "read_verilog" {
  set define_args [list $param_define "BIKE_PARALLEL_L=$parallel_l" "BIKE_C_TILE=$c_tile"]
  puts "Vivado defines: $define_args"
  read_verilog -sv -define $define_args $rtl_files
}
set_property include_dirs [list rtl] [current_fileset]

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
    -directive $synth_directive \
    -flatten_hierarchy $flatten_hierarchy
}

report_utilization -hierarchical -file [file join $build_dir utilization_hier.rpt]
report_utilization -file [file join $build_dir utilization.rpt]
report_methodology -file [file join $build_dir methodology.rpt]
report_cdc -file [file join $build_dir cdc.rpt]
report_timing_summary -file [file join $build_dir timing_summary.rpt]
report_messages -file [file join $build_dir messages.rpt]
write_checkpoint -force [file join $build_dir post_synth.dcp]
puts "Vivado synthesis completed. Reports written to $build_dir"
