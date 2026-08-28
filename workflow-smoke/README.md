# SystemVerilog workflow smoke test

This independent four-bit counter proves the local workflow before it is applied
to project RTL. It is intentionally outside `rtl/` and the canonical design
filelists.

After `source scripts/eda-env.sh` from the repository root:

```sh
make -C workflow-smoke check
make -C workflow-smoke test WAVES=1
make -C workflow-smoke check-failures
```

`check` runs formatting checks, Verible/Slang/Verilator lint, elaboration,
cocotb simulation, SymbiYosys proof and cover, and generic plus Xilinx-oriented
Yosys synthesis. `check-failures` injects isolated faults under `build/` and
requires lint, simulation, and formal to reject them. Generated waveforms are
written to `build/workflow-smoke/waves/dump.fst` and can be opened with Surfer.

This PoC is workflow evidence only. It does not validate the decoder, KEM,
Vivado mapping, FPGA timing, or hardware behavior.
