VERILATOR ?= ./scripts/verilator_quiet.py
REAL_VERILATOR ?= verilator
VERILATOR_LOG_DIR ?= build/logs/verilator
BIKE_PARALLEL_L ?= 8
BIKE_SYNTH_PARAM ?= BIKE_128_PARAMS
BIKE_SYNTH_PARALLEL_L ?= 16
BIKE_SYNTH_C_TILE ?= 288
VERILATOR_FLAGS ?= --binary --sv -DBIKE_TOY_PARAMS -DBIKE_PARALLEL_L=$(BIKE_PARALLEL_L) -DBIKE_SIM_DEBUG -Wall -Wno-fatal -I./tb -I./rtl
SIM ?= ./scripts/run_quiet.py
VIVADO ?= vivado
VIVADO_BUILD_DIR ?= build/vivado
VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_FORMAT_FLAGS ?= --port_declarations_alignment=align --module_net_variable_alignment=align --formal_parameters_alignment=align
VERIBLE_LINT ?= verible-verilog-lint
VERIBLE_LINT_FLAGS ?= --rules_config .rules.verible_lint
SV_DECL_FORMAT ?= python3 scripts/format_sv_decls.py
export REAL_VERILATOR
export VERILATOR_LOG_DIR
export BIKE_PARALLEL_L

VECTOR_SVH := tb/generated/bike_demo_vectors.svh
TOY_CASE_SVH := tb/generated/bike_toy_case.svh
RTL_PKG := rtl/bike_pkg.sv
RTL_CORE := rtl/reset_sync.sv rtl/h_matrix_mem.sv rtl/edge_addr_gen.sv rtl/tile_scheduler.sv rtl/check_state_ram.sv rtl/msg_sign_ram.sv rtl/tile_accum_ram.sv rtl/c2v_cache_ram.sv rtl/msg_tc_to_signmag_sat.sv rtl/vnu_update.sv rtl/decision_ram.sv rtl/cnu_a.sv rtl/cnu_b.sv rtl/msg_signmag_to_tc.sv rtl/decoder_top.sv
RTL := $(RTL_PKG) $(RTL_CORE)
MAINTAINED_SV := $(sort $(wildcard rtl/*.sv) $(wildcard tb/*.sv))
BIKE_RANDOM_BASE_SEED ?= 1
BIKE_RANDOM_TRIALS ?= 1
BIKE_RANDOM_PARAM_SET ?= bike128
BIKE_RANDOM_ERROR_COUNT ?=
BIKE_RANDOM_PARALLEL_L ?= $(BIKE_PARALLEL_L)
BIKE_RANDOM_C_TILE ?= 288
BIKE_RANDOM_TIMEOUT_CYCLES ?= 800000
BIKE_RANDOM_ERROR_ARG := $(if $(BIKE_RANDOM_ERROR_COUNT),--error-count $(BIKE_RANDOM_ERROR_COUNT),)

.PHONY: all sim test test-unit test-integration test-bike-random format-rtl check-format-rtl lint-rtl vivado-synth FORCE

all: test

$(TOY_CASE_SVH): FORCE scripts/gen_toy_case_fixture.py scripts/run_bike_random.py scripts/qc_matrix_data.py
	@python3 scripts/gen_toy_case_fixture.py --output $@

test: test-unit test-integration

test-unit: $(VECTOR_SVH)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_reset_sync rtl/reset_sync.sv tb/tb_reset_sync.sv
	@$(SIM) ./obj_dir/Vtb_reset_sync +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_msg_codec rtl/bike_pkg.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv tb/tb_msg_codec.sv
	@$(SIM) ./obj_dir/Vtb_msg_codec +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_tile_scheduler rtl/bike_pkg.sv rtl/tile_scheduler.sv tb/tb_tile_scheduler.sv
	@$(SIM) ./obj_dir/Vtb_tile_scheduler +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_edge_addr_gen rtl/bike_pkg.sv rtl/edge_addr_gen.sv tb/tb_edge_addr_gen.sv
	@$(SIM) ./obj_dir/Vtb_edge_addr_gen +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_h_matrix_mem rtl/bike_pkg.sv rtl/h_matrix_mem.sv tb/tb_h_matrix_mem.sv
	@$(SIM) ./obj_dir/Vtb_h_matrix_mem +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_check_state_ram rtl/bike_pkg.sv rtl/check_state_ram.sv tb/tb_check_state_ram.sv
	@$(SIM) ./obj_dir/Vtb_check_state_ram +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_tile_accum_ram rtl/bike_pkg.sv rtl/tile_accum_ram.sv tb/tb_tile_accum_ram.sv
	@$(SIM) ./obj_dir/Vtb_tile_accum_ram +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_c2v_cache_ram rtl/bike_pkg.sv rtl/c2v_cache_ram.sv tb/tb_c2v_cache_ram.sv
	@$(SIM) ./obj_dir/Vtb_c2v_cache_ram +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_decision_ram rtl/bike_pkg.sv rtl/decision_ram.sv tb/tb_decision_ram.sv
	@$(SIM) ./obj_dir/Vtb_decision_ram +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_a rtl/bike_pkg.sv rtl/cnu_a.sv tb/tb_cnu_a.sv
	@$(SIM) ./obj_dir/Vtb_cnu_a +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_b rtl/bike_pkg.sv rtl/cnu_b.sv tb/tb_cnu_b.sv
	@$(SIM) ./obj_dir/Vtb_cnu_b +verilator+quiet

test-integration: $(TOY_CASE_SVH)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_decoder_top $(RTL) tb/tb_decoder_top.sv
	@$(SIM) ./obj_dir/Vtb_decoder_top +verilator+quiet

test-bike-random:
	@python3 scripts/run_bike_random.py --param-set $(BIKE_RANDOM_PARAM_SET) --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) $(BIKE_RANDOM_ERROR_ARG) --parallel-l $(BIKE_RANDOM_PARALLEL_L) --c-tile $(BIKE_RANDOM_C_TILE) --timeout-cycles $(BIKE_RANDOM_TIMEOUT_CYCLES) --verilator $(VERILATOR)

format-rtl:
	@$(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $(MAINTAINED_SV)
	@$(SV_DECL_FORMAT) $(MAINTAINED_SV)

check-format-rtl:
	@for f in $(MAINTAINED_SV); do tmp=$$(mktemp /private/tmp/format-rtl.XXXXXX.sv); cp $$f $$tmp; $(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $$tmp; $(SV_DECL_FORMAT) $$tmp; cmp -s $$f $$tmp || { echo "$$f: formatting needed"; rm -f $$tmp; exit 1; }; rm -f $$tmp; done

lint-rtl:
	@$(VERIBLE_LINT) $(VERIBLE_LINT_FLAGS) $(MAINTAINED_SV)

vivado-synth:
	@mkdir -p $(VIVADO_BUILD_DIR)
	@BIKE_PARAM_DEFINE=$(BIKE_SYNTH_PARAM) BIKE_PARALLEL_L=$(BIKE_SYNTH_PARALLEL_L) BIKE_C_TILE=$(BIKE_SYNTH_C_TILE) $(VIVADO) -mode batch -source scripts/vivado_synth.tcl -tclargs $(VIVADO_BUILD_DIR)

sim: test
