---
name: rtl-synthesis
description: Run and interpret local Yosys plus Slang synthesis for repository RTL, or route physical implementation questions to comparable Vivado runs.
---

# RTL synthesis

Source `scripts/eda-env.sh` and use the repository Make targets. Confirm the top,
ordered sources, defines, parameters, and intended family before interpreting a
result. Local `make synth` uses Yosys with the Slang frontend for generic and
Xilinx-oriented structural estimates. Inspect warnings and optimized-away logic.
For XPM/RAMB mapping, utilization, routing, clock frequency, or timing claims,
use the repository Vivado Tcl script directly in the Windows Tcl Console or
batch mode; Make wrappers are optional. Record device, Vivado version, XDC,
parameter set, `L`, `K`, memory geometry, run ID, and report stage.
