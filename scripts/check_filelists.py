#!/usr/bin/env python3
"""Validate canonical implementation filelists."""

from __future__ import annotations

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
EXPECTED_TOPS = {
    "decoder.f": "rtl/decoder_top.sv",
    "trike_poly_mul_karatsuba.f": "rtl/trike_poly_mul_karatsuba_core.sv",
    "trike_poly_mul_karatsuba2.f": "rtl/trike_poly_mul_karatsuba2_core.sv",
    "trike_poly_inv.f": "rtl/trike_poly_inv_synth_top.sv",
    "trike_pseudohash.f": "rtl/trike_pseudohash_synth_top.sv",
    "trike_encaps.f": "rtl/trike_encaps_synth_top.sv",
    "trike_keygen.f": "rtl/trike_keygen_synth_top.sv",
    "trike_decaps.f": "rtl/trike_decaps_synth_top.sv",
    "trike_kem_asic.f": "rtl/trike_kem_asic_top.sv",
}


def read_filelist(path: Path) -> list[str]:
    entries = []
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("#", maxsplit=1)[0].strip()
        if line:
            entries.append(line)
    return entries


def main() -> None:
    for name, expected_top in EXPECTED_TOPS.items():
        path = REPO_ROOT / "filelists" / name
        entries = read_filelist(path)
        if len(entries) != len(set(entries)):
            raise SystemExit(f"{path}: duplicate source entry")
        missing = [entry for entry in entries if not (REPO_ROOT / entry).is_file()]
        if missing:
            raise SystemExit(f"{path}: missing sources: {', '.join(missing)}")
        if expected_top not in entries:
            raise SystemExit(f"{path}: missing implementation top {expected_top}")
    print("Canonical RTL filelists PASS")


if __name__ == "__main__":
    main()
