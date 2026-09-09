#!/usr/bin/env python3
"""Reproduce dense/sparse runtime and inversion full-geometry fold regressions.

Run from the repository root after sourcing scripts/eda-env.sh. These are
seeded independent polynomial goldens, not official KAT records or DFR trials.
"""
import argparse
import json
import hashlib
from pathlib import Path
import random
import subprocess

from gen_trike_poly_inv_fixture import generate_fixture
from trike_fixture_utils import cyclic_multiply, format_word_array, words_from_value


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--suite", choices=["multiply", "inverse", "all"], default="all")
    parser.add_argument("--build-dir", type=Path, default=Path("build/trike-fold-profiles"))
    args = parser.parse_args()
    results = []
    args.build_dir.mkdir(parents=True, exist_ok=True)
    report_path = args.build_dir / f"results-{args.suite}.json"
    report = {"status": "RUNNING", "cases": results,
              "source_sha256": {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                                for p in [Path("rtl/trike_poly_mul_core.sv"),
                                          Path("rtl/trike_poly_mul_karatsuba_core.sv"),
                                          Path("rtl/trike_poly_inv_core.sv")]}}
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    suites = ["multiply", "inverse"] if args.suite == "all" else [args.suite]
    for suite in suites:
        profiles = ([12589, 15581, 30389, 63773, 106781] if suite == "multiply"
                    else [12589, 15581, 35363, 69691, 114043])
        for r in profiles:
            case_dir = args.build_dir / suite / f"r{r}"
            generated = case_dir / "generated"
            generated.mkdir(parents=True, exist_ok=True)
            seed = 20260908 + r
            if suite == "multiply":
                n = (r + 63) // 64
                rng = random.Random(seed)
                a, b = rng.getrandbits(r), rng.getrandbits(r)
                support = [0, r // 2, r - 1]
                sparse = sum(1 << bit for bit in support)
                fixture = generated / "trike_poly_mul_reference_case.svh"
                lines = [f"localparam int REF_R_BITS={r};", "localparam int REF_WORD_W=64;",
                         f"localparam int REF_WORDS={n};", "localparam int REF_SPARSE_WEIGHT=3;",
                         "localparam int REF_INDEX_W=$clog2(REF_R_BITS);"]
                for name, value in [("REF_DENSE_A", a), ("REF_DENSE_B", b),
                                    ("REF_DENSE_RESULT", cyclic_multiply(a, b, r)),
                                    ("REF_SPARSE_RESULT", cyclic_multiply(sparse, b, r))]:
                    lines += format_word_array(name, words_from_value(value, n),
                                               width="REF_WORD_W-1:0", size_expr="REF_WORDS")
                lines.append("localparam logic [REF_INDEX_W-1:0] REF_SPARSE_INDICES[0:2] = '{" +
                             ", ".join(f"REF_INDEX_W'({bit})" for bit in support) + "};")
                fixture.write_text("\n".join(lines) + "\n")
                target = "test-trike-poly-reference"
                fixture_arg = "TRIKE_POLY_REFERENCE_FIXTURE"
            else:
                fixture = generated / "trike_poly_inv_reference_case.svh"
                generate_fixture(None, fixture, r, 1, seed)
                target = "test-trike-poly-inv-reference"
                fixture_arg = "TRIKE_POLY_INV_REFERENCE_FIXTURE"
            mdir = case_dir / "obj"
            flags = (f"--binary --sv -Wall -I{case_dir} -I./tb -I./rtl "
                     f"config/verilator_waivers.vlt --Mdir {mdir}")
            print(f"RUN {suite} r={r} seed={seed}", flush=True)
            try:
                subprocess.run(["make", "--no-print-directory", target,
                                f"{fixture_arg}={fixture}", f"VERILATOR_MDIR={mdir}",
                                f"VERILATOR_FLAGS={flags}"], check=True)
            except subprocess.CalledProcessError:
                report["status"] = "FAIL"
                results.append({"suite": suite, "r_bits": r, "seed": seed, "status": "FAIL"})
                report_path.write_text(json.dumps(report, indent=2) + "\n")
                raise
            results.append({"suite": suite, "r_bits": r, "seed": seed, "status": "PASS"})
            report_path.write_text(json.dumps(report, indent=2) + "\n")
    report["status"] = "PASS"
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    print(f"PASS {len(results)} full-geometry cases", flush=True)


if __name__ == "__main__":
    main()
