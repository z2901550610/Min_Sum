VERILATOR ?= ./scripts/verilator_quiet.py
REAL_VERILATOR ?= verilator
VERILATOR_LOG_DIR ?= build/logs/verilator
BIKE_PARALLEL_L ?= 32
BIKE_TOY_PARALLEL_L ?= 8
BIKE_SYNTH_PARAM ?=
BIKE_SYNTH_PARALLEL_L ?= 32
BIKE_SYNTH_COLS_PER_TILE ?=
VERILATOR_FLAGS ?= --binary --sv -DBIKE_TOY_PARAMS -DBIKE_PARALLEL_L=$(BIKE_TOY_PARALLEL_L) -DBIKE_SIM_DEBUG -Wall -Wno-fatal -I./tb -I./rtl
SIM ?= ./scripts/run_quiet.py
VIVADO ?= vivado
VIVADO_BUILD_DIR ?= build/vivado
CC ?= cc
CFLAGS ?= -O3 -std=c11 -Wall -Wextra -Wpedantic -pthread
MODEL_BUILD_DIR ?= build/model
MIN_SUM_MODEL ?= $(MODEL_BUILD_DIR)/min_sum_model
VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_FORMAT_FLAGS ?= --port_declarations_alignment=align --module_net_variable_alignment=align --formal_parameters_alignment=align
VERIBLE_LINT ?= verible-verilog-lint
VERIBLE_LINT_FLAGS ?= --rules_config .rules.verible_lint
SV_DECL_FORMAT ?= python3 scripts/format_sv_decls.py
export REAL_VERILATOR
export VERILATOR_LOG_DIR
export BIKE_PARALLEL_L

TOY_CASE_SVH := tb/generated/bike_toy_case.svh
RTL_PKG := rtl/bike_pkg.sv
RTL_CORE := rtl/reset_sync.sv rtl/decoder_profile_config.sv rtl/ram_bram.sv rtl/ram_i.sv rtl/barrel_rotate.sv rtl/edge_addr_gen.sv rtl/tile_scheduler.sv rtl/ram_m.sv rtl/ram_s.sv rtl/k_sign_update.sv rtl/k_sign_reconstruct.sv rtl/k_sign_correction.sv rtl/ram_k_tile.sv rtl/k_sign_selector.sv rtl/ram_k_global.sv rtl/ram_syndrome.sv rtl/ram_accum.sv rtl/ram_t.sv rtl/msg_tc_to_signmag_sat.sv rtl/vnu.sv rtl/ram_decision.sv rtl/cnu_a.sv rtl/cnu_b.sv rtl/msg_signmag_to_tc.sv rtl/decoder_top.sv
RTL := $(RTL_PKG) $(RTL_CORE)
MAINTAINED_SV := $(sort $(wildcard rtl/*.sv) $(wildcard tb/*.sv))
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
TRIKE_UNIFIED_KSIGN_PARALLEL_L ?= 16
TRIKE_UNIFIED_KSIGN_COLS_PER_TILE ?= 1168
TRIKE_UNIFIED_KSIGN_PARAM_SETS ?= trike128 trike160 trike256 trike384 trike512
TRIKE_UNIFIED_KSIGN_TIMEOUT_CYCLES ?= 40000000

.PHONY: all sim test test-unit test-integration test-bike-random test-bike-unified-random test-trike-unified-ksign-random model-min-sum run-model-min-sum sweep-min-sum optimum-min-sum campaign-min-sum confirm-min-sum check-model-rtl check-model-rtl-bike128 format-rtl check-format-rtl lint-rtl vivado-synth vivado-synth-trike-unified-ksign FORCE

all: test

$(TOY_CASE_SVH): FORCE scripts/gen_toy_case_fixture.py scripts/run_bike_random.py scripts/qc_matrix_data.py
	@python3 scripts/gen_toy_case_fixture.py --output $@

test: test-unit test-integration

test-unit:
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
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_k_sign_update rtl/bike_pkg.sv rtl/ram_bram.sv rtl/barrel_rotate.sv rtl/k_sign_update.sv rtl/k_sign_reconstruct.sv rtl/ram_k_tile.sv rtl/k_sign_selector.sv rtl/ram_k_global.sv tb/tb_k_sign_update.sv
	@$(SIM) ./obj_dir/Vtb_k_sign_update +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_accum rtl/bike_pkg.sv rtl/barrel_rotate.sv rtl/ram_accum.sv tb/tb_ram_accum.sv
	@$(SIM) ./obj_dir/Vtb_ram_accum +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_t rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_t.sv tb/tb_ram_t.sv
	@$(SIM) ./obj_dir/Vtb_ram_t +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_decision rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_decision.sv tb/tb_ram_decision.sv
	@$(SIM) ./obj_dir/Vtb_ram_decision +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_syndrome rtl/bike_pkg.sv rtl/ram_bram.sv rtl/ram_syndrome.sv tb/tb_ram_syndrome.sv
	@$(SIM) ./obj_dir/Vtb_ram_syndrome +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_a rtl/bike_pkg.sv rtl/cnu_a.sv tb/tb_cnu_a.sv
	@$(SIM) ./obj_dir/Vtb_cnu_a +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_b rtl/bike_pkg.sv rtl/cnu_b.sv tb/tb_cnu_b.sv
	@$(SIM) ./obj_dir/Vtb_cnu_b +verilator+quiet

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
		python3 scripts/run_bike_random.py --unified --param-set $$param_set --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) $(BIKE_RANDOM_ERROR_ARG) --parallel-l $(TRIKE_UNIFIED_KSIGN_PARALLEL_L) --cols-per-tile $(TRIKE_UNIFIED_KSIGN_COLS_PER_TILE) --timeout-cycles $(TRIKE_UNIFIED_KSIGN_TIMEOUT_CYCLES) --out-dir tb/generated/trike_unified_ksign/$$param_set --verilator $(VERILATOR); \
	done

model-min-sum: $(MIN_SUM_MODEL)

$(MIN_SUM_MODEL): scripts/min_sum_model.c
	@mkdir -p $(MODEL_BUILD_DIR)
	@$(CC) $(CFLAGS) $< -o $@

run-model-min-sum: model-min-sum
	@$(MIN_SUM_MODEL) --profile bike128 --seed 1 --trials 1

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

format-rtl:
	@$(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $(MAINTAINED_SV)
	@$(SV_DECL_FORMAT) $(MAINTAINED_SV)

check-format-rtl:
	@for f in $(MAINTAINED_SV); do tmp=$$(mktemp /private/tmp/format-rtl.XXXXXX.sv); cp $$f $$tmp; $(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $$tmp; $(SV_DECL_FORMAT) $$tmp; cmp -s $$f $$tmp || { echo "$$f: formatting needed"; rm -f $$tmp; exit 1; }; rm -f $$tmp; done

lint-rtl:
	@$(VERIBLE_LINT) $(VERIBLE_LINT_FLAGS) $(MAINTAINED_SV)

vivado-synth:
	@mkdir -p $(VIVADO_BUILD_DIR)
	@BIKE_PARAM_DEFINE=$(BIKE_SYNTH_PARAM) BIKE_PARALLEL_L=$(BIKE_SYNTH_PARALLEL_L) $(if $(BIKE_SYNTH_COLS_PER_TILE),BIKE_COLS_PER_TILE=$(BIKE_SYNTH_COLS_PER_TILE),) $(VIVADO) -mode batch -source scripts/vivado_synth.tcl -tclargs $(VIVADO_BUILD_DIR)

vivado-synth-trike-unified-ksign:
	@$(MAKE) vivado-synth BIKE_SYNTH_PARAM=TRIKE_UNIFIED_PARAMS BIKE_SYNTH_PARALLEL_L=$(TRIKE_UNIFIED_KSIGN_PARALLEL_L) BIKE_SYNTH_COLS_PER_TILE=$(TRIKE_UNIFIED_KSIGN_COLS_PER_TILE) VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)/trike_unified_ksign_l$(TRIKE_UNIFIED_KSIGN_PARALLEL_L)

sim: test
