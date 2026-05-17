VERILATOR ?= ./scripts/verilator_quiet.py
REAL_VERILATOR ?= verilator
VERILATOR_LOG_DIR ?= build/logs/verilator
VERILATOR_FLAGS ?= --binary --sv -DBIKE_TOY_PARAMS -DBIKE_SIM_DEBUG -Wall -Wno-fatal -I./tb -I./rtl
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

VECTOR_SVH := tb/generated/bike_demo_vectors.svh
RAM_I_HEX := rtl/generated/ram_i0_entries_test.hex rtl/generated/ram_i0_counts_test.hex rtl/generated/ram_i1_entries_test.hex rtl/generated/ram_i1_counts_test.hex rtl/generated/ram_i0_entries_l1.hex rtl/generated/ram_i0_counts_l1.hex rtl/generated/ram_i1_entries_l1.hex rtl/generated/ram_i1_counts_l1.hex
RAM_I_HEX_STAMP := rtl/generated/.ram_i_hex.stamp
RTL_PKG := rtl/bike_pkg.sv
RTL_CORE := rtl/decoder_top.sv rtl/ram_i.sv rtl/h_shift.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv rtl/decoder_ctrl.sv rtl/ram_c.sv rtl/ram_m.sv rtl/ram_s.sv rtl/ram_syndrome.sv rtl/ram_t.sv rtl/cnu_a.sv rtl/cnu_b.sv rtl/vnu.sv
RTL := $(RTL_PKG) $(RTL_CORE)
MAINTAINED_SV := $(sort $(wildcard rtl/*.sv) $(wildcard tb/*.sv))
BIKE_RANDOM_BASE_SEED ?= 1
BIKE_RANDOM_TRIALS ?= 8
BIKE_RANDOM_ERROR_COUNT ?= 1

.PHONY: all sim test test-unit test-integration test-bike-random format-rtl check-format-rtl lint-rtl vivado-synth

all: test

$(RAM_I_HEX_STAMP): rtl/bike_pkg.sv scripts/gen_qc_first_columns.py scripts/ram_i_hex.py scripts/qc_matrix_data.py
	@python3 scripts/gen_qc_first_columns.py --input rtl/bike_pkg.sv --output-dir rtl/generated/
	@touch $@

$(RAM_I_HEX): $(RAM_I_HEX_STAMP)
	@if [ ! -f "$@" ]; then python3 scripts/gen_qc_first_columns.py --input rtl/bike_pkg.sv --output-dir rtl/generated/; touch $(RAM_I_HEX_STAMP); fi

test: test-unit test-integration

test-unit: $(VECTOR_SVH) $(RAM_I_HEX_STAMP)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_msg_codec rtl/bike_pkg.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv tb/tb_msg_codec.sv
	@$(SIM) ./obj_dir/Vtb_msg_codec +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_i rtl/bike_pkg.sv rtl/ram_i.sv tb/tb_ram_i.sv
	@$(SIM) ./obj_dir/Vtb_ram_i +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_blocks rtl/bike_pkg.sv rtl/ram_c.sv rtl/ram_m.sv rtl/ram_s.sv rtl/ram_t.sv tb/tb_ram_blocks.sv
	@$(SIM) ./obj_dir/Vtb_ram_blocks +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_h_shift rtl/bike_pkg.sv rtl/h_shift.sv tb/tb_h_shift.sv
	@$(SIM) ./obj_dir/Vtb_h_shift +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_a rtl/bike_pkg.sv rtl/cnu_a.sv tb/tb_cnu_a.sv
	@$(SIM) ./obj_dir/Vtb_cnu_a +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_b rtl/bike_pkg.sv rtl/cnu_b.sv tb/tb_cnu_b.sv
	@$(SIM) ./obj_dir/Vtb_cnu_b +verilator+quiet
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_vnu rtl/bike_pkg.sv rtl/vnu.sv tb/tb_vnu.sv
	@$(SIM) ./obj_dir/Vtb_vnu +verilator+quiet

test-integration: $(VECTOR_SVH) $(RAM_I_HEX_STAMP)
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_decoder_top $(RTL) tb/tb_decoder_top.sv
	@$(SIM) ./obj_dir/Vtb_decoder_top +verilator+quiet

test-bike-random:
	@python3 scripts/run_bike_random.py --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) --error-count $(BIKE_RANDOM_ERROR_COUNT) --verilator $(VERILATOR)

format-rtl:
	@$(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $(MAINTAINED_SV)
	@$(SV_DECL_FORMAT) $(MAINTAINED_SV)

check-format-rtl:
	@for f in $(MAINTAINED_SV); do tmp=$$(mktemp /private/tmp/format-rtl.XXXXXX.sv); cp $$f $$tmp; $(VERIBLE_FORMAT) $(VERIBLE_FORMAT_FLAGS) --inplace $$tmp; $(SV_DECL_FORMAT) $$tmp; cmp -s $$f $$tmp || { echo "$$f: formatting needed"; rm -f $$tmp; exit 1; }; rm -f $$tmp; done

lint-rtl:
	@$(VERIBLE_LINT) $(VERIBLE_LINT_FLAGS) $(MAINTAINED_SV)

vivado-synth: $(RAM_I_HEX_STAMP)
	@mkdir -p $(VIVADO_BUILD_DIR)
	@$(VIVADO) -mode batch -source scripts/vivado_synth.tcl -tclargs $(VIVADO_BUILD_DIR)

sim: test
