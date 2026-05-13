CC ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra -pedantic
VERILATOR ?= ./scripts/verilator_quiet.py
REAL_VERILATOR ?= verilator
VERILATOR_LOG_DIR ?= build/logs/verilator
VERILATOR_FLAGS ?= --binary --sv -DBIKE_TOY_PARAMS -DBIKE_SIM_DEBUG -Wall -Wno-fatal -I./tb -I./rtl
SIM ?= ./scripts/run_quiet.py
VIVADO ?= vivado
VIVADO_BUILD_DIR ?= build/vivado
export REAL_VERILATOR
export VERILATOR_LOG_DIR

GOLDEN_BIN := golden/mdpc_min_sum_golden
BIKE_GOLDEN_BIN := golden/bike_l1_min_sum_golden
VECTOR_SVH := tb/generated/bike_demo_vectors.svh
RAM_I_HEX := rtl/generated/ram_i0_entries_test.hex rtl/generated/ram_i0_counts_test.hex rtl/generated/ram_i1_entries_test.hex rtl/generated/ram_i1_counts_test.hex rtl/generated/ram_i0_entries_l1.hex rtl/generated/ram_i0_counts_l1.hex rtl/generated/ram_i1_entries_l1.hex rtl/generated/ram_i1_counts_l1.hex
RAM_I_HEX_STAMP := rtl/generated/.ram_i_hex.stamp
RTL_CORE := rtl/decoder_top.sv rtl/ram_i.sv rtl/h_shift.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv rtl/decoder_ctrl.sv rtl/ram_c.sv rtl/ram_m.sv rtl/ram_s.sv rtl/ram_t.sv rtl/cnu_a.sv rtl/cnu_b.sv rtl/vnu.sv
RTL := $(RTL_CORE)
BIKE_SEED ?= 1
BIKE_BASE_SEED ?= 1
BIKE_TRIALS ?= 8
BIKE_CAL_BASE_SEED ?= 1
BIKE_CAL_TRIALS ?= 4
BIKE_RANDOM_BASE_SEED ?= 1
BIKE_RANDOM_TRIALS ?= 8
BIKE_RANDOM_ERROR_COUNT ?= 1
BIKE_RANDOM_RAM_LANE_DEPTH ?=
BIKE_RANDOM_SUPPORT_MODE ?= random

.PHONY: all golden sim test test-unit test-integration test-bike-random test-bike-overflow-cases test-bike-l1-cycle vivado-synth golden-self-test bike-golden-self-test bike-golden-once bike-golden-batch bike-golden-calibrate FORCE

all: test

golden: $(VECTOR_SVH)

$(GOLDEN_BIN): golden/mdpc_min_sum_golden.c FORCE
	@$(CC) $(CFLAGS) -o $@ $<

$(BIKE_GOLDEN_BIN): golden/bike_l1_min_sum_golden.c FORCE
	@$(CC) $(CFLAGS) -o $@ $<

$(VECTOR_SVH): $(GOLDEN_BIN)
	@./$(GOLDEN_BIN) --emit-svh $@

$(RAM_I_HEX_STAMP): rtl/bike_pkg.sv scripts/gen_qc_first_columns.py scripts/ram_i_hex.py
	@python3 scripts/gen_qc_first_columns.py --input rtl/bike_pkg.sv --output-dir rtl/generated/
	@touch $@

$(RAM_I_HEX): $(RAM_I_HEX_STAMP)
	@if [ ! -f "$@" ]; then python3 scripts/gen_qc_first_columns.py --input rtl/bike_pkg.sv --output-dir rtl/generated/; touch $(RAM_I_HEX_STAMP); fi

golden-self-test: $(GOLDEN_BIN)
	@./$(GOLDEN_BIN) --self-test

bike-golden-self-test: $(BIKE_GOLDEN_BIN)
	@./$(BIKE_GOLDEN_BIN) --self-test

bike-golden-once: $(BIKE_GOLDEN_BIN)
	@./$(BIKE_GOLDEN_BIN) --bike-l1-once --seed $(BIKE_SEED)

bike-golden-batch: $(BIKE_GOLDEN_BIN)
	@./$(BIKE_GOLDEN_BIN) --bike-l1-batch --base-seed $(BIKE_BASE_SEED) --trials $(BIKE_TRIALS)

bike-golden-calibrate: $(BIKE_GOLDEN_BIN)
	@./$(BIKE_GOLDEN_BIN) --bike-l1-calibrate --base-seed $(BIKE_CAL_BASE_SEED) --trials $(BIKE_CAL_TRIALS)

test: test-unit test-integration

test-unit: $(VECTOR_SVH) $(RAM_I_HEX)
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

test-integration: $(VECTOR_SVH) $(RAM_I_HEX)
	@if grep -nE '\b(generate|genvar|endgenerate)\b' rtl/decoder_top.sv; then echo "decoder_top.sv must not use generate/genvar for RAM instantiation"; exit 1; fi
	@if grep -nE '\bram_[mstu]_debug_mem\b' rtl/decoder_top.sv; then echo "decoder_top.sv must not use aggregate RAM debug mirror arrays"; exit 1; fi
	@$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_decoder_top $(RTL) tb/tb_decoder_top.sv
	@$(SIM) ./obj_dir/Vtb_decoder_top +verilator+quiet

test-bike-random:
	@python3 scripts/run_bike_random.py --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) --error-count $(BIKE_RANDOM_ERROR_COUNT) --support-mode $(BIKE_RANDOM_SUPPORT_MODE) $(if $(BIKE_RANDOM_RAM_LANE_DEPTH),--ram-lane-depth $(BIKE_RANDOM_RAM_LANE_DEPTH),) --verilator $(VERILATOR)

test-bike-overflow-cases:
	@python3 scripts/run_bike_random.py --base-seed $(BIKE_RANDOM_BASE_SEED) --trials 4 --r 257 --w 71 --i-max 2 --error-count $(BIKE_RANDOM_ERROR_COUNT) --timeout-cycles 1000000 --ram-lane-depth 40 --support-mode sweep --out-dir tb/generated/bike_overflow_cases --verilator $(VERILATOR)

test-bike-l1-cycle: $(RAM_I_HEX)
	@$(VERILATOR) --binary --sv -DBIKE_PKG_EXTERNAL -DBIKE_SIM_DEBUG -Wall -Wno-fatal -I./tb -I./rtl --top-module tb_bike_l1_cycle rtl/bike_pkg.sv $(RTL) tb/tb_bike_l1_cycle.sv
	@$(SIM) ./obj_dir/Vtb_bike_l1_cycle +verilator+quiet

vivado-synth: $(RAM_I_HEX)
	@mkdir -p $(VIVADO_BUILD_DIR)
	@$(VIVADO) -mode batch -source scripts/vivado_synth.tcl -tclargs $(VIVADO_BUILD_DIR)

sim: test
