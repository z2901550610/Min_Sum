CC ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra -pedantic
VERILATOR ?= verilator
VERILATOR_FLAGS ?= --binary --sv -Wall -Wno-fatal -I./tb

GOLDEN_BIN := golden/mdpc_min_sum_golden
BIKE_GOLDEN_BIN := golden/bike_l1_min_sum_golden
VECTOR_SVH := tb/generated/mdpc_demo_vectors.svh
RTL_CORE := rtl/mdpc_i_ram.sv rtl/mdpc_bit_ram_c.sv rtl/mdpc_row_state_ram_m.sv rtl/mdpc_sign_ram_s.sv rtl/mdpc_msg_ram_t.sv rtl/mdpc_msg_ram_u.sv rtl/mdpc_h_shift.sv rtl/mdpc_cnu_a.sv rtl/mdpc_cnu_b.sv rtl/mdpc_vnu.sv rtl/mdpc_decoder_demo.sv
RTL := rtl/mdpc_demo_pkg.sv $(RTL_CORE)
PAPER_RTL := tb/mdpc_paper_pkg.sv $(RTL_CORE)
PAPER80_SEED ?= 1
PAPER80_BASE_SEED ?= 1
PAPER80_TRIALS ?= 8
BIKE_SEED ?= 1
BIKE_BASE_SEED ?= 1
BIKE_TRIALS ?= 8
BIKE_CAL_BASE_SEED ?= 1
BIKE_CAL_TRIALS ?= 4

.PHONY: all golden sim test test-unit test-integration test-paper test-paper-random golden-self-test golden-paper80-once golden-paper80-batch bike-golden-self-test bike-golden-once bike-golden-batch bike-golden-calibrate FORCE

all: test

golden: $(VECTOR_SVH)

$(GOLDEN_BIN): golden/mdpc_min_sum_golden.c FORCE
	$(CC) $(CFLAGS) -o $@ $<

$(BIKE_GOLDEN_BIN): golden/bike_l1_min_sum_golden.c FORCE
	$(CC) $(CFLAGS) -o $@ $<

$(VECTOR_SVH): $(GOLDEN_BIN)
	./$(GOLDEN_BIN) --emit-svh $@

golden-self-test: $(GOLDEN_BIN)
	./$(GOLDEN_BIN) --self-test

golden-paper80-once: $(GOLDEN_BIN)
	./$(GOLDEN_BIN) --paper80-once --seed $(PAPER80_SEED)

golden-paper80-batch: $(GOLDEN_BIN)
	./$(GOLDEN_BIN) --paper80-batch --base-seed $(PAPER80_BASE_SEED) --trials $(PAPER80_TRIALS)

bike-golden-self-test: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --self-test

bike-golden-once: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --bike-l1-once --seed $(BIKE_SEED)

bike-golden-batch: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --bike-l1-batch --base-seed $(BIKE_BASE_SEED) --trials $(BIKE_TRIALS)

bike-golden-calibrate: $(BIKE_GOLDEN_BIN)
	./$(BIKE_GOLDEN_BIN) --bike-l1-calibrate --base-seed $(BIKE_CAL_BASE_SEED) --trials $(BIKE_CAL_TRIALS)

test: test-unit test-integration

test-unit: $(VECTOR_SVH)
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_mdpc_cnu_a rtl/mdpc_demo_pkg.sv rtl/mdpc_cnu_a.sv tb/tb_mdpc_cnu_a.sv
	./obj_dir/Vtb_mdpc_cnu_a
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_mdpc_cnu_b rtl/mdpc_demo_pkg.sv rtl/mdpc_cnu_b.sv tb/tb_mdpc_cnu_b.sv
	./obj_dir/Vtb_mdpc_cnu_b
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_mdpc_vnu rtl/mdpc_demo_pkg.sv rtl/mdpc_vnu.sv tb/tb_mdpc_vnu.sv
	./obj_dir/Vtb_mdpc_vnu

test-integration: $(VECTOR_SVH)
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_mdpc_decoder_demo $(RTL) tb/tb_mdpc_decoder_demo.sv
	./obj_dir/Vtb_mdpc_decoder_demo

test-paper:
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module tb_mdpc_decoder_paper $(PAPER_RTL) tb/tb_mdpc_decoder_paper.sv
	./obj_dir/Vtb_mdpc_decoder_paper

test-paper-random:
	python3 scripts/run_paper_random.py

sim: test
