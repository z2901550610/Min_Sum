VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_LINT ?= verible-verilog-lint
SLANG ?= slang
VERILATOR ?= verilator
SBY ?= sby
YOSYS ?= yosys

BUILD_DIR ?= $(abspath ../build/workflow-smoke)
SIM_BUILD := $(BUILD_DIR)/sim-host-cocotb-2.0b$(if $(filter 1,$(WAVES)),-waves-lz4,)
FORMAL_BUILD := $(BUILD_DIR)/formal
SYNTH_BUILD := $(BUILD_DIR)/synth
WAVE_BUILD := $(BUILD_DIR)/waves
COUNTER_RTL ?= $(abspath rtl/workflow_counter.sv)
FORMAL_RTL := $(abspath formal/workflow_counter_formal.sv)

.PHONY: all format check-format lint compile test formal synth synth-generic synth-xilinx check check-failures clean

all: check

format:
	@$(VERIBLE_FORMAT) --inplace rtl/workflow_counter.sv formal/workflow_counter_formal.sv

check-format:
	@for f in rtl/workflow_counter.sv formal/workflow_counter_formal.sv; do \
		tmp=$$(mktemp /private/tmp/workflow-smoke-format.XXXXXX.sv); \
		cp $$f $$tmp; \
		$(VERIBLE_FORMAT) --inplace $$tmp; \
		cmp -s $$f $$tmp || { echo "$$f: formatting needed"; rm -f $$tmp; exit 1; }; \
		rm -f $$tmp; \
	done

lint: check-format
	@$(VERIBLE_LINT) rtl/workflow_counter.sv formal/workflow_counter_formal.sv
	@$(SLANG) --std 1800-2017 --single-unit --lint-only --quiet -Werror --top workflow_counter $(COUNTER_RTL)
	@$(VERILATOR) --lint-only --sv -Wall --top-module workflow_counter $(COUNTER_RTL)

compile:
	@mkdir -p $(BUILD_DIR)/compile
	@$(VERILATOR) --cc --sv -Wall --top-module workflow_counter --Mdir $(BUILD_DIR)/compile $(COUNTER_RTL)

test: sim

formal:
	@mkdir -p $(FORMAL_BUILD)
	@for task in prove cover; do \
		$(SBY) -f -d $(FORMAL_BUILD)/counter_$$task formal/counter.sby $$task || exit 1; \
	done

synth: synth-generic synth-xilinx

synth-generic:
	@mkdir -p $(SYNTH_BUILD)
	@$(YOSYS) -m slang -ql $(SYNTH_BUILD)/generic.log -p 'read_slang --std 1800-2017 $(COUNTER_RTL) --top workflow_counter; synth -top workflow_counter; tee -o $(SYNTH_BUILD)/generic-stat.json stat -json'

synth-xilinx:
	@mkdir -p $(SYNTH_BUILD)
	@$(YOSYS) -m slang -ql $(SYNTH_BUILD)/xilinx.log -p 'read_slang --std 1800-2017 $(COUNTER_RTL) --top workflow_counter; synth_xilinx -family xc7 -top workflow_counter; tee -o $(SYNTH_BUILD)/xilinx-stat.json stat -json'

check: lint compile test formal synth

check-failures:
	@$(HOST_PYTHON3) scripts/check_failures.py

clean::
	@echo "Generated products are under $(BUILD_DIR); remove that explicit directory when a clean rebuild is required."

TOPLEVEL_LANG := verilog
SIM := verilator
VERILOG_SOURCES := $(COUNTER_RTL)
COCOTB_TOPLEVEL := workflow_counter
COCOTB_TEST_MODULES := test_counter
PYTHONPATH := $(abspath tb)
COCOTB_RESULTS_FILE := $(BUILD_DIR)/results.xml
COCOTB_MAKEFILES := $(shell $(HOST_PYTHON3) -m cocotb_tools.config --makefiles)
PATH := $(dir $(HOST_COCOTB_CONFIG)):$(PATH)
export PATH
export PYTHONPATH

ifeq ($(WAVES),1)
LZ4_PREFIX ?= $(shell brew --prefix lz4)
COMPILE_ARGS += --trace-fst -CFLAGS "-I$(LZ4_PREFIX)/include" -LDFLAGS "-L$(LZ4_PREFIX)/lib -llz4"
SIM_ARGS += --trace --trace-file $(WAVE_BUILD)/dump.fst
CUSTOM_SIM_DEPS += $(WAVE_BUILD)

$(WAVE_BUILD):
	@mkdir -p $@
endif

include $(COCOTB_MAKEFILES)/Makefile.sim
