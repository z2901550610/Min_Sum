.DEFAULT_GOAL := all
-include config/local.mk

# Full-size regression scope; individual suite variables remain overridable.
VALIDATION_PROFILE_SET ?= representative
ifeq ($(VALIDATION_PROFILE_SET),representative)
TRIKE_TEST_PROFILES := trike160 trike512
BIKE_TEST_PROFILES := bike128 bike256
TRIKE_REFERENCE_PROFILES := TRIKE-2 TRIKE-9
else ifeq ($(VALIDATION_PROFILE_SET),all)
TRIKE_TEST_PROFILES := trike160 trike256 trike384 trike512
BIKE_TEST_PROFILES := bike128 bike192 bike256
TRIKE_REFERENCE_PROFILES := TRIKE-2 TRIKE-5 TRIKE-7 TRIKE-9
else
$(error VALIDATION_PROFILE_SET must be representative or all)
endif

# Tool and build configuration.
VERILATOR ?= ./scripts/verilator_quiet.py
REAL_VERILATOR ?= verilator
VERILATOR_LOG_DIR ?= build/logs/verilator
BIKE_PARALLEL_L ?= 32
BIKE_TOY_PARALLEL_L ?= 8
BIKE_SYNTH_PARAM ?=
BIKE_SYNTH_PARALLEL_L ?= 32
BIKE_SYNTH_COLS_PER_TILE ?=
VERILATOR_WAIVER_FILE ?= config/verilator_waivers.vlt
VERILATOR_BUILD_ROOT ?= build/verilator
VERILATOR_VARIANT_KEY = l$(BIKE_TOY_PARALLEL_L)-kd$(TRIKE_POLY_KARATSUBA_DEPTH)-p$(TRIKE_MINSUM_PROFILE)-k$(TRIKE_UNIFIED_KSIGN_K)
VERILATOR_MDIR = $(VERILATOR_BUILD_ROOT)/$@/$(VERILATOR_VARIANT_KEY)
VERILATOR_MDIR_FLAG = --Mdir $(VERILATOR_MDIR)
VERILATOR_FLAGS ?= --binary --sv -DBIKE_TOY_PARAMS -DBIKE_PARALLEL_L=$(BIKE_TOY_PARALLEL_L) -DBIKE_SIM_DEBUG -Wall -I./tb -I./rtl $(VERILATOR_WAIVER_FILE) $(VERILATOR_MDIR_FLAG)
VERILATOR_LINT_FLAGS ?= --lint-only --sv -Wall --quiet -I./tb -I./rtl $(VERILATOR_WAIVER_FILE)
SIM ?= ./scripts/run_quiet.py
VIVADO ?= vivado
YOSYS ?= yosys
SLANG ?= slang
SBY ?= ./scripts/sby_quiet.py
REAL_SBY ?= sby
SBY_LOG_DIR ?= build/logs/sby
CHECK_SUMMARY_PATH ?= build/results/check-summary.json
Z3 ?= z3
COCOTB_CONFIG ?= cocotb-config
UV ?= uv
SLANG_FLAGS ?= --std 1800-2017 --single-unit --lint-only --quiet -Werror -I tb -I rtl
FORMAL_BUILD_DIR ?= build/formal
LOCAL_SYNTH_TOP ?= kem_ct_compare_select
LOCAL_SYNTH_SOURCES ?= rtl/kem_ct_compare_select.sv
LOCAL_SYNTH_BUILD_DIR ?= build/synth/$(LOCAL_SYNTH_TOP)
QOR_TOP := kem_ct_compare_select
QOR_SOURCES := rtl/kem_ct_compare_select.sv
QOR_BUILD_DIR := build/synth/$(QOR_TOP)
QOR_REPORT_DIR ?= build/results/qor
QOR_RECORD_DIR ?= reports/qor
QOR_LINT_STATUS ?= NOT_RUN
QOR_SIMULATION_STATUS ?= NOT_RUN
QOR_FORMAL_STATUS ?= NOT_RUN
QOR_VALIDATION_RUN_ID ?=
VALIDATION_JOBS ?= 2
VALIDATION_PATHS ?=
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
TRIKE_KEM_TEST_PROFILES ?= $(TRIKE_TEST_PROFILES)
TRIKE_REFERENCE_SOURCE_ROOT ?= external/trike-reference
TRIKE_REFERENCE_BUILD_DIR ?= build/software/trike_reference
TRIKE_REFERENCE_PARAM_SETS ?= $(TRIKE_REFERENCE_PROFILES)
TRIKE_POLY_REFERENCE_KAT ?= $(TRIKE_REFERENCE_SOURCE_ROOT)/Test_Vectors/KAT_KEM_TRIKE-2.txt
TRIKE_POLY_REFERENCE_FIXTURE ?= tb/generated/trike_poly_mul_reference_case.svh
TRIKE_POLY_INV_REFERENCE_FIXTURE ?= tb/generated/trike_poly_inv_reference_case.svh
TRIKE_MINSUM_POLY_INV_FIXTURE ?= tb/generated/trike_poly_inv_minsum_case.svh
TRIKE_POLY_KARATSUBA_DEPTH ?= 2
TRIKE_MINSUM_PROFILE ?= trike160
TRIKE_MINSUM_PROFILES ?= $(TRIKE_TEST_PROFILES)
TRIKE_RUNTIME_REFERENCE_DEFINES ?=
TRIKE_RUNTIME_REFERENCE_CFLAGS ?= -CFLAGS -O3
TRIKE_MINSUM_KEM_CASE ?= build/generated/trike_minsum_kem/$(TRIKE_MINSUM_PROFILE)_seed1.json
TRIKE_MINSUM_DECAPS_MESSAGE_FIXTURE ?= tb/generated/trike_decaps_message_minsum_case.svh
TRIKE_MINSUM_RUNTIME_DECAPS_FIXTURE ?= tb/generated/trike_decaps_runtime_minsum_case.svh
TRIKE_ENCAPS_REFERENCE_FIXTURE ?= tb/generated/trike_encaps_reference_case.svh
TRIKE_KEYGEN_REFERENCE_FIXTURE ?= tb/generated/trike_keygen_reference_case.svh
TRIKE_DECAPS_SYNDROME_REFERENCE_FIXTURE ?= tb/generated/trike_decaps_syndrome_reference_case.svh
TRIKE_KEM_SYNTH_TOP ?= trike_poly_inv_synth_top
VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_FORMAT_FLAGS ?= --port_declarations_alignment=align --module_net_variable_alignment=align --formal_parameters_alignment=align
VERIBLE_LINT ?= verible-verilog-lint
VERIBLE_LINT_FLAGS ?= --rules_config .rules.verible_lint
SV_DECL_FORMAT ?= python3 scripts/format_sv_decls.py
export REAL_VERILATOR
export VERILATOR_LOG_DIR
export REAL_SBY
export SBY_LOG_DIR
export CHECK_SUMMARY_PATH
export BIKE_PARALLEL_L

TOY_CASE_SVH := tb/generated/bike_toy_case.svh
read_filelist = $(shell sed -e '/^[[:space:]]*\#/d' -e '/^[[:space:]]*$$/d' $(1))
RTL := $(call read_filelist,filelists/decoder.f)
RTL_PKG := rtl/bike_pkg.sv
RTL_CORE := $(filter-out $(RTL_PKG),$(RTL))
SM3_COMPRESS_RTL := rtl/sm3_compress.sv rtl/trike_sm3_service.sv
TRIKE_POLY_INV_RTL := $(call read_filelist,filelists/trike_poly_inv.f)
TRIKE_POLY_KARATSUBA_RTL := $(call read_filelist,filelists/trike_poly_mul_karatsuba.f)
TRIKE_POLY_KARATSUBA2_RTL := $(call read_filelist,filelists/trike_poly_mul_karatsuba2.f)
TRIKE_PSEUDOHASH_RTL := $(call read_filelist,filelists/trike_pseudohash.f)
TRIKE_ENCAPS_RTL := $(call read_filelist,filelists/trike_encaps.f)
TRIKE_KEYGEN_RTL := $(call read_filelist,filelists/trike_keygen.f)
TRIKE_DECAPS_SYNTH_RTL := $(call read_filelist,filelists/trike_decaps.f)
TRIKE_DECAPS_RTL := $(filter-out rtl/trike_decaps_synth_top.sv rtl/trike_decaps_runtime_synth_top.sv,$(TRIKE_DECAPS_SYNTH_RTL))
TRIKE_KEM_ASIC_RTL := $(call read_filelist,filelists/trike_kem_asic.f)
TRIKE_ENCAPS_UV_UNIT_RTL := rtl/ram_bram.sv rtl/trike_poly_mul_karatsuba_core.sv rtl/trike_poly_mul_core.sv rtl/trike_encaps_uv_core.sv
TRIKE_KEYGEN_ARITH_UNIT_RTL := rtl/trike_inv_schedule_pkg.sv rtl/ram_bram.sv rtl/trike_poly_mul_karatsuba_core.sv rtl/trike_poly_mul_core.sv rtl/trike_poly_inv_core.sv rtl/trike_keygen_arith_core.sv
TRIKE_KEYGEN_SECRET_REFERENCE_RTL := $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/ram_bram.sv rtl/trike_weak_key_test.sv rtl/trike_keygen_secret_sampler.sv
TRIKE_KEYGEN_CORE_REFERENCE_RTL := $(filter-out rtl/reset_sync.sv rtl/trike_keygen_synth_top.sv,$(TRIKE_KEYGEN_RTL))
TRIKE_DECAPS_POSTPROCESS_REFERENCE_RTL := $(SM3_COMPRESS_RTL) rtl/sm3_hash_stream.sv rtl/sm3_df_stream.sv rtl/hmac_sm3_64byte_key_stream.sv rtl/trike_sm3_drng_instantiate_stream.sv rtl/trike_sm3_drng_generate_stream.sv rtl/trike_sampler_candidate.sv rtl/trike_fixed_weight_sampler.sv rtl/trike_drng_weight_sampler.sv rtl/trike_h4_error_sampler.sv rtl/ram_bram.sv rtl/trike_error_support_store.sv rtl/trike_h4_error_vector.sv rtl/kem_ct_compare_select.sv rtl/trike_ct_verify_stream.sv rtl/trike_decaps_message_recover.sv rtl/trike_decaps_reencrypt_verify.sv rtl/trike_decaps_kdf.sv rtl/trike_decaps_postprocess_core.sv
TRIKE_DECAPS_SYNDROME_REFERENCE_RTL := rtl/ram_bram.sv rtl/trike_poly_mul_karatsuba_core.sv rtl/trike_poly_mul_core.sv rtl/trike_decaps_syndrome_core.sv
MAINTAINED_SV := $(sort $(wildcard rtl/*.sv) $(wildcard tb/*.sv) $(wildcard formal/*.sv))
BIKE_RANDOM_BASE_SEED ?= 1
BIKE_RANDOM_TRIALS ?= 1
BIKE_RANDOM_PARAM_SET ?= bike128
BIKE_RANDOM_ERROR_COUNT ?=
BIKE_RANDOM_PARALLEL_L ?= $(BIKE_PARALLEL_L)
BIKE_RANDOM_COLS_PER_TILE ?= 256
BIKE_RANDOM_TIMEOUT_CYCLES ?= 800000
BIKE_RANDOM_ERROR_ARG := $(if $(BIKE_RANDOM_ERROR_COUNT),--error-count $(BIKE_RANDOM_ERROR_COUNT),)
BIKE_UNIFIED_RANDOM_PARAM_SETS ?= $(BIKE_TEST_PROFILES)
BIKE_UNIFIED_RANDOM_COLS_PER_TILE ?= 576
BIKE_UNIFIED_RANDOM_TIMEOUT_CYCLES ?= 40000000
TRIKE_UNIFIED_KSIGN_PARALLEL_L ?= 32
TRIKE_UNIFIED_KSIGN_COLS_PER_TILE ?= 1152
TRIKE_UNIFIED_KSIGN_K ?= 4
TRIKE_UNIFIED_KSIGN_PARAM_SETS ?= $(TRIKE_TEST_PROFILES)
TRIKE_UNIFIED_KSIGN_TIMEOUT_CYCLES ?= 40000000
CI_SMOKE_SEED ?= 1
CI_NIGHTLY_TRIALS ?= 4

# Test commands, groups and validation owners share one catalog.
build/test_catalog.mk: config/test_catalog.toml scripts/test_catalog.py
	@python3 scripts/test_catalog.py --makefile $@
include build/test_catalog.mk

.PHONY: all format lint compile regress formal synth synth-generic synth-xilinx qor qor-report qor-record check validate-workflow workflow-smoke check-trike-sm3-sharing model-min-sum run-model-min-sum sweep-min-sum optimum-min-sum campaign-min-sum confirm-min-sum check-model-rtl check-model-rtl-bike128 software-trike-kem check-local-tools check-format-rtl lint-rtl lint-slang check-rtl formal-ct-select formal-ct-control formal-trike-poly-divstep-s1 formal-k-sign-overlap-scheduler formal-tile-scheduler vivado-synth vivado-synth-trike-unified-ksign vivado-impl-trike-kem-core vivado-impl-trike-poly-inv vivado-impl-trike-pseudohash vivado-impl-trike-encaps vivado-impl-trike-keygen vivado-impl-trike-decaps vivado-impl-trike-decaps-runtime vivado-impl-trike-kem-cores FORCE
.PHONY: gen-trike-minsum-kem-case formal-trike-kem-operation-control
.PHONY: tool-versions check-tool-versions check-filelists check-records check-validation-profiles check-trike-reference-data lint-verilator formal-fast formal-nightly formal-ct-control-extended ci-fast ci-smoke ci-nightly ci-kem-reference check-plan check-agent-workflow
.PHONY: python-sync format-changed format-all format-check

# Stable human and Agent entrypoints.
all: test

format:
	@if [ -z "$(strip $(FILES))" ]; then \
		echo 'FILES is required; use make format FILES="rtl/foo.sv tb/tb_foo.sv", make format-changed, or make format-all'; \
		exit 2; \
	fi
	@$(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $(FILES)
	@$(SV_DECL_FORMAT) $(FILES)

format-changed:
	@files="$$( { git diff --name-only --diff-filter=ACMR HEAD -- 'rtl/*.sv' 'tb/*.sv' 'formal/*.sv'; git ls-files --others --exclude-standard -- 'rtl/*.sv' 'tb/*.sv' 'formal/*.sv'; } | sort -u | tr '\n' ' ' )"; \
	if [ -z "$$files" ]; then echo 'No changed SystemVerilog files'; else $(MAKE) format FILES="$$files"; fi

format-all:
	@$(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $(MAINTAINED_SV)
	@$(SV_DECL_FORMAT) $(MAINTAINED_SV)

format-check: check-format-rtl

lint: check-rtl

compile:
	@mkdir -p build/compile/decoder build/compile/kem_ct_compare_select
	@$(REAL_VERILATOR) --cc --sv -Wall --quiet -I./rtl $(VERILATOR_WAIVER_FILE) -DBIKE_PARALLEL_L=$(BIKE_PARALLEL_L) --top-module decoder_top --Mdir build/compile/decoder $(RTL)
	@$(REAL_VERILATOR) --cc --sv -Wall --quiet $(VERILATOR_WAIVER_FILE) --top-module kem_ct_compare_select --Mdir build/compile/kem_ct_compare_select rtl/kem_ct_compare_select.sv

regress:
	@$(MAKE) test-bike-random BIKE_RANDOM_PARAM_SET=bike128 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-bike-unified-random BIKE_UNIFIED_RANDOM_PARAM_SETS=bike128 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_PARAM_SETS=trike160 TRIKE_UNIFIED_KSIGN_K=3 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_PARAM_SETS=trike160 TRIKE_UNIFIED_KSIGN_K=4 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1

# Daily static feedback; the owning test supplies behavioral evidence.
.PHONY: check-fast
check-fast: check-filelists lint-slang

# Explicit complete local qualification, including the validated tool baseline.
check: check-local-tools check-tool-versions check-records check-rtl formal-fast test compile synth

validate-workflow:
	@python3 scripts/run_validation.py --jobs $(VALIDATION_JOBS)

check-plan:
	@python3 scripts/check_plan.py $(if $(strip $(VALIDATION_PATHS)),--paths $(VALIDATION_PATHS),)

check-agent-workflow: check-validation-profiles
	@python3 -m pytest -q tests/test_agent_workflow.py

workflow-smoke:
	@$(MAKE) -C workflow-smoke check \
		SBY="$(if $(findstring /,$(SBY)),$(abspath $(SBY)),$(SBY))" \
		REAL_SBY="$(REAL_SBY)" \
		SBY_LOG_DIR="$(abspath $(SBY_LOG_DIR))" \
		CHECK_SUMMARY_PATH="$(abspath $(CHECK_SUMMARY_PATH))"
	@python3 scripts/validation_events.py record --layer workflow --name workflow-smoke --status PASS --signature workflow-smoke

python-sync:
	@$(UV) sync --frozen

$(TOY_CASE_SVH): FORCE scripts/gen_toy_case_fixture.py scripts/run_bike_random.py scripts/qc_matrix_data.py
	@python3 scripts/gen_toy_case_fixture.py --output $@

# Decoder and KEM unit tests. Each decoder test remains directly reproducible.

$(TRIKE_KEYGEN_REFERENCE_FIXTURE): scripts/gen_trike_keygen_fixture.py scripts/trike_fixture_utils.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_keygen_fixture.py \
		--kat "$(TRIKE_POLY_REFERENCE_KAT)" \
		--output "$@" \
		--candidate-count 16

$(TRIKE_POLY_REFERENCE_FIXTURE): scripts/gen_trike_poly_mul_fixture.py scripts/trike_fixture_utils.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_poly_mul_fixture.py \
		--kat "$(TRIKE_POLY_REFERENCE_KAT)" \
		--output "$@"

$(TRIKE_POLY_INV_REFERENCE_FIXTURE): scripts/gen_trike_poly_inv_fixture.py scripts/gen_trike_inv_schedule.py scripts/trike_fixture_utils.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_poly_inv_fixture.py \
		--kat "$(TRIKE_POLY_REFERENCE_KAT)" \
		--output "$@"

$(TRIKE_MINSUM_POLY_INV_FIXTURE): scripts/gen_trike_poly_inv_fixture.py scripts/gen_trike_inv_schedule.py scripts/trike_fixture_utils.py
	@python3 scripts/gen_trike_poly_inv_fixture.py \
		--input-seed 1 \
		--r-bits 12589 \
		--output "$@"

gen-trike-minsum-kem-case: $(MIN_SUM_MODEL)
	@python3 scripts/gen_trike_minsum_kem_case.py \
		--model "$(MIN_SUM_MODEL)" \
		--seed 1 \
		--profile "$(TRIKE_MINSUM_PROFILE)" \
		--work-dir "$(dir $(TRIKE_MINSUM_KEM_CASE))" \
		--decaps-message-svh "$(TRIKE_MINSUM_DECAPS_MESSAGE_FIXTURE)" \
		--runtime-decaps-svh "$(TRIKE_MINSUM_RUNTIME_DECAPS_FIXTURE)" \
		--output "$(TRIKE_MINSUM_KEM_CASE)"

$(TRIKE_ENCAPS_REFERENCE_FIXTURE): scripts/gen_trike_encaps_fixture.py scripts/trike_fixture_utils.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_encaps_fixture.py --kat "$(TRIKE_POLY_REFERENCE_KAT)" --output "$@"

$(TRIKE_DECAPS_SYNDROME_REFERENCE_FIXTURE): scripts/gen_trike_decaps_syndrome_fixture.py scripts/trike_fixture_utils.py $(TRIKE_POLY_REFERENCE_KAT)
	@python3 scripts/gen_trike_decaps_syndrome_fixture.py --kat "$(TRIKE_POLY_REFERENCE_KAT)" --output "$@"

check-trike-sm3-sharing:
	@$(YOSYS) -Q -s scripts/check_trike_sm3_sharing.ys >/dev/null
	@REAL_VERILATOR=$(REAL_VERILATOR) python3 scripts/check_trike_kem_asic_structure.py
	@echo "TRIKE SM3 sharing PASS: one sm3_compress per standalone composite or unified ASIC top"

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
	@for tool in $(REAL_VERILATOR) $(VERIBLE_FORMAT) $(VERIBLE_LINT) $(SLANG) $(YOSYS) $(SBY) $(REAL_SBY) $(Z3) $(COCOTB_CONFIG); do \
		command -v $$tool >/dev/null || { echo "missing required local tool: $$tool"; exit 1; }; \
	done
	@python3 -c 'import cocotb, pytest, yaml' || { echo "project Python dependencies missing; run uv sync --frozen"; exit 1; }
	@$(YOSYS) -m slang -Q -p 'help read_slang' | grep -q 'Read SystemVerilog sources' || { echo "missing Yosys read_slang frontend"; exit 1; }
	@echo "Local RTL tools PASS"

tool-versions:
	@python3 scripts/check_tool_versions.py

check-tool-versions:
	@python3 scripts/check_tool_versions.py --check

check-filelists:
	@python3 scripts/check_filelists.py

check-validation-profiles:
	@python3 scripts/validation_profiles.py

check-records:
	@python3 scripts/check_project_records.py

check-format-rtl:
	@for f in $(MAINTAINED_SV); do tmp_dir="$${TMPDIR:-/tmp}"; tmp=$$(mktemp "$$tmp_dir/format-rtl.XXXXXX.sv"); cp $$f $$tmp; $(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $$tmp; $(SV_DECL_FORMAT) $$tmp; cmp -s $$f $$tmp || { echo "$$f: formatting needed"; rm -f $$tmp; exit 1; }; rm -f $$tmp; done

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
	@python3 scripts/validation_events.py record --layer static --name check-rtl --status PASS --signature check-rtl

formal: formal-fast

formal-fast: formal-ct-select formal-ct-control formal-trike-kem-operation-control formal-trike-poly-divstep-s1 formal-k-sign-overlap-scheduler formal-tile-scheduler

formal-k-sign-overlap-scheduler:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove cover; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/k_sign_overlap_scheduler_$$task formal/k_sign_overlap_scheduler.sby $$task || exit 1; \
	done

formal-tile-scheduler:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove cover; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/tile_scheduler_$$task formal/tile_scheduler.sby $$task || exit 1; \
	done

formal-trike-poly-divstep-s1:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove_w2 prove_w8 cover_w2 cover_w8; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/trike_poly_divstep_s1_$$task formal/trike_poly_divstep_s1.sby $$task || exit 1; \
	done

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
	@for task in prove_words1 prove_words3 prove_runtime3 cover_words1 cover_words3 cover_runtime3; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/trike_ct_verify_stream_$$task formal/trike_ct_verify_stream.sby $$task || exit 1; \
	done

formal-ct-control-extended:
	@mkdir -p $(FORMAL_BUILD_DIR)
	@for task in prove_words16 prove_runtime16 cover_words16 cover_runtime16; do \
		$(SBY) -f -d $(FORMAL_BUILD_DIR)/trike_ct_verify_stream_$$task formal/trike_ct_verify_stream.sby $$task || exit 1; \
	done

ci-fast: check-fast test

ci-smoke:
	@$(MAKE) ci-fast
	@$(MAKE) regress

ci-nightly:
	@$(MAKE) ci-fast formal-fast formal-ct-control-extended
	@$(MAKE) test-bike-random BIKE_RANDOM_PARAM_SET=bike128 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=1
	@$(MAKE) test-bike-unified-random BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=$(CI_NIGHTLY_TRIALS)
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K=3 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=$(CI_NIGHTLY_TRIALS)
	@$(MAKE) test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K=4 BIKE_RANDOM_BASE_SEED=$(CI_SMOKE_SEED) BIKE_RANDOM_TRIALS=$(CI_NIGHTLY_TRIALS)

ci-kem-reference: check-trike-reference-data $(TRIKE_KEM_REFERENCE_TARGETS)

synth: synth-generic synth-xilinx
	@python3 scripts/validation_events.py record --layer synthesis --name synth --status PASS --signature "synth:$(LOCAL_SYNTH_TOP):$(LOCAL_SYNTH_SOURCES)"

synth-generic:
	@mkdir -p $(LOCAL_SYNTH_BUILD_DIR)
	@$(YOSYS) -m slang -ql $(LOCAL_SYNTH_BUILD_DIR)/generic.log -p 'read_slang --std 1800-2017 $(LOCAL_SYNTH_SOURCES) --top $(LOCAL_SYNTH_TOP); synth -top $(LOCAL_SYNTH_TOP); tee -o $(LOCAL_SYNTH_BUILD_DIR)/generic-stat.json stat -json'

synth-xilinx:
	@mkdir -p $(LOCAL_SYNTH_BUILD_DIR)
	@$(YOSYS) -m slang -ql $(LOCAL_SYNTH_BUILD_DIR)/xilinx.log -p 'read_slang --std 1800-2017 $(LOCAL_SYNTH_SOURCES) --top $(LOCAL_SYNTH_TOP); synth_xilinx -family xc7 -top $(LOCAL_SYNTH_TOP); tee -o $(LOCAL_SYNTH_BUILD_DIR)/xilinx-stat.json stat -json'

qor: test-kem-ct-compare-select formal-ct-select synth
	@$(MAKE) qor-report QOR_LINT_STATUS=NOT_RUN QOR_SIMULATION_STATUS=PASS QOR_FORMAL_STATUS=PASS

qor-report:
	@python3 scripts/report_qor.py --top $(QOR_TOP) --generic $(QOR_BUILD_DIR)/generic-stat.json --xilinx $(QOR_BUILD_DIR)/xilinx-stat.json --output-json $(QOR_REPORT_DIR)/latest.json --output-markdown $(QOR_REPORT_DIR)/latest.md --lint $(QOR_LINT_STATUS) --simulation $(QOR_SIMULATION_STATUS) --formal $(QOR_FORMAL_STATUS) $(if $(QOR_VALIDATION_RUN_ID),--validation-run-id $(QOR_VALIDATION_RUN_ID),)

qor-record: test-kem-ct-compare-select formal-ct-select synth
	@$(MAKE) qor-report QOR_REPORT_DIR=$(QOR_RECORD_DIR) QOR_LINT_STATUS=NOT_RUN QOR_SIMULATION_STATUS=PASS QOR_FORMAL_STATUS=PASS

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
