#!/usr/bin/env python3
"""Check resource-sharing invariants in the unified TRIKE KEM hierarchy."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import tempfile


REPO_ROOT = Path(__file__).resolve().parents[1]


def read_filelist(path: Path) -> list[str]:
    sources = []
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("#", maxsplit=1)[0].strip()
        if line:
            sources.append(line)
    return sources


def main() -> None:
    verilator = os.environ.get("REAL_VERILATOR", "verilator")
    sources = read_filelist(REPO_ROOT / "filelists" / "trike_kem_asic.f")
    with tempfile.TemporaryDirectory(prefix="trike-kem-structure-") as temp_dir:
        json_path = Path(temp_dir) / "hierarchy.json"
        command = [
            verilator,
            "--json-only",
            "--json-only-output",
            str(json_path),
            "--sv",
            "-DTRIKE_UNIFIED_PARAMS",
            "-DBIKE_PARALLEL_L=32",
            "-DBIKE_K_SIGN_K=4",
            "-DBIKE_MSG_BITS=5",
            "-DBIKE_COLS_PER_TILE=256",
            "-Wall",
            "-I./tb",
            "-I./rtl",
            "config/verilator_waivers.vlt",
            "--top-module",
            "trike_kem_asic_top",
            *sources,
        ]
        subprocess.run(command, cwd=REPO_ROOT, check=True, stdout=subprocess.DEVNULL)
        tree = json.loads(json_path.read_text(encoding="utf-8"))

    objects: list[dict[str, object]] = []

    def visit(node: object) -> None:
        if isinstance(node, dict):
            objects.append(node)
            for value in node.values():
                visit(value)
        elif isinstance(node, list):
            for value in node:
                visit(value)

    visit(tree)

    def instance_count(module_prefix: str) -> int:
        addresses = {
            item.get("addr")
            for item in objects
            if item.get("type") == "MODULE"
            and str(item.get("name", "")).startswith(module_prefix)
        }
        return sum(item.get("type") == "CELL" and item.get("modp") in addresses for item in objects)

    count = instance_count("sm3_compress")
    if count != 1:
        raise SystemExit(f"trike_kem_asic_top: expected one sm3_compress instance, found {count}")
    mul_count = instance_count("trike_poly_mul_core")
    if mul_count != 2:
        raise SystemExit(
            "trike_kem_asic_top: expected one shared streaming multiplier and "
            f"one KeyGen inversion multiplier, found {mul_count}"
        )
    h123_count = instance_count("trike_h123_vectors")
    if h123_count != 1:
        raise SystemExit(
            f"trike_kem_asic_top: expected one shared H123 vector service, found {h123_count}"
        )
    parity_count = instance_count("trike_parity_map_stream")
    if parity_count != 1:
        raise SystemExit(
            f"trike_kem_asic_top: expected one shared H123 parity mapper, found {parity_count}"
        )
    sampler_count = instance_count("trike_drng_weight_sampler")
    if sampler_count != 1:
        raise SystemExit(
            f"trike_kem_asic_top: expected one shared DRNG weight sampler, found {sampler_count}"
        )
    fixed_sampler_count = instance_count("trike_fixed_weight_sampler")
    if fixed_sampler_count != 1:
        raise SystemExit(
            "trike_kem_asic_top: expected one shared fixed-weight index sampler, "
            f"found {fixed_sampler_count}"
        )
    h4_store_count = instance_count("trike_error_support_store")
    if h4_store_count != 1:
        raise SystemExit(
            "trike_kem_asic_top: expected one shared H4 support/error store, "
            f"found {h4_store_count}"
        )
    h123_store_count = instance_count("trike_h123_vector_store")
    if h123_store_count != 1:
        raise SystemExit(
            "trike_kem_asic_top: expected one shared H123 vector store, "
            f"found {h123_store_count}"
        )
    uv_core_count = instance_count("trike_encaps_uv_core")
    uv_external_store_count = sum(
        item.get("type") == "GENBLOCK" and item.get("name") == "gen_external_uv_store"
        for item in objects
    )
    uv_local_store_count = sum(
        item.get("type") == "GENBLOCK" and item.get("name") == "gen_local_uv_store"
        for item in objects
    )
    if (
        uv_core_count != 1
        or uv_external_store_count != 1
        or uv_local_store_count != 0
    ):
        raise SystemExit(
            "trike_kem_asic_top: expected one Encaps UV core using the persistent "
            "external u/v store, found "
            f"cores={uv_core_count} external={uv_external_store_count} "
            f"local={uv_local_store_count}"
        )
    keygen_arith_modules = [
        item
        for item in objects
        if item.get("type") == "MODULE"
        and str(item.get("name", "")).startswith("trike_keygen_arith_core")
    ]
    keygen_arith_cells = {
        child.get("name")
        for module in keygen_arith_modules
        for child in module.get("stmtsp", [])
        if isinstance(child, dict) and child.get("type") == "CELL"
    }
    keygen_core_modules = [
        item
        for item in objects
        if item.get("type") == "MODULE"
        and str(item.get("name", "")).startswith("trike_keygen_core")
    ]
    keygen_core_cells = {
        child.get("name")
        for module in keygen_core_modules
        for child in module.get("stmtsp", [])
        if isinstance(child, dict) and child.get("type") == "CELL"
    }
    keygen_external_result_store_count = sum(
        item.get("type") == "GENBLOCK"
        and item.get("name") == "gen_external_result_store"
        for item in objects
    )
    keygen_local_result_store_count = sum(
        item.get("type") == "GENBLOCK" and item.get("name") == "gen_local_result_store"
        for item in objects
    )
    keygen_external_support_store_count = sum(
        item.get("type") == "GENBLOCK"
        and item.get("name") == "gen_external_support_store"
        for item in objects
    )
    keygen_local_support_store_count = sum(
        item.get("type") == "GENBLOCK" and item.get("name") == "gen_local_support_store"
        for item in objects
    )
    if (
        len(keygen_arith_modules) != 1
        or len(keygen_core_modules) != 1
        or keygen_external_result_store_count != 1
        or keygen_local_result_store_count != 0
        or keygen_external_support_store_count != 1
        or keygen_local_support_store_count != 0
        or "u_numerator_r2_mem" in keygen_arith_cells
        or "u_t0_mem" in keygen_arith_cells
        or "u_inverse_mem" in keygen_arith_cells
        or "u_t0_output_mem" not in keygen_core_cells
        or "u_r2_output_mem" not in keygen_core_cells
    ):
        raise SystemExit(
            "trike_kem_asic_top: expected KeyGen arithmetic and serialization to "
            "reuse two persistent result RAMs, found "
            f"arith_modules={len(keygen_arith_modules)} "
            f"core_modules={len(keygen_core_modules)} "
            f"external={keygen_external_result_store_count} "
            f"local={keygen_local_result_store_count} "
            f"external_support={keygen_external_support_store_count} "
            f"local_support={keygen_local_support_store_count} "
            f"arith_cells={sorted(keygen_arith_cells)} "
            f"core_cells={sorted(keygen_core_cells)}"
        )
    print("Unified TRIKE KEM structure PASS: one sm3_compress instance")
    print("Unified TRIKE KEM structure PASS: two poly-mul instances")
    print("Unified TRIKE KEM structure PASS: one H123 vector service and parity mapper")
    print("Unified TRIKE KEM structure PASS: one DRNG and fixed-weight sampler chain")
    print("Unified TRIKE KEM structure PASS: one H4 support/error store")
    print("Unified TRIKE KEM structure PASS: one H123 vector store")
    print("Unified TRIKE KEM structure PASS: Encaps UV reuses persistent u/v store")
    print("Unified TRIKE KEM structure PASS: KeyGen reuses two persistent result RAMs")
    print("Unified TRIKE KEM structure PASS: KeyGen arithmetic reuses the stage support view")
    print("Unified TRIKE KEM structure PASS: KeyGen inverse reuses the H123 t1 bank")


if __name__ == "__main__":
    main()
