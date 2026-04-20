CC ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra -pedantic
VERILATOR ?= verilator
VERILATOR_FLAGS ?= --binary --sv -Wall -Wno-fatal -I./tb -I./rtl

GOLDEN_BIN := golden/mdpc_min_sum_golden
BIKE_GOLDEN_BIN := golden/bike_l1_min_sum_golden
VECTOR_SVH := tb/generated/bike_demo_vectors.svh
QC_FIRST_COL_SVH := rtl/generated/qc_first_columns.svh
RTL_CORE := rtl/ram_i.sv rtl/h_shift.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv rtl/decoder_edge_meta.sv rtl/decoder_ctrl.sv rtl/ram_c.sv rtl/ram_m.sv rtl/ram_s.sv rtl/ram_t.sv rtl/ram_u.sv rtl/cnu_a.sv rtl/cnu_b.sv rtl/vnu.sv rtl/decoder_top.sv
RTL := rtl/bike_pkg.sv $(RTL_CORE)
BIKE_SEED ?= 1
BIKE_BASE_SEED ?= 1
BIKE_TRIALS ?= 8
BIKE_CAL_BASE_SEED ?= 1
BIKE_CAL_TRIALS ?= 4
BIKE_RANDOM_BASE_SEED ?= 1
BIKE_RANDOM_TRIALS ?= 8
BIKE_RANDOM_ERROR_COUNT ?= 1

.PHONY: all golden sim test test-unit test-integration test-bike-random golden-self-test bike-golden-self-test bike-golden-once bike-golden-batch bike-golden-calibrate FORCE

all: test

golden: $(VECTOR_SVH)

$(GOLDEN_BIN): golden/mdpc_min_sum_golden.c FORCE
	$(CC) $(CFLAGS) -o $@ $<

$(BIKE_GOLDEN_BIN): golden/bike_l1_min_sum_golden.c FORCE
	$(CC) $(CFLAGS) -o $@ $<

$(VECTOR_SVH): $(GOLDEN_BIN)
	./$(GOLDEN_BIN) --emit-svh $@

$(QC_FIRST_COL_SVH): rtl/bike_pkg.sv scripts/gen_qc_first_columns.py
	python3 scripts/gen_qc_first_columns.py --input rtl/bike_pkg.sv --output $@

golden-self-test: $(GOLDEN_BIN)
	./$(GOLDEN_BIN) --self-test

bike-golden-self-test: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --self-test

bike-golden-once: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --bike-l1-once --seed $(BIKE_SEED)

bike-golden-batch: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --bike-l1-batch --base-seed $(BIKE_BASE_SEED) --trials $(BIKE_TRIALS)

bike-golden-calibrate: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --bike-l1-calibrate --base-seed $(BIKE_CAL_BASE_SEED) --trials $(BIKE_CAL_TRIALS)

test: test-unit test-integration

test-unit: $(VECTOR_SVH) $(QC_FIRST_COL_SVH)
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_msg_codec rtl/bike_pkg.sv rtl/msg_signmag_to_tc.sv rtl/msg_tc_to_signmag_sat.sv tb/tb_msg_codec.sv
	./obj_dir/Vtb_msg_codec
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_i rtl/bike_pkg.sv rtl/ram_i.sv tb/tb_ram_i.sv
	./obj_dir/Vtb_ram_i
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_ram_blocks rtl/bike_pkg.sv rtl/ram_c.sv rtl/ram_m.sv rtl/ram_s.sv rtl/ram_t.sv rtl/ram_u.sv tb/tb_ram_blocks.sv
	./obj_dir/Vtb_ram_blocks
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_h_shift rtl/bike_pkg.sv rtl/h_shift.sv tb/tb_h_shift.sv
	./obj_dir/Vtb_h_shift
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_a rtl/bike_pkg.sv rtl/cnu_a.sv tb/tb_cnu_a.sv
	./obj_dir/Vtb_cnu_a
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_cnu_b rtl/bike_pkg.sv rtl/cnu_b.sv tb/tb_cnu_b.sv
	./obj_dir/Vtb_cnu_b
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_vnu rtl/bike_pkg.sv rtl/vnu.sv tb/tb_vnu.sv
	./obj_dir/Vtb_vnu

test-integration: $(VECTOR_SVH) $(QC_FIRST_COL_SVH)
	@if grep -nE '\b(generate|genvar|endgenerate)\b' rtl/decoder_top.sv; then echo "decoder_top.sv must not use generate/genvar for RAM instantiation"; exit 1; fi
	@if grep -nE '\bram_[mstu]_debug_mem\b' rtl/decoder_top.sv; then echo "decoder_top.sv must not use aggregate RAM debug mirror arrays"; exit 1; fi
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_decoder_top $(RTL) tb/tb_decoder_top.sv
	./obj_dir/Vtb_decoder_top

test-bike-random:
	python3 scripts/run_bike_random.py --base-seed $(BIKE_RANDOM_BASE_SEED) --trials $(BIKE_RANDOM_TRIALS) --error-count $(BIKE_RANDOM_ERROR_COUNT) --verilator $(VERILATOR)

sim: test
