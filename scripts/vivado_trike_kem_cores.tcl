set build_dir [lindex $argv 0]
if {$build_dir eq ""} {
  set build_dir "build/vivado/trike_kem_core"
}

set part [expr {[info exists ::env(VIVADO_PART)] ? $::env(VIVADO_PART) : "xc7k355tffg901-2L"}]
set top [expr {[info exists ::env(TRIKE_KEM_SYNTH_TOP)] ?
              $::env(TRIKE_KEM_SYNTH_TOP) : "trike_poly_inv_synth_top"}]
set threads [expr {[info exists ::env(VIVADO_THREADS)] ? $::env(VIVADO_THREADS) : "8"}]
set synth_directive [expr {[info exists ::env(VIVADO_SYNTH_DIRECTIVE)] ?
                          $::env(VIVADO_SYNTH_DIRECTIVE) : "Default"}]
set place_directive [expr {[info exists ::env(VIVADO_PLACE_DIRECTIVE)] ?
                          $::env(VIVADO_PLACE_DIRECTIVE) : "Explore"}]
set phys_opt_directive [expr {[info exists ::env(VIVADO_PHYS_OPT_DIRECTIVE)] ?
                             $::env(VIVADO_PHYS_OPT_DIRECTIVE) : "Explore"}]
set route_directive [expr {[info exists ::env(VIVADO_ROUTE_DIRECTIVE)] ?
                          $::env(VIVADO_ROUTE_DIRECTIVE) : "Explore"}]
set xdc_file [expr {[info exists ::env(VIVADO_XDC)] ?
                    $::env(VIVADO_XDC) : "constraints/trike_kem_core.xdc"}]

file mkdir $build_dir
set_param general.maxThreads $threads
puts "TRIKE KEM core top: $top"
puts "Vivado part: $part"
puts "Vivado threads: $threads"

create_project -in_memory -part $part trike_kem_core_vivado
auto_detect_xpm

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

if {$top eq "trike_poly_inv_synth_top"} {
  set rtl_files [list \
    rtl/reset_sync.sv \
    rtl/ram_bram.sv \
    rtl/trike_inv_schedule_pkg.sv \
    rtl/trike_poly_mul_core.sv \
    rtl/trike_poly_inv_core.sv \
    rtl/trike_poly_inv_synth_top.sv \
  ]
} elseif {$top eq "trike_pseudohash_synth_top"} {
  set rtl_files [list \
    rtl/reset_sync.sv \
    rtl/sm3_compress.sv \
    rtl/trike_sm3_service.sv \
    rtl/sm3_hash_stream.sv \
    rtl/hmac_sm3_64byte_key_stream.sv \
    rtl/trike_pseudohash512_stream.sv \
    rtl/trike_pseudohash_synth_top.sv \
  ]
} else {
  error "Unsupported TRIKE_KEM_SYNTH_TOP: $top"
}

run_step "read_verilog" {
  read_verilog -sv $rtl_files
}
set_property include_dirs [list rtl] [current_fileset]

run_step "read_xdc" {
  read_xdc $xdc_file
}

run_step "synth_design" {
  synth_design \
    -top $top \
    -part $part \
    -directive $synth_directive \
    -flatten_hierarchy rebuilt
}

report_utilization -hierarchical -file [file join $build_dir post_synth_utilization_hier.rpt]
report_utilization -file [file join $build_dir post_synth_utilization.rpt]
report_timing_summary -report_unconstrained \
  -file [file join $build_dir post_synth_timing_summary.rpt]
write_checkpoint -force [file join $build_dir post_synth.dcp]

run_step "opt_design" {
  opt_design
}

run_step "place_design" {
  place_design -directive $place_directive
}

run_step "phys_opt_design" {
  phys_opt_design -directive $phys_opt_directive
}

run_step "route_design" {
  route_design -directive $route_directive
}

report_utilization -hierarchical -file [file join $build_dir post_route_utilization_hier.rpt]
report_utilization -file [file join $build_dir post_route_utilization.rpt]
report_timing_summary -delay_type min_max -report_unconstrained \
  -file [file join $build_dir post_route_timing_summary.rpt]
report_timing -delay_type max -max_paths 20 -sort_by group \
  -file [file join $build_dir post_route_setup_paths.rpt]
report_timing -delay_type min -max_paths 20 -sort_by group \
  -file [file join $build_dir post_route_hold_paths.rpt]
report_clock_utilization -file [file join $build_dir post_route_clock_utilization.rpt]
report_methodology -file [file join $build_dir post_route_methodology.rpt]
report_cdc -file [file join $build_dir post_route_cdc.rpt]
report_drc -file [file join $build_dir post_route_drc.rpt]
report_messages -file [file join $build_dir post_route_messages.rpt]
write_checkpoint -force [file join $build_dir post_route.dcp]

puts "TRIKE KEM core implementation completed. Reports written to $build_dir"
