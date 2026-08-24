-include config/local.mk

VERILATOR ?= ./scripts/verilator_quiet.py
REAL_VERILATOR ?= verilator
VERILATOR_LOG_DIR ?= build/logs/verilator
BIKE_PARALLEL_L ?= 32
BIKE_TOY_PARALLEL_L ?= 8
BIKE_SYNTH_PARAM ?=
BIKE_SYNTH_PARALLEL_L ?= 32
BIKE_SYNTH_COLS_PER_TILE ?=
VERILATOR_WAIVER_FILE ?= config/verilator_waivers.vlt
VERILATOR_FLAGS ?= --binary --sv -DBIKE_TOY_PARAMS -DBIKE_PARALLEL_L=$(BIKE_TOY_PARALLEL_L) -DBIKE_SIM_DEBUG -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE)
VERILATOR_LINT_FLAGS ?= --lint-only --sv -Wall --quiet -I./tb -I./rtl $(VERILATOR_WAIVER_FILE)
SIM ?= ./scripts/run_quiet.py
VIVADO ?= vivado
YOSYS ?= yosys
SLANG ?= slang
SBY ?= sby
Z3 ?= z3
SLANG_FLAGS ?= --std 1800-2017 --single-unit --lint-only --quiet -Werror -I tb -I rtl
FORMAL_BUILD_DIR ?= build/formal
VIVADO_PART ?= xc7k355tffg901-2L
VIVADO_RUN_TAG ?= $(shell date +%Y%m%d-%H%M%S)
VIVADO_BUILD_DIR ?= build/vivado/$(VIVADO_RUN_TAG)
CC ?= cc
CFLAGS ?= -O3 -std=c11 -Wall -Wextra -Wpedantic -pthread
MODEL_BUILD_DIR ?= build/model
MIN_SUM_MODEL ?= $(MODEL_BUILD_DIR)/min_sum_model
AWS_BIKE_KEM_DIR ?= build/upstream/aws-bike-kem
AWS_BIKE_KEM_URL ?= https://github.com/awslabs/bike-kem.git
AWS_FIPS202_C := $(AWS_BIKE_KEM_DIR)/src/third_party_src/fips202.c
AWS_FIPS202_INCLUDE := $(AWS_BIKE_KEM_DIR)/src/third_party_src
TRIKE_KEM_BUILD_DIR ?= build/software/trike_kem
TRIKE_KEM_SELFTEST ?= $(TRIKE_KEM_BUILD_DIR)/trike_kem_selftest
TRIKE_KEM_SOURCES := software/trike_kem/trike_kem.c software/trike_kem/trike_ms_quant.c software/trike_kem/selftest.c
TRIKE_KEM_TEST_PROFILES ?= trike160 trike256 trike384 trike512
TRIKE_REFERENCE_SOURCE_ROOT ?= external/trike-reference
TRIKE_REFERENCE_BUILD_DIR ?= build/software/trike_reference
TRIKE_REFERENCE_PARAM_SETS ?= TRIKE-2 TRIKE-5 TRIKE-7 TRIKE-9
TRIKE_POLY_REFERENCE_KAT ?= $(TRIKE_REFERENCE_SOURCE_ROOT)/Test_Vectors/KAT_KEM_TRIKE-2.txt
TRIKE_POLY_REFERENCE_FIXTURE ?= tb/generated/trike_poly_mul_reference_case.svh
TRIKE_POLY_INV_REFERENCE_FIXTURE ?= tb/generated/trike_poly_inv_reference_case.svh
TRIKE_MINSUM_POLY_INV_FIXTURE ?= tb/generated/trike_poly_inv_minsum_case.svh
TRIKE_MINSUM_PROFILE ?= trike160
TRIKE_MINSUM_PROFILES ?= trike160 trike256 trike384 trike512
TRIKE_RUNTIME_REFERENCE_DEFINES ?=
TRIKE_RUNTIME_REFERENCE_CFLAGS ?= -CFLAGS -O3
TRIKE_MINSUM_KEM_CASE ?= build/generated/trike_minsum_kem/$(TRIKE_MINSUM_PROFILE)_seed1.json
TRIKE_MINSUM_DECAPS_MESSAGE_FIXTURE ?= tb/generated/trike_decaps_message_minsum_case.svh
TRIKE_MINSUM_RUNTIME_DECAPS_FIXTURE ?= tb/generated/trike_decaps_runtime_minsum_case.svh
TRIKE_ENCAPS_REFERENCE_FIXTURE ?= tb/generated/trike_encaps_reference_case.svh
TRIKE_KEYGEN_REFERENCE_FIXTURE ?= tb/generated/trike_keygen_reference_case.svh
TRIKE_DECAPS_SYNDROME_REFERENCE_FIXTURE ?= tb/generated/trike_decaps_syndrome_reference_case.svh
TRIKE_KEM_SYNTH_TOP ?= trike_poly_inv_synth_top
TRIKE_KEM_REFERENCE_TARGETS := \
	test-trike-reference-kat \
	test-software-trike-kem \
	test-trike-poly-reference \
	test-trike-poly-inv-reference \
	test-trike-poly-inv-minsum-reference \
	test-trike-weak-key-reference \
	test-trike-keygen-secret-reference \
	test-trike-keygen-arith-reference \
	test-trike-keygen-core-reference \
	test-trike-keygen-synth-reference \
	test-trike-encaps-components-reference \
	test-trike-encaps-hash-reference \
	test-trike-encaps-core-reference \
	test-trike-encaps-synth-reference \
	test-trike-error-store-reference \
	test-trike-h4-vector-reference \
	test-trike-decaps-syndrome-reference \
	test-trike-decaps-message-reference \
	test-trike-decaps-verify-reference \
	test-trike-decaps-kdf-reference \
	test-trike-decaps-postprocess-reference \
	test-trike-decoder-residual-reference \
	test-trike-decaps-pipeline-reference \
	test-trike-decaps-synth-reference
VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_FORMAT_FLAGS ?= --port_declarations_alignment=align --module_net_variable_alignment=align --formal_parameters_alignment=align
VERIBLE_LINT ?= verible-verilog-lint
VERIBLE_LINT_FLAGS ?= --rules_config .rules.verible_lint
SV_DECL_FORMAT ?= python3 scripts/format_sv_decls.py
export REAL_VERILATOR
export VERILATOR_LOG_DIR
export BIKE_PARALLEL_L

TOY_CASE_SVH := tb/generated/bike_toy_case.svh
read_filelist = $(shell sed -e '/^[[:space:]]*\#/d' -e '/^[[:space:]]*$$/d' $(1))
RTL := $(call read_filelist,filelists/decoder.f)
RTL_PKG := rtl/bike_pkg.sv
RTL_CORE := $(filter-out $(RTL_PKG),$(RTL))
SM3_COMPRESS_RTL := rtl/sm3_compress.sv rtl/trike_sm3_service.sv
TRIKE_POLY_INV_RTL := $(call read_filelist,filelists/trike_poly_inv.f)
TRIKE_PSEUDOHASH_RTL := $(call read_filelist,filelists/trike_pseudohash.f)
TRIKE_ENCAPS_RTL := $(call read_filelist,filelists/trike_encaps.f)
TRIKE_KEYGEN_RTL := $(call read_filelist,filelists/trike_keygen.f)
TRIKE_DECAPS_SYNTH_RTL := $(call read_filelist,filelists/trike_decaps.f)
TRIKE_DECAPS_RTL := $(filter-out rtl/trike_decaps_synth_top.sv rtl/trike_decaps_runtime_synth_top.sv,$(TRIKE_DECAPS_SYNTH_RTL))
TRIKE_KEM_ASIC_RTL := $(call read_filelist,filelists/trike_kem_asic.f)
MAINTAINED_SV := $(sort $(wildcard rtl/*.sv) $(wildcard tb/*.sv) $(wildcard formal/*.sv))
BIKE_RANDOM_BASE_SEED ?= 1
BIKE_RANDOM_TRIALS ?= 1
BIKE_RANDOM_PARAM_SET ?= bike128
BIKE_RANDOM_ERROR_COUNT ?=
BIKE_RANDOM_PARALLEL_L ?= $(BIKE_PARALLEL_L)
BIKE_RANDOM_COLS_PER_TILE ?= 256
BIKE_RANDOM_TIMEOUT_CYCLES ?= 800000
BIKE_RANDOM_ERROR_ARG := $(if $(BIKE_RANDOM_ERROR_COUNT),--error-count $(BIKE_RANDOM_ERROR_COUNT),)
BIKE_UNIFIED_RANDOM_PARAM_SETS ?= bike128 bike192 bike256
BIKE_UNIFIED_RANDOM_COLS_PER_TILE ?= 576
BIKE_UNIFIED_RANDOM_TIMEOUT_CYCLES ?= 40000000
TRIKE_UNIFIED_KSIGN_PARALLEL_L ?= 32
TRIKE_UNIFIED_KSIGN_COLS_PER_TILE ?= 1152
TRIKE_UNIFIED_KSIGN_K ?= 4
TRIKE_UNIFIED_KSIGN_PARAM_SETS ?= trike160 trike256 trike384 trike512
TRIKE_UNIFIED_KSIGN_TIMEOUT_CYCLES ?= 40000000
CI_SMOKE_SEED ?= 1
CI_NIGHTLY_TRIALS ?= 4

.PHONY: all sim test test-unit test-kem-unit test-trike-weak-key-reference test-trike-keygen-secret-reference test-trike-keygen-arith-reference test-trike-keygen-core-reference test-trike-keygen-synth-reference test-trike-poly-reference test-trike-poly-inv-reference test-trike-encaps-components-reference test-trike-encaps-hash-reference test-trike-encaps-core-reference test-trike-decaps-syndrome-reference test-trike-error-store-reference test-trike-h4-vector-reference check-trike-sm3-sharing test-integration test-bike-random test-bike-unified-random test-trike-unified-ksign-random model-min-sum run-model-min-sum sweep-min-sum optimum-min-sum campaign-min-sum confirm-min-sum check-model-rtl check-model-rtl-bike128 software-trike-kem test-software-trike-kem test-trike-reference-kat check-local-tools format-rtl check-format-rtl lint-rtl lint-slang check-rtl formal formal-ct-select formal-ct-control verify-rtl vivado-synth vivado-synth-trike-unified-ksign vivado-impl-trike-kem-core vivado-impl-trike-poly-inv vivado-impl-trike-pseudohash vivado-impl-trike-encaps vivado-impl-trike-keygen vivado-impl-trike-decaps vivado-impl-trike-decaps-runtime vivado-impl-trike-kem-cores FORCE
.PHONY: test-trike-poly-inv-minsum-reference gen-trike-minsum-kem-case test-trike-pseudohash-runtime test-trike-h4-runtime test-trike-ct-verify-runtime test-trike-decaps-postprocess-runtime test-trike-decaps-input-loader test-trike-decaps-input-store test-trike-decaps-syndrome-runtime test-trike-decaps-syndrome-store-core test-trike-decaps-input-syndrome-core test-trike-decaps-support-prefetch test-trike-decaps-input-decoder-load-core test-trike-decaps-decoder-postcheck-core test-trike-fixed-support-sorter-runtime test-trike-decoder-load-adapter-runtime test-trike-decaps-message-reference test-trike-decaps-verify-reference test-trike-decaps-kdf-reference test-trike-decoder-residual-reference test-trike-decaps-pipeline-reference test-trike-decaps-synth-reference test-trike-decaps-runtime-synth-reference test-trike-decaps-runtime-four-profile-reference test-trike-kem-operation-control formal-trike-kem-operation-control
.PHONY: tool-versions check-tool-versions check-filelists check-records check-trike-reference-data lint-verilator formal-fast formal-nightly formal-ct-control-extended ci-fast ci-smoke ci-nightly ci-kem-reference

all: test

$(TOY_CASE_SVH): FORCE scripts/gen_toy_case_fixture.py scripts/run_bike_random.py scripts/qc_matrix_data.py
	@python3 scripts/gen_toy_case_fixture.py --output $@

test: test-unit test-integration

test-unit: test-kem-unit
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_reset_sync rtl/reset_sync.sv tb/tb_reset_sync.sv
	@$(SIM) ./obj_dir/Vtb_reset_sync +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_msg_codec rtl/bike_pkg.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv tb/tb_msg_codec.sv
	@$(SIM) ./obj_dir/Vtb_msg_codec +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_tile_scheduler rtl/bike_pkg.sv rtl/tile_scheduler.sv tb/tb_tile_scheduler.sv
	@$(SIM) ./obj_dir/Vtb_tile_scheduler +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_edge_addr_gen rtl/bike_pkg.sv rtl/edge_addr_gen.sv tb/tb_edge_addr_gen.sv
	@$(SIM) ./obj_dir/Vtb_edge_addr_gen +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_i rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_i.sv tb/tb_ram_i.sv
	@$(SIM) ./obj_dir/Vtb_ram_i +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_m rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_m.sv tb/tb_ram_m.sv
	@$(SIM) ./obj_dir/Vtb_ram_m +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_sign_delta rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_sign_delta.sv tb/tb_ram_sign_delta.sv
	@$(SIM) ./obj_dir/Vtb_ram_sign_delta +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_k_sign_update rtl/bike_pkg.sv rtl/ram_bram.sv rtl/barrel_rotate.sv rtl/k_sign_update.sv rtl/k_sign_reconstruct.sv rtl/ram_k_tile.sv rtl/k_sign_selector.sv rtl/ram_k_global.sv tb/tb_k_sign_update.sv
	@$(SIM) ./obj_dir/Vtb_k_sign_update +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_accum rtl/bike_pkg.sv rtl/barrel_rotate.sv rtl/ram_accum.sv tb/tb_ram_accum.sv
	@$(SIM) ./obj_dir/Vtb_ram_accum +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_t rtl/bike_pkg.sv rtl/barrel_rotate.sv rtl/ram_bram.sv rtl/ram_t.sv tb/tb_ram_t.sv
	@$(SIM) ./obj_dir/Vtb_ram_t +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_decision rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_decision.sv tb/tb_ram_decision.sv
	@$(SIM) ./obj_dir/Vtb_ram_decision +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_syndrome rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_syndrome.sv tb/tb_ram_syndrome.sv
	@$(SIM) ./obj_dir/Vtb_ram_syndrome +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_a rtl/bike_pkg.sv rtl/cnu_a.sv tb/tb_cnu_a.sv
	@$(SIM) ./obj_dir/Vtb_cnu_a +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_b rtl/bike_pkg.sv rtl/cnu_b.sv tb/tb_cnu_b.sv
	@$(SIM) ./obj_dir/Vtb_cnu_b +verilator+quiet

test-kem-unit:
	@$(MAKE) test-trike-pseudohash-runtime
	@$(MAKE) test-trike-h4-runtime
	@$(MAKE) test-trike-ct-verify-runtime
	@$(MAKE) test-trike-decaps-postprocess-runtime
	@$(MAKE) test-trike-decaps-input-loader
	@$(MAKE) test-trike-decaps-input-store
	@$(MAKE) test-trike-decaps-syndrome-runtime
	@$(MAKE) test-trike-decaps-syndrome-store-core
	@$(MAKE) test-trike-decaps-input-syndrome-core
	@$(MAKE) test-trike-decaps-support-prefetch
	@$(MAKE) test-trike-decaps-input-decoder-load-core
	@$(MAKE) test-trike-decaps-decoder-postcheck-core
	@$(MAKE) test-trike-fixed-support-sorter-runtime
	@$(MAKE) test-trike-decoder-load-adapter-runtime
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_sm3_compress $(SM3_COMPRESS_RTL) tb/tb_sm3_compress.sv
	@$(SIM) ./obj_dir/Vtb_sm3_compress +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_sm3_hash_stream $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv tb/tb_sm3_hash_stream.sv
	@$(SIM) ./obj_dir/Vtb_sm3_hash_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_hmac_sm3_64byte_key_stream $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv tb/tb_hmac_sm3_64byte_key_stream.sv
	@$(SIM) ./obj_dir/Vtb_hmac_sm3_64byte_key_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_sm3_df_stream $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv tb/tb_sm3_df_stream.sv
	@$(SIM) ./obj_dir/Vtb_sm3_df_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_sm3_drng_instantiate_stream $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv tb/tb_trike_sm3_drng_instantiate_stream.sv
	@$(SIM) ./obj_dir/Vtb_trike_sm3_drng_instantiate_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_sm3_drng_generate_stream $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/trike_sm3_drng_generate_stream.sv tb/tb_trike_sm3_drng_generate_stream.sv
	@$(SIM) ./obj_dir/Vtb_trike_sm3_drng_generate_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_pseudohash512_stream $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_pseudohash512_stream.sv tb/tb_trike_pseudohash512_stream.sv
	@$(SIM) ./obj_dir/Vtb_trike_pseudohash512_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_pseudohash_synth_top rtl/reset_sync.sv $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_pseudohash512_stream.sv rtl/trike_pseudohash_synth_top.sv tb/tb_trike_pseudohash_synth_top.sv
	@$(SIM) ./obj_dir/Vtb_trike_pseudohash_synth_top +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_parity_map_stream rtl/trike_parity_map_stream.sv tb/tb_trike_parity_map_stream.sv
	@$(SIM) ./obj_dir/Vtb_trike_parity_map_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_sampler_candidate rtl/trike_sampler_candidate.sv tb/tb_trike_sampler_candidate.sv
	@$(SIM) ./obj_dir/Vtb_trike_sampler_candidate +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_fixed_weight_sampler rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv tb/tb_trike_fixed_weight_sampler.sv
	@$(SIM) ./obj_dir/Vtb_trike_fixed_weight_sampler +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_weak_key_test rtl/ram_bram.sv rtl/trike_weak_key_test.sv tb/tb_trike_weak_key_test.sv
	@$(SIM) ./obj_dir/Vtb_trike_weak_key_test +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_drng_weight_sampler $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv tb/tb_trike_drng_weight_sampler.sv
	@$(SIM) ./obj_dir/Vtb_trike_drng_weight_sampler +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_h4_error_sampler $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv tb/tb_trike_h4_error_sampler.sv
	@$(SIM) ./obj_dir/Vtb_trike_h4_error_sampler +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_h123_vectors $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_parity_map_stream.sv rtl/trike_h123_vectors.sv tb/tb_trike_h123_vectors.sv
	@$(SIM) ./obj_dir/Vtb_trike_h123_vectors +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_poly_mul_core rtl/ram_bram.sv rtl/trike_poly_mul_core.sv tb/tb_trike_poly_mul_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_poly_mul_core +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_encaps_uv_core rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_encaps_uv_core.sv tb/tb_trike_encaps_uv_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_uv_core +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_poly_inv_core rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv tb/tb_trike_poly_inv_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_poly_inv_core +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_keygen_arith_core rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv tb/tb_trike_keygen_arith_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_arith_core +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_keccak_f1600 rtl/keccak_f1600.sv tb/tb_keccak_f1600.sv
	@$(SIM) ./obj_dir/Vtb_keccak_f1600 +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_shake256_stream rtl/keccak_f1600.sv rtl/shake256_stream.sv tb/tb_shake256_stream.sv
	@$(SIM) ./obj_dir/Vtb_shake256_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_kem_ct_compare_select rtl/kem_ct_compare_select.sv tb/tb_kem_ct_compare_select.sv
	@$(SIM) ./obj_dir/Vtb_kem_ct_compare_select +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_ct_verify_stream rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv tb/tb_trike_ct_verify_stream.sv
	@$(SIM) ./obj_dir/Vtb_trike_ct_verify_stream +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decoder_load_adapter rtl/trike_fixed_support_sorter.sv rtl/trike_decoder_load_adapter.sv tb/tb_trike_decoder_load_adapter.sv
	@$(SIM) ./obj_dir/Vtb_trike_decoder_load_adapter +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_fixed_support_sorter rtl/trike_fixed_support_sorter.sv tb/tb_trike_fixed_support_sorter.sv
	@$(SIM) ./obj_dir/Vtb_trike_fixed_support_sorter +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decoder_error_vector rtl/ram_bram.sv rtl/trike_decoder_error_vector.sv tb/tb_trike_decoder_error_vector.sv
	@$(SIM) ./obj_dir/Vtb_trike_decoder_error_vector +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decoder_residual_check rtl/ram_bram.sv rtl/trike_decoder_residual_check.sv tb/tb_trike_decoder_residual_check.sv
	@$(SIM) ./obj_dir/Vtb_trike_decoder_residual_check +verilator+quiet

$(TRIKE_KEYGEN_REFERENCE_FIXTURE): scripts/gen_trike_keygen_fixture.py scripts/gen_trike_encaps_fixture.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_keygen_fixture.py \
		--kat "$(TRIKE_POLY_REFERENCE_KAT)" \
		--output "$@" \
		--candidate-count 16

test-trike-weak-key-reference: $(TRIKE_KEYGEN_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_weak_key_reference rtl/ram_bram.sv rtl/trike_weak_key_test.sv tb/tb_trike_weak_key_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_weak_key_reference +verilator+quiet

test-trike-keygen-secret-reference: $(TRIKE_KEYGEN_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_keygen_secret_sampler_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/ram_bram.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv tb/tb_trike_keygen_secret_sampler_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_secret_sampler_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_keygen_secret_sampler_schedule $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/ram_bram.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv tb/tb_trike_keygen_secret_sampler_schedule.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_secret_sampler_schedule +verilator+quiet

test-trike-keygen-arith-reference: $(TRIKE_KEYGEN_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_keygen_arith_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv tb/tb_trike_keygen_arith_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_arith_reference +verilator+quiet

test-trike-keygen-core-reference: $(TRIKE_KEYGEN_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_keygen_core_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv rtl/trike_parity_map_stream.sv rtl/trike_h123_vectors.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv rtl/trike_keygen_core.sv tb/tb_trike_keygen_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_core_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GALT_CASE=1 --top-module tb_trike_keygen_core_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv rtl/trike_parity_map_stream.sv rtl/trike_h123_vectors.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv rtl/trike_keygen_core.sv tb/tb_trike_keygen_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_core_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SHARED_SM3=1 --top-module tb_trike_keygen_core_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv rtl/trike_parity_map_stream.sv rtl/trike_h123_vectors.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv rtl/trike_keygen_core.sv tb/tb_trike_keygen_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_core_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SHARED_SM3=1 -GUSE_SHARED_MUL=1 -GUSE_SHARED_H123=1 --top-module tb_trike_keygen_core_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv rtl/trike_parity_map_stream.sv rtl/trike_h123_vectors.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv rtl/trike_keygen_core.sv tb/tb_trike_keygen_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_core_reference +verilator+quiet

test-trike-keygen-synth-reference: $(TRIKE_KEYGEN_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SYNTH_TOP=1 --top-module tb_trike_keygen_core_reference $(TRIKE_KEYGEN_RTL) tb/tb_trike_keygen_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_keygen_core_reference +verilator+quiet

$(TRIKE_POLY_REFERENCE_FIXTURE): scripts/gen_trike_poly_mul_fixture.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_poly_mul_fixture.py \
		--kat "$(TRIKE_POLY_REFERENCE_KAT)" \
		--output "$@"

test-trike-poly-reference: $(TRIKE_POLY_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_poly_mul_reference rtl/ram_bram.sv rtl/trike_poly_mul_core.sv tb/tb_trike_poly_mul_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_poly_mul_reference +verilator+quiet

$(TRIKE_POLY_INV_REFERENCE_FIXTURE): scripts/gen_trike_poly_inv_fixture.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_poly_inv_fixture.py \
		--kat "$(TRIKE_POLY_REFERENCE_KAT)" \
		--output "$@"

$(TRIKE_MINSUM_POLY_INV_FIXTURE): scripts/gen_trike_poly_inv_fixture.py scripts/gen_trike_inv_schedule.py
	@python3 scripts/gen_trike_poly_inv_fixture.py \
		--input-seed 1 \
		--r-bits 12589 \
		--output "$@"

test-trike-poly-inv-reference: $(TRIKE_POLY_INV_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_poly_inv_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv tb/tb_trike_poly_inv_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_poly_inv_reference +verilator+quiet

test-trike-poly-inv-minsum-reference: $(TRIKE_MINSUM_POLY_INV_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) -DTRIKE_MINSUM_INV_FIXTURE --top-module tb_trike_poly_inv_reference rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv tb/tb_trike_poly_inv_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_poly_inv_reference +verilator+quiet

gen-trike-minsum-kem-case: $(MIN_SUM_MODEL)
	@python3 scripts/gen_trike_minsum_kem_case.py \
		--model "$(MIN_SUM_MODEL)" \
		--seed 1 \
		--profile "$(TRIKE_MINSUM_PROFILE)" \
		--work-dir "$(dir $(TRIKE_MINSUM_KEM_CASE))" \
		--decaps-message-svh "$(TRIKE_MINSUM_DECAPS_MESSAGE_FIXTURE)" \
		--runtime-decaps-svh "$(TRIKE_MINSUM_RUNTIME_DECAPS_FIXTURE)" \
		--output "$(TRIKE_MINSUM_KEM_CASE)"

test-trike-pseudohash-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_pseudohash512_runtime $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_pseudohash512_stream.sv tb/tb_trike_pseudohash512_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_pseudohash512_runtime +verilator+quiet

test-trike-h4-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_h4_runtime $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv tb/tb_trike_h4_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_h4_runtime +verilator+quiet

test-trike-ct-verify-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_ct_verify_runtime rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv tb/tb_trike_ct_verify_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_ct_verify_runtime +verilator+quiet

test-trike-decaps-postprocess-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_postprocess_runtime $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv rtl/trike_decaps_message_recover.sv rtl/trike_decaps_reencrypt_verify.sv rtl/trike_pseudohash512_stream.sv rtl/trike_decaps_kdf.sv rtl/trike_decaps_postprocess_core.sv tb/tb_trike_decaps_postprocess_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_postprocess_runtime +verilator+quiet

test-trike-decaps-input-loader:
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_input_loader rtl/bike_pkg.sv rtl/trike_decaps_profile_config.sv rtl/trike_decaps_input_loader.sv tb/tb_trike_decaps_input_loader.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_input_loader +verilator+quiet

test-trike-decaps-input-store:
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_input_store rtl/bike_pkg.sv rtl/trike_decaps_profile_config.sv rtl/trike_decaps_input_loader.sv rtl/ram_bram.sv rtl/trike_decaps_input_store.sv tb/tb_trike_decaps_input_store.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_input_store +verilator+quiet

test-trike-decaps-syndrome-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_syndrome_runtime rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv tb/tb_trike_decaps_syndrome_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_syndrome_runtime +verilator+quiet

test-trike-decaps-syndrome-store-core:
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_syndrome_store_core rtl/bike_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv rtl/trike_decaps_syndrome_prefetch.sv rtl/trike_decaps_syndrome_store_core.sv tb/tb_trike_decaps_syndrome_store_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_syndrome_store_core +verilator+quiet

test-trike-decaps-input-syndrome-core:
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_input_syndrome_core rtl/bike_pkg.sv rtl/trike_decaps_profile_config.sv rtl/trike_decaps_input_loader.sv rtl/ram_bram.sv rtl/trike_decaps_input_store.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv rtl/trike_decaps_syndrome_prefetch.sv rtl/trike_decaps_syndrome_store_core.sv rtl/trike_decaps_input_syndrome_core.sv tb/tb_trike_decaps_input_syndrome_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_input_syndrome_core +verilator+quiet

test-trike-decaps-support-prefetch:
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_support_prefetch rtl/bike_pkg.sv rtl/trike_decaps_support_prefetch.sv tb/tb_trike_decaps_support_prefetch.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_support_prefetch +verilator+quiet

test-trike-decaps-input-decoder-load-core:
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_input_decoder_load_core rtl/bike_pkg.sv rtl/trike_decaps_profile_config.sv rtl/trike_decaps_input_loader.sv rtl/ram_bram.sv rtl/trike_decaps_input_store.sv rtl/trike_decaps_support_prefetch.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv rtl/trike_decaps_syndrome_prefetch.sv rtl/trike_decaps_syndrome_store_core.sv rtl/trike_fixed_support_sorter.sv rtl/trike_decoder_load_adapter.sv rtl/trike_decaps_input_decoder_load_core.sv tb/tb_trike_decaps_input_decoder_load_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_input_decoder_load_core +verilator+quiet

test-trike-decaps-decoder-postcheck-core:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_decoder_postcheck_core rtl/ram_bram.sv rtl/trike_decoder_error_vector.sv rtl/trike_decoder_residual_check.sv rtl/trike_decaps_decoder_postcheck_core.sv tb/tb_trike_decaps_decoder_postcheck_core.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_decoder_postcheck_core +verilator+quiet

test-trike-fixed-support-sorter-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_fixed_support_sorter_runtime rtl/trike_fixed_support_sorter.sv tb/tb_trike_fixed_support_sorter_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_fixed_support_sorter_runtime +verilator+quiet

test-trike-decoder-load-adapter-runtime:
	@$(VERILATOR) --binary --sv -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decoder_load_adapter_runtime rtl/trike_fixed_support_sorter.sv rtl/trike_decoder_load_adapter.sv tb/tb_trike_decoder_load_adapter_runtime.sv
	@$(SIM) ./obj_dir/Vtb_trike_decoder_load_adapter_runtime +verilator+quiet

test-trike-decaps-message-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decaps_message_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_pseudohash512_stream.sv rtl/trike_decaps_message_recover.sv tb/tb_trike_decaps_message_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_message_reference +verilator+quiet

test-trike-decaps-verify-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decaps_verify_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv rtl/trike_decaps_reencrypt_verify.sv tb/tb_trike_decaps_verify_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_verify_reference +verilator+quiet

test-trike-decaps-kdf-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decaps_kdf_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_pseudohash512_stream.sv rtl/trike_decaps_kdf.sv tb/tb_trike_decaps_kdf_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_kdf_reference +verilator+quiet

test-trike-decaps-postprocess-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decaps_postprocess_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv rtl/trike_decaps_message_recover.sv rtl/trike_decaps_reencrypt_verify.sv rtl/trike_decaps_kdf.sv rtl/trike_decaps_postprocess_core.sv tb/tb_trike_decaps_postprocess_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_postprocess_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SHARED_SM3=1 --top-module tb_trike_decaps_postprocess_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv rtl/trike_decaps_message_recover.sv rtl/trike_decaps_reencrypt_verify.sv rtl/trike_decaps_kdf.sv rtl/trike_decaps_postprocess_core.sv tb/tb_trike_decaps_postprocess_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_postprocess_reference +verilator+quiet

test-trike-decoder-residual-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decoder_residual_reference rtl/ram_bram.sv rtl/trike_decoder_residual_check.sv tb/tb_trike_decoder_residual_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decoder_residual_reference +verilator+quiet

test-trike-decaps-pipeline-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) --binary --sv -DTRIKE_160_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_SIM_DEBUG -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_pipeline_reference $(TRIKE_DECAPS_RTL) tb/tb_trike_decaps_pipeline_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_pipeline_reference +verilator+quiet

test-trike-decaps-synth-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) --binary --sv -DTRIKE_160_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_SIM_DEBUG -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_synth_reference $(TRIKE_DECAPS_SYNTH_RTL) tb/tb_trike_decaps_synth_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_synth_reference +verilator+quiet

test-trike-decaps-runtime-synth-reference: gen-trike-minsum-kem-case
	@$(VERILATOR) --binary --sv -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 -DBIKE_SIM_DEBUG $(TRIKE_RUNTIME_REFERENCE_DEFINES) $(TRIKE_RUNTIME_REFERENCE_CFLAGS) -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) --top-module tb_trike_decaps_runtime_synth_reference $(TRIKE_DECAPS_SYNTH_RTL) tb/tb_trike_decaps_runtime_synth_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_runtime_synth_reference +verilator+quiet

test-trike-decaps-runtime-four-profile-reference:
	@for profile in $(TRIKE_MINSUM_PROFILES); do \
		$(MAKE) test-trike-decaps-runtime-synth-reference TRIKE_MINSUM_PROFILE=$$profile TRIKE_RUNTIME_REFERENCE_DEFINES=-DTRIKE_RUNTIME_ACCEPT_REJECT_ONLY || exit 1; \
	done

$(TRIKE_ENCAPS_REFERENCE_FIXTURE): scripts/gen_trike_encaps_fixture.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_encaps_fixture.py --kat "$(TRIKE_POLY_REFERENCE_KAT)" --output "$@"

$(TRIKE_DECAPS_SYNDROME_REFERENCE_FIXTURE): scripts/gen_trike_decaps_syndrome_fixture.py scripts/gen_trike_encaps_fixture.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_decaps_syndrome_fixture.py --kat "$(TRIKE_POLY_REFERENCE_KAT)" --output "$@"

test-trike-decaps-syndrome-reference: $(TRIKE_DECAPS_SYNDROME_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_decaps_syndrome_reference rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv tb/tb_trike_decaps_syndrome_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_syndrome_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SHARED_MUL=1 --top-module tb_trike_decaps_syndrome_reference rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv tb/tb_trike_decaps_syndrome_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_decaps_syndrome_reference +verilator+quiet

test-trike-encaps-components-reference: $(TRIKE_ENCAPS_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_encaps_components_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/trike_parity_map_stream.sv rtl/trike_h123_vectors.sv rtl/ram_bram.sv rtl/trike_poly_mul_core.sv rtl/trike_encaps_uv_core.sv tb/tb_trike_encaps_components_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_components_reference +verilator+quiet

test-trike-encaps-hash-reference: $(TRIKE_ENCAPS_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_encaps_hash_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_pseudohash512_stream.sv tb/tb_trike_encaps_hash_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_hash_reference +verilator+quiet

test-trike-encaps-core-reference: $(TRIKE_ENCAPS_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_encaps_core_reference $(TRIKE_ENCAPS_RTL) tb/tb_trike_encaps_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_core_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SHARED_SM3=1 --top-module tb_trike_encaps_core_reference $(TRIKE_ENCAPS_RTL) tb/tb_trike_encaps_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_core_reference +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SHARED_SM3=1 -GUSE_SHARED_MUL=1 -GUSE_SHARED_H123=1 --top-module tb_trike_encaps_core_reference $(TRIKE_ENCAPS_RTL) tb/tb_trike_encaps_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_core_reference +verilator+quiet

test-trike-encaps-synth-reference: $(TRIKE_ENCAPS_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) -GUSE_SYNTH_TOP=1 --top-module tb_trike_encaps_core_reference $(TRIKE_ENCAPS_RTL) tb/tb_trike_encaps_core_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_encaps_core_reference +verilator+quiet

test-trike-error-store-reference: $(TRIKE_ENCAPS_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_error_support_store_reference rtl/ram_bram.sv rtl/trike_error_support_store.sv tb/tb_trike_error_support_store_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_error_support_store_reference +verilator+quiet

test-trike-h4-vector-reference: $(TRIKE_ENCAPS_REFERENCE_FIXTURE)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_h4_error_vector_reference $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv tb/tb_trike_h4_error_vector_reference.sv
	@$(SIM) ./obj_dir/Vtb_trike_h4_error_vector_reference +verilator+quiet

check-trike-sm3-sharing:
	@$(YOSYS) -Q -s scripts/check_trike_sm3_sharing.ys >/dev/null
	@REAL_VERILATOR=$(REAL_VERILATOR) python3 scripts/check_trike_kem_asic_structure.py
	@echo "TRIKE SM3 sharing PASS: one sm3_compress per standalone composite or unified ASIC top"

test-trike-kem-operation-control:
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_trike_kem_operation_control rtl/trike_kem_operation_control.sv tb/tb_trike_kem_operation_control.sv
	@$(SIM) ./obj_dir/Vtb_trike_kem_operation_control +verilator+quiet

test-integration: $(TOY_CASE_SVH)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_decoder_top $(RTL) tb/tb_decoder_top.sv
	@$(SIM) ./obj_dir/Vtb_decoder_top +verilator+quiet

test-bike-random:
	@python3 scripts/run_bike_random.py --param-set $(BIKE_RANDOM_PARAM_SET) --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) $(BIKE_RANDOM_ERROR_ARG) --parallel-l $(BIKE_RANDOM_PARALLEL_L) --cols-per-tile $(BIKE_RANDOM_COLS_PER_TILE) --timeout-cycles $(BIKE_RANDOM_TIMEOUT_CYCLES) --verilator $(VERILATOR)

test-bike-unified-random:
	@for param_set in $(BIKE_UNIFIED_RANDOM_PARAM_SETS); do \
		python3 scripts/run_bike_random.py --unified --param-set $$param_set --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) $(BIKE_RANDOM_ERROR_ARG) --parallel-l $(BIKE_RANDOM_PARALLEL_L) --cols-per-tile $(BIKE_UNIFIED_RANDOM_COLS_PER_TILE) --timeout-cycles $(BIKE_UNIFIED_RANDOM_TIMEOUT_CYCLES) --out-dir tb/generated/bike_unified_random/$$param_set --verilator $(VERILATOR); \
	done

test-trike-unified-ksign-random:
	@for param_set in $(TRIKE_UNIFIED_KSIGN_PARAM_SETS); do \
		python3 scripts/run_bike_random.py --unified --param-set $$param_set --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) $(BIKE_RANDOM_ERROR_ARG) --parallel-l $(TRIKE_UNIFIED_KSIGN_PARALLEL_L) --cols-per-tile $(TRIKE_UNIFIED_KSIGN_COLS_PER_TILE) --k-sign-k $(TRIKE_UNIFIED_KSIGN_K) --timeout-cycles $(TRIKE_UNIFIED_KSIGN_TIMEOUT_CYCLES) --out-dir tb/generated/trike_unified_ksign/k$(TRIKE_UNIFIED_KSIGN_K)/$$param_set --verilator $(VERILATOR); \
	done

model-min-sum: $(MIN_SUM_MODEL)

$(MIN_SUM_MODEL): scripts/min_sum_model.c
	@mkdir -p $(MODEL_BUILD_DIR)
	@$(CC) $(CFLAGS) $< -o $@

run-model-min-sum: model-min-sum
	@$(MIN_SUM_MODEL) --profile bike128 --seed 1 --trials 1

$(AWS_FIPS202_C):
	@mkdir -p $(dir $(AWS_BIKE_KEM_DIR))
	@git clone --depth 1 $(AWS_BIKE_KEM_URL) $(AWS_BIKE_KEM_DIR)

software-trike-kem: $(TRIKE_KEM_SELFTEST)

$(TRIKE_KEM_SELFTEST): $(TRIKE_KEM_SOURCES) software/trike_kem/trike_kem.h software/trike_kem/trike_ms_quant.h $(AWS_FIPS202_C)
	@mkdir -p $(TRIKE_KEM_BUILD_DIR)
	@$(CC) $(CFLAGS) -Isoftware/trike_kem -I$(AWS_FIPS202_INCLUDE) $(TRIKE_KEM_SOURCES) $(AWS_FIPS202_C) -o $@

test-software-trike-kem: software-trike-kem
	@for profile in $(TRIKE_KEM_TEST_PROFILES); do \
		$(TRIKE_KEM_SELFTEST) $$profile 1 || exit 1; \
	done

test-trike-reference-kat:
	@python3 scripts/run_trike_reference_kat.py \
		--source-root "$(TRIKE_REFERENCE_SOURCE_ROOT)" \
		--build-root "$(TRIKE_REFERENCE_BUILD_DIR)" \
		--parameter-sets $(TRIKE_REFERENCE_PARAM_SETS) \
		--cc "$(CC)"

check-trike-reference-data:
	@if [ ! -f "$(TRIKE_POLY_REFERENCE_KAT)" ]; then \
		echo "missing TRIKE reference KAT: $(TRIKE_POLY_REFERENCE_KAT)"; \
		echo "set TRIKE_REFERENCE_SOURCE_ROOT in config/local.mk"; \
		exit 1; \
	fi

sweep-min-sum: model-min-sum
	@python3 scripts/run_quantization_experiment.py sweep --model $(MIN_SUM_MODEL)

optimum-min-sum: model-min-sum
	@python3 scripts/run_quantization_experiment.py optimum --model $(MIN_SUM_MODEL)

campaign-min-sum: model-min-sum
	@python3 scripts/run_quantization_experiment.py campaign --model $(MIN_SUM_MODEL)

confirm-min-sum: model-min-sum
	@python3 scripts/run_quantization_experiment.py confirm --model $(MIN_SUM_MODEL)

check-model-rtl: model-min-sum
	@python3 scripts/check_model_rtl.py --model $(MIN_SUM_MODEL) --verilator $(VERILATOR)

check-model-rtl-bike128: model-min-sum
	@python3 scripts/check_model_rtl.py --model $(MIN_SUM_MODEL) --verilator $(VERILATOR) --seed 1 --r 12323 --w 71 --errors 134 --iterations 7 --msg-bits 5 --c-val 5 --alpha-shift-0 3 --alpha-shift-1 4 --parallel-l 32 --cols-per-tile 576

check-local-tools:
	@for tool in $(REAL_VERILATOR) $(VERIBLE_FORMAT) $(VERIBLE_LINT) $(SLANG) $(YOSYS) $(SBY) $(Z3); do \
		command -v $$tool >/dev/null || { echo "missing required local tool: $$tool"; exit 1; }; \
	done
	@echo "Local RTL tools PASS"

tool-versions:
	@python3 scripts/check_tool_versions.py

check-tool-versions:
	@python3 scripts/check_tool_versions.py --check

check-filelists:
	@python3 scripts/check_filelists.py

check-records:
	@python3 scripts/check_project_records.py

format-rtl:
	@$(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $(MAINTAINED_SV)
	@$(SV_DECL_FORMAT) $(MAINTAINED_SV)

check-format-rtl:
	@for f in $(MAINTAINED_SV); do tmp=$$(mktemp /private/tmp/format-rtl.XXXXXX.sv); cp $$f $$tmp; $(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $$tmp; $(SV_DECL_FORMAT) $$tmp; cmp -s $$f $$tmp || { echo "$$f: formatting needed"; rm -f $$tmp; exit 1; }; rm -f $$tmp; done

lint-rtl:
	@$(VERIBLE_LINT) $(VERIBLE_LINT_FLAGS) $(MAINTAINED_SV)

lint-verilator:
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) -DBIKE_PARALLEL_L=$(BIKE_PARALLEL_L) --top-module decoder_top $(RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) --top-module trike_poly_inv_synth_top $(TRIKE_POLY_INV_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) --top-module trike_pseudohash_synth_top $(TRIKE_PSEUDOHASH_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) --top-module trike_encaps_synth_top $(TRIKE_ENCAPS_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) --top-module trike_keygen_synth_top $(TRIKE_KEYGEN_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) -DTRIKE_160_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top-module trike_decaps_synth_top $(TRIKE_DECAPS_SYNTH_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top-module trike_decaps_synth_top $(TRIKE_DECAPS_SYNTH_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top-module trike_decaps_runtime_synth_top $(TRIKE_DECAPS_SYNTH_RTL)
	@$(REAL_VERILATOR) $(VERILATOR_LINT_FLAGS) -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top-module trike_kem_asic_top $(TRIKE_KEM_ASIC_RTL)

lint-slang:
	@$(SLANG) $(SLANG_FLAGS) -DBIKE_PARALLEL_L=$(BIKE_PARALLEL_L) --top decoder_top $(RTL)
	@$(SLANG) $(SLANG_FLAGS) --top trike_encaps_synth_top $(TRIKE_ENCAPS_RTL)
	@$(SLANG) $(SLANG_FLAGS) --top trike_keygen_synth_top $(TRIKE_KEYGEN_RTL)
	@$(SLANG) $(SLANG_FLAGS) -DTRIKE_160_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top trike_decaps_synth_top $(TRIKE_DECAPS_RTL) rtl/trike_decaps_synth_top.sv
	@$(SLANG) $(SLANG_FLAGS) -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top trike_decaps_synth_top $(TRIKE_DECAPS_RTL) rtl/trike_decaps_synth_top.sv
	@$(SLANG) $(SLANG_FLAGS) -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top trike_decaps_runtime_synth_top $(TRIKE_DECAPS_RTL) rtl/trike_decaps_runtime_synth_top.sv
	@$(SLANG) $(SLANG_FLAGS) -DTRIKE_UNIFIED_PARAMS -DBIKE_PARALLEL_L=32 -DBIKE_K_SIGN_K=4 -DBIKE_MSG_BITS=5 -DBIKE_COLS_PER_TILE=256 --top trike_kem_asic_top $(TRIKE_KEM_ASIC_RTL)

check-rtl: check-filelists check-format-rtl lint-rtl lint-verilator lint-slang

formal: formal-fast

formal-fast: formal-ct-select formal-ct-control formal-trike-kem-operation-control

formal-trike-kem-operation-control:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove cover; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/trike_kem_operation_control_$$task formal/trike_kem_operation_control.sby $$task || exit 1; \
	done

formal-nightly: formal-fast formal-ct-control-extended

formal-ct-select:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove_w1 prove_w8 prove_w256 cover_w1 cover_w8 cover_w256; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/kem_ct_compare_select_$$task formal/kem_ct_compare_select.sby $$task || exit 1; \
	done

formal-ct-control:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove_words1 prove_words3 cover_words1 cover_words3; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/trike_ct_verify_stream_$$task formal/trike_ct_verify_stream.sby $$task || exit 1; \
	done

formal-ct-control-extended:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove_words16 cover_words16; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/trike_ct_verify_stream_$$task formal/trike_ct_verify_stream.sby $$task || exit 1; \
	done

verify-rtl: ci-fast

ci-fast: check-local-tools check-tool-versions check-records check-rtl formal-fast test

ci-smoke:
	@$(MAKE) ci-fast
	@$(MAKE) test-bike-random BIKE_RANDOM_PARAM_SET=bike128 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-bike-unified-random BIKE_UNIFIED_RANDOM_PARAM_SETS=bike128 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_PARAM_SETS=trike160 TRIKE_UNIFIED_KSIGN_K=3 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_PARAM_SETS=trike160 TRIKE_UNIFIED_KSIGN_K=4 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1

ci-nightly:
	@$(MAKE) ci-smoke
	@$(MAKE) formal-nightly
	@$(MAKE) test-bike-unified-random BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=$(CI_NIGHTLY_TRIALS)
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K=3 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=$(CI_NIGHTLY_TRIALS)
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K=4 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=$(CI_NIGHTLY_TRIALS)

ci-kem-reference: check-local-tools check-tool-versions check-records check-rtl check-trike-reference-data $(TRIKE_KEM_REFERENCE_TARGETS)

vivado-synth:
	@mkdir -p $(VIVADO_BUILD_DIR)
	@BIKE_PARAM_DEFINE=$(BIKE_SYNTH_PARAM) BIKE_PARALLEL_L=$(BIKE_SYNTH_PARALLEL_L) BIKE_K_SIGN_K=$(TRIKE_UNIFIED_KSIGN_K) $(if $(BIKE_SYNTH_COLS_PER_TILE),BIKE_COLS_PER_TILE=$(BIKE_SYNTH_COLS_PER_TILE),) $(VIVADO) -mode batch -source scripts/vivado_synth.tcl -tclargs $(VIVADO_BUILD_DIR)

vivado-synth-trike-unified-ksign:
	@$(MAKE) vivado-synth BIKE_SYNTH_PARAM=TRIKE_UNIFIED_PARAMS BIKE_SYNTH_PARALLEL_L=$(TRIKE_UNIFIED_KSIGN_PARALLEL_L) BIKE_SYNTH_COLS_PER_TILE=$(TRIKE_UNIFIED_KSIGN_COLS_PER_TILE) VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_unified_ksign_l$(TRIKE_UNIFIED_KSIGN_PARALLEL_L)_k$(TRIKE_UNIFIED_KSIGN_K)

vivado-impl-trike-kem-core:
	@mkdir -p $(VIVADO_BUILD_DIR)
	@TRIKE_KEM_SYNTH_TOP=$(TRIKE_KEM_SYNTH_TOP) VIVADO_PART=$(VIVADO_PART) VIVADO_XDC=constraints/trike_kem_core.xdc VIVADO_RUN_ID=$(VIVADO_RUN_TAG) $(VIVADO) -mode batch -source scripts/vivado_trike_kem_cores.tcl -tclargs $(VIVADO_BUILD_DIR)

vivado-impl-trike-poly-inv:
	@$(MAKE) vivado-impl-trike-kem-core TRIKE_KEM_SYNTH_TOP=trike_poly_inv_synth_top VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_poly_inv

vivado-impl-trike-pseudohash:
	@$(MAKE) vivado-impl-trike-kem-core TRIKE_KEM_SYNTH_TOP=trike_pseudohash_synth_top VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_pseudohash

vivado-impl-trike-encaps:
	@$(MAKE) vivado-impl-trike-kem-core TRIKE_KEM_SYNTH_TOP=trike_encaps_synth_top VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_encaps

vivado-impl-trike-keygen:
	@$(MAKE) vivado-impl-trike-kem-core TRIKE_KEM_SYNTH_TOP=trike_keygen_synth_top VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_keygen

vivado-impl-trike-decaps:
	@$(MAKE) vivado-impl-trike-kem-core TRIKE_KEM_SYNTH_TOP=trike_decaps_synth_top VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_decaps

vivado-impl-trike-decaps-runtime:
	@$(MAKE) vivado-impl-trike-kem-core TRIKE_KEM_SYNTH_TOP=trike_decaps_runtime_synth_top VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_decaps_runtime

vivado-impl-trike-kem-cores:
	@$(MAKE) vivado-impl-trike-poly-inv VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)
	@$(MAKE) vivado-impl-trike-pseudohash VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)

sim: test
