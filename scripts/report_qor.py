#!/usr/bin/env python3
"""Convert Yosys stat JSON into a bounded local QoR report."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import subprocess
from pathlib import Path
from typing import Any


def load_design(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    return payload.get("design", {})


def sum_matching(cells: dict[str, int], predicate: Any) -> int:
    return sum(count for cell_type, count in cells.items() if predicate(cell_type))


def git_value(*args: str) -> str:
    result = subprocess.run(
        ["git", *args], text=True, capture_output=True, check=False
    )
    return result.stdout.strip() if result.returncode == 0 else "unknown"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--top", required=True)
    parser.add_argument("--generic", type=Path, required=True)
    parser.add_argument("--xilinx", type=Path, required=True)
    parser.add_argument("--output-json", type=Path, required=True)
    parser.add_argument("--output-markdown", type=Path, required=True)
    parser.add_argument("--lint", default="NOT_RUN")
    parser.add_argument("--simulation", default="NOT_RUN")
    parser.add_argument("--formal", default="NOT_RUN")
    args = parser.parse_args()

    generic = load_design(args.generic)
    xilinx = load_design(args.xilinx)
    generic_cells = generic.get("num_cells_by_type", {})
    xilinx_cells = xilinx.get("num_cells_by_type", {})

    lut = sum_matching(
        xilinx_cells,
        lambda name: name == "$lut" or name.startswith("LUT"),
    )
    ff = sum_matching(
        xilinx_cells,
        lambda name: name.startswith("FD") or "DFF" in name,
    )
    bram = sum_matching(xilinx_cells, lambda name: name.startswith("RAMB"))
    dsp = sum_matching(xilinx_cells, lambda name: name.startswith("DSP"))
    dirty = bool(git_value("status", "--porcelain"))

    report = {
        "timestamp": dt.datetime.now(dt.timezone.utc).isoformat(),
        "git_commit": git_value("rev-parse", "HEAD"),
        "git_dirty": dirty,
        "tool": "Yosys",
        "top": args.top,
        "parameters": {},
        "verification": {
            "lint": args.lint,
            "simulation": args.simulation,
            "formal": args.formal,
        },
        "latency_cycles": None,
        "throughput": None,
        "generic_synthesis": {
            "cells": generic.get("num_cells"),
            "ff": sum_matching(generic_cells, lambda name: "DFF" in name),
        },
        "fpga_estimate": {
            "family": "xc7",
            "lut": lut,
            "ff": ff,
            "bram": bram,
            "dsp": dsp,
            "mapped_cells": xilinx.get("num_cells"),
        },
        "not_verified": [
            "Vivado synthesis",
            "Vivado implementation",
            "post-route timing",
            "physical FPGA behavior",
        ],
    }

    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_markdown.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(
        json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )

    markdown = f"""# Local QoR Report

- Top: `{args.top}`
- Git commit: `{report['git_commit']}`
- Dirty worktree: `{str(dirty).lower()}`
- Lint / simulation / formal: `{args.lint}` / `{args.simulation}` / `{args.formal}`

| Metric | Value |
| --- | ---: |
| Generic cells | {report['generic_synthesis']['cells']} |
| Xilinx-oriented mapped cells | {report['fpga_estimate']['mapped_cells']} |
| LUT estimate | {lut} |
| FF estimate | {ff} |
| RAMB estimate | {bram} |
| DSP estimate | {dsp} |

This is an open-source synthesis/resource estimate. It is not Vivado synthesis,
implementation, post-route timing, or FPGA hardware sign-off.
"""
    args.output_markdown.write_text(markdown, encoding="utf-8")
    print(f"QoR JSON: {args.output_json}")
    print(f"QoR Markdown: {args.output_markdown}")


if __name__ == "__main__":
    main()
