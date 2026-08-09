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

set verilog_defines [list]

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
} elseif {$top eq "trike_encaps_synth_top"} {
  set rtl_files [list \
    rtl/reset_sync.sv \
    rtl/ram_bram.sv \
    rtl/sm3_compress.sv \
    rtl/trike_sm3_service.sv \
    rtl/sm3_hash_stream.sv \
    rtl/sm3_df_stream.sv \
    rtl/hmac_sm3_64byte_key_stream.sv \
    rtl/trike_sm3_drng_instantiate_stream.sv \
    rtl/trike_sm3_drng_generate_stream.sv \
    rtl/trike_sampler_candidate.sv \
    rtl/trike_fixed_weight_sampler.sv \
    rtl/trike_drng_weight_sampler.sv \
    rtl/trike_h4_error_sampler.sv \
    rtl/trike_parity_map_stream.sv \
    rtl/trike_h123_vectors.sv \
    rtl/trike_error_support_store.sv \
    rtl/trike_h4_error_vector.sv \
    rtl/trike_poly_mul_core.sv \
    rtl/trike_encaps_uv_core.sv \
    rtl/trike_pseudohash512_stream.sv \
    rtl/trike_encaps_core.sv \
    rtl/trike_encaps_synth_top.sv \
  ]
} elseif {$top eq "trike_keygen_synth_top"} {
  set rtl_files [list \
    rtl/reset_sync.sv \
    rtl/trike_inv_schedule_pkg.sv \
    rtl/ram_bram.sv \
    rtl/sm3_compress.sv \
    rtl/trike_sm3_service.sv \
    rtl/sm3_hash_stream.sv \
    rtl/sm3_df_stream.sv \
    rtl/trike_sm3_drng_instantiate_stream.sv \
    rtl/trike_sm3_drng_generate_stream.sv \
    rtl/trike_sampler_candidate.sv \
    rtl/trike_fixed_weight_sampler.sv \
    rtl/trike_drng_weight_sampler.sv \
    rtl/trike_weak_key_test.sv \
    rtl/trike_keygen_secret_sampler.sv \
    rtl/trike_parity_map_stream.sv \
    rtl/trike_h123_vectors.sv \
    rtl/trike_poly_mul_core.sv \
    rtl/trike_poly_inv_core.sv \
    rtl/trike_keygen_arith_core.sv \
    rtl/trike_keygen_core.sv \
    rtl/trike_keygen_synth_top.sv \
  ]
} elseif {$top eq "trike_decaps_synth_top"} {
  set verilog_defines [list \
    TRIKE_160_PARAMS \
    BIKE_PARALLEL_L=32 \
    BIKE_K_SIGN_K=4 \
    BIKE_MSG_BITS=5 \
    BIKE_COLS_PER_TILE=256 \
  ]
  set rtl_files [list \
    rtl/bike_pkg.sv \
    rtl/reset_sync.sv \
    rtl/decoder_profile_config.sv \
    rtl/ram_bram.sv \
    rtl/ram_i.sv \
    rtl/barrel_rotate.sv \
    rtl/edge_addr_gen.sv \
    rtl/tile_scheduler.sv \
    rtl/ram_m.sv \
    rtl/ram_s.sv \
    rtl/k_sign_update.sv \
    rtl/k_sign_reconstruct.sv \
    rtl/k_sign_overlap_scheduler.sv \
    rtl/ram_k_tile.sv \
    rtl/k_sign_selector.sv \
    rtl/ram_k_global.sv \
    rtl/ram_sign_delta.sv \
    rtl/ram_syndrome.sv \
    rtl/ram_accum.sv \
    rtl/ram_t.sv \
    rtl/msg_tc_to_signmag_sat.sv \
    rtl/vnu.sv \
    rtl/ram_decision.sv \
    rtl/cnu_a.sv \
    rtl/cnu_b.sv \
    rtl/msg_signmag_to_tc.sv \
    rtl/decoder_top.sv \
    rtl/trike_poly_mul_core.sv \
    rtl/trike_decaps_syndrome_core.sv \
    rtl/trike_fixed_support_sorter.sv \
    rtl/trike_decoder_load_adapter.sv \
    rtl/trike_decoder_error_vector.sv \
    rtl/trike_decoder_residual_check.sv \
    rtl/sm3_compress.sv \
    rtl/trike_sm3_service.sv \
    rtl/sm3_hash_stream.sv \
    rtl/sm3_df_stream.sv \
    rtl/hmac_sm3_64byte_key_stream.sv \
    rtl/trike_sm3_drng_instantiate_stream.sv \
    rtl/trike_sm3_drng_generate_stream.sv \
    rtl/trike_sampler_candidate.sv \
    rtl/trike_fixed_weight_sampler.sv \
    rtl/trike_drng_weight_sampler.sv \
    rtl/trike_h4_error_sampler.sv \
    rtl/trike_error_support_store.sv \
    rtl/trike_h4_error_vector.sv \
    rtl/kem_ct_compare_select.sv \
    rtl/trike_ct_verify_stream.sv \
    rtl/trike_pseudohash512_stream.sv \
    rtl/trike_decaps_message_recover.sv \
    rtl/trike_decaps_reencrypt_verify.sv \
    rtl/trike_decaps_kdf.sv \
    rtl/trike_decaps_postprocess_core.sv \
    rtl/trike_decaps_pipeline_core.sv \
    rtl/trike_decaps_synth_top.sv \
  ]
} else {
  error "Unsupported TRIKE_KEM_SYNTH_TOP: $top"
}

run_step "read_verilog" {
  if {[llength $verilog_defines] > 0} {
    read_verilog -sv -define $verilog_defines $rtl_files
  } else {
    read_verilog -sv $rtl_files
  }
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
set core_registers [all_registers -clock [get_clocks core_clk]]
report_timing -from $core_registers -to $core_registers -delay_type max \
  -max_paths 20 -sort_by slack \
  -file [file join $build_dir post_route_internal_setup_paths.rpt]
report_high_fanout_nets -timing -load_types -max_nets 30 \
  -file [file join $build_dir post_route_high_fanout.rpt]
report_clock_utilization -file [file join $build_dir post_route_clock_utilization.rpt]
report_methodology -file [file join $build_dir post_route_methodology.rpt]
report_cdc -file [file join $build_dir post_route_cdc.rpt]
report_drc -file [file join $build_dir post_route_drc.rpt]
report_messages -file [file join $build_dir post_route_messages.rpt]
write_checkpoint -force [file join $build_dir post_route.dcp]

puts "TRIKE KEM core implementation completed. Reports written to $build_dir"
