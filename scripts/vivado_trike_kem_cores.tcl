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
set run_id [expr {[info exists ::env(VIVADO_RUN_ID)] ?
                  $::env(VIVADO_RUN_ID) : [file tail [file normalize $build_dir]]}]

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

proc command_output {args} {
  if {[catch {exec {*}$args} result]} {
    return "unavailable: [string trim $result]"
  }
  return [string trim $result]
}

set verilog_defines [list]

proc read_rtl_filelist {path repo_root} {
  if {![file exists $path]} {
    error "RTL filelist not found: $path"
  }
  set channel [open $path r]
  set rtl_files [list]
  while {[gets $channel line] >= 0} {
    regsub {#.*$} $line "" line
    set line [string trim $line]
    if {$line ne ""} {
      lappend rtl_files [file join $repo_root $line]
    }
  }
  close $channel
  return $rtl_files
}

set repo_root [file normalize [file join [file dirname [info script]] ..]]
set filelist_by_top [dict create \
  trike_poly_inv_synth_top filelists/trike_poly_inv.f \
  trike_pseudohash_synth_top filelists/trike_pseudohash.f \
  trike_encaps_synth_top filelists/trike_encaps.f \
  trike_keygen_synth_top filelists/trike_keygen.f \
  trike_decaps_synth_top filelists/trike_decaps.f \
  trike_decaps_runtime_synth_top filelists/trike_decaps.f \
]

if {![dict exists $filelist_by_top $top]} {
  error "Unsupported TRIKE_KEM_SYNTH_TOP: $top"
}
set rtl_filelist [file join $repo_root [dict get $filelist_by_top $top]]
set rtl_files [read_rtl_filelist $rtl_filelist $repo_root]
puts "RTL filelist: $rtl_filelist"

if {($top eq "trike_decaps_synth_top") ||
    ($top eq "trike_decaps_runtime_synth_top")} {
  set verilog_defines [list \
    TRIKE_UNIFIED_PARAMS \
    BIKE_PARALLEL_L=32 \
    BIKE_K_SIGN_K=4 \
    BIKE_MSG_BITS=5 \
    BIKE_COLS_PER_TILE=256 \
  ]
}

set source_revision [command_output git -C $repo_root rev-parse HEAD]
set source_status [command_output git -C $repo_root status --short]
set dirty_tree [expr {$source_status eq "" ? "false" : "true"}]
set provenance_file [file join $build_dir run_provenance.txt]
set provenance_channel [open $provenance_file w]
puts $provenance_channel "format_version=1"
puts $provenance_channel "run_id=$run_id"
puts $provenance_channel "generated_at=[clock format [clock seconds] -format {%Y-%m-%dT%H:%M:%S%z}]"
puts $provenance_channel "vivado_version=[version -short]"
puts $provenance_channel "top=$top"
puts $provenance_channel "part=$part"
puts $provenance_channel "xdc=[file normalize $xdc_file]"
puts $provenance_channel "rtl_filelist=[file normalize $rtl_filelist]"
puts $provenance_channel "verilog_defines=[join $verilog_defines { }]"
puts $provenance_channel "synth_directive=$synth_directive"
puts $provenance_channel "place_directive=$place_directive"
puts $provenance_channel "phys_opt_directive=$phys_opt_directive"
puts $provenance_channel "route_directive=$route_directive"
puts $provenance_channel "source_revision=$source_revision"
puts $provenance_channel "dirty_tree=$dirty_tree"
puts $provenance_channel "source_status_begin"
puts $provenance_channel $source_status
puts $provenance_channel "source_status_end"
puts $provenance_channel "rtl_files_begin"
foreach rtl_file $rtl_files {
  puts $provenance_channel [file normalize $rtl_file]
}
puts $provenance_channel "rtl_files_end"
close $provenance_channel
puts "Run provenance: $provenance_file"

run_step "read_verilog" {
  if {[llength $verilog_defines] > 0} {
    read_verilog -sv -define $verilog_defines $rtl_files
  } else {
    read_verilog -sv $rtl_files
  }
}
set_property include_dirs [list [file join $repo_root rtl]] [current_fileset]

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
set core_register_outputs [all_registers -clock [get_clocks core_clk] -output_pins]
set core_register_data_pins [all_registers -clock [get_clocks core_clk] -data_pins]
report_timing -from $core_register_outputs -to $core_register_data_pins -delay_type max \
  -max_paths 20 -sort_by slack \
  -file [file join $build_dir post_route_internal_data_setup_paths.rpt]
report_high_fanout_nets -timing -load_types -max_nets 30 \
  -file [file join $build_dir post_route_high_fanout.rpt]
report_clock_utilization -file [file join $build_dir post_route_clock_utilization.rpt]
report_methodology -file [file join $build_dir post_route_methodology.rpt]
report_cdc -file [file join $build_dir post_route_cdc.rpt]
report_drc -file [file join $build_dir post_route_drc.rpt]
report_messages -file [file join $build_dir post_route_messages.rpt]
write_checkpoint -force [file join $build_dir post_route.dcp]

puts "TRIKE KEM core implementation completed. Reports written to $build_dir"
