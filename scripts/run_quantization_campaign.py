#!/usr/bin/env python3
"""Run a reproducible uniform-quantization parameter campaign."""

from __future__ import annotations

import argparse
import csv
import subprocess
import tempfile
from collections import defaultdict
from pathlib import Path


PROFILE_TARGETS = {
    "bike128": 134,
    "bike192": 199,
    "bike256": 264,
}

MODE_PRESETS = {
    "smoke": {"coarse_trials": 2, "final_trials": 20, "stress_trials": 20},
    "quick": {"coarse_trials": 20, "final_trials": 1000, "stress_trials": 500},
    "full": {"coarse_trials": 100, "final_trials": 10000, "stress_trials": 5000},
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run coarse search, candidate validation, and stress tests."
    )
    parser.add_argument("--model", default="build/model/min_sum_model")
    parser.add_argument("--profile", choices=sorted(PROFILE_TARGETS), default="bike128")
    parser.add_argument("--mode", choices=sorted(MODE_PRESETS), default="quick")
    parser.add_argument("--threads", type=int, default=0)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--out-dir", default=None)
    parser.add_argument("--top-per-width", type=int, default=3)
    return parser.parse_args()


def run_command(command: list[str], *, stdout_path: Path | None = None) -> None:
    if stdout_path is None:
        subprocess.run(command, check=True)
        return
    with stdout_path.open("w", encoding="utf-8") as output:
        subprocess.run(command, check=True, stdout=output, stderr=subprocess.STDOUT)


def load_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def candidate_key(row: dict[str, str]) -> tuple[float, ...]:
    alpha = float(row["alpha"])
    return (
        -int(row["exact"]),
        -int(row["syndrome_success"]),
        float(row["mean_residual_weight"]),
        abs(alpha - 0.1875),
        -int(row["c_val"]),
        int(row["alpha_shift_0"]),
        int(row["alpha_shift_1"]),
    )


def select_candidates(
    rows: list[dict[str, str]], top_per_width: int
) -> list[tuple[int, int, int, int]]:
    grouped: dict[int, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[int(row["msg_bits"])].append(row)

    selected: list[tuple[int, int, int, int]] = []
    for msg_bits in (3, 4, 5):
        ranked = sorted(grouped[msg_bits], key=candidate_key)
        width_candidates = [
            (
                msg_bits,
                int(row["c_val"]),
                int(row["alpha_shift_0"]),
                int(row["alpha_shift_1"]),
            )
            for row in ranked[:top_per_width]
        ]
        magnitude_max = (1 << (msg_bits - 1)) - 1
        width_candidates.append((msg_bits, magnitude_max, 3, 4))
        if msg_bits == 5:
            width_candidates.append((5, 5, 3, 4))
        for candidate in width_candidates:
            if candidate not in selected:
                selected.append(candidate)
    return selected


def run_configuration(
    model: Path,
    profile: str,
    errors: int,
    trials: int,
    threads: int,
    seed: int,
    candidate: tuple[int, int, int, int],
) -> dict[str, object]:
    msg_bits, c_val, shift_0, shift_1 = candidate
    with tempfile.TemporaryDirectory(prefix="min-sum-campaign-") as temp_dir:
        trial_csv = Path(temp_dir) / "trials.csv"
        completed = subprocess.run(
            [
                str(model),
                "--profile",
                profile,
                "--errors",
                str(errors),
                "--msg-bits",
                str(msg_bits),
                "--c-val",
                str(c_val),
                "--alpha-shift-0",
                str(shift_0),
                "--alpha-shift-1",
                str(shift_1),
                "--seed",
                str(seed),
                "--trials",
                str(trials),
                "--threads",
                str(threads),
                "--csv",
                str(trial_csv),
            ],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
        )
        rows = load_csv(trial_csv)

    summary = completed.stdout.strip().splitlines()[-1]
    wall_seconds = float(
        next(token.split("=", 1)[1] for token in summary.split() if token.startswith("wall_seconds="))
    )
    return {
        "profile": profile,
        "msg_bits": msg_bits,
        "c_val": c_val,
        "alpha_shift_0": shift_0,
        "alpha_shift_1": shift_1,
        "alpha": (2.0**-shift_0) + (2.0**-shift_1),
        "errors": errors,
        "trials": trials,
        "syndrome_success": sum(int(row["residual_weight"]) == 0 for row in rows),
        "exact": sum(int(row["exact"]) for row in rows),
        "mean_residual_weight": sum(int(row["residual_weight"]) for row in rows) / len(rows),
        "mean_decision_weight": sum(int(row["decision_weight"]) for row in rows) / len(rows),
        "wall_seconds": wall_seconds,
    }


def write_results(path: Path, rows: list[dict[str, object]]) -> None:
    fields = [
        "profile",
        "msg_bits",
        "c_val",
        "alpha_shift_0",
        "alpha_shift_1",
        "alpha",
        "errors",
        "trials",
        "syndrome_success",
        "exact",
        "mean_residual_weight",
        "mean_decision_weight",
        "wall_seconds",
    ]
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def choose_recommendations(
    rows: list[dict[str, object]], target_weight: int
) -> dict[int, tuple[int, int, int, int]]:
    by_candidate: dict[tuple[int, int, int, int], dict[int, dict[str, object]]] = defaultdict(dict)
    for row in rows:
        candidate = (
            int(row["msg_bits"]),
            int(row["c_val"]),
            int(row["alpha_shift_0"]),
            int(row["alpha_shift_1"]),
        )
        by_candidate[candidate][int(row["errors"])] = row

    recommendations = {}
    for msg_bits in (3, 4, 5):
        candidates = [candidate for candidate in by_candidate if candidate[0] == msg_bits]
        stress_weights = sorted(
            {weight for candidate in candidates for weight in by_candidate[candidate]},
            reverse=True,
        )

        def rank(candidate: tuple[int, int, int, int]) -> tuple[float, ...]:
            records = by_candidate[candidate]
            target = records[target_weight]
            exact_rates = [
                int(records[weight]["exact"]) / int(records[weight]["trials"])
                for weight in stress_weights
            ]
            residuals = [
                float(records[weight]["mean_residual_weight"]) for weight in stress_weights
            ]
            return (
                int(target["exact"]) / int(target["trials"]),
                *exact_rates,
                *(-value for value in residuals),
                candidate[1],
            )

        recommendations[msg_bits] = max(candidates, key=rank)
    return recommendations


def write_summary(
    path: Path,
    profile: str,
    mode: str,
    target_weight: int,
    coarse_trials: int,
    final_trials: int,
    stress_trials: int,
    recommendations: dict[int, tuple[int, int, int, int]],
    rows: list[dict[str, object]],
) -> None:
    lookup = {
        (
            int(row["msg_bits"]),
            int(row["c_val"]),
            int(row["alpha_shift_0"]),
            int(row["alpha_shift_1"]),
            int(row["errors"]),
        ): row
        for row in rows
    }
    error_weights = sorted({int(row["errors"]) for row in rows})
    lines = [
        f"# {profile} quantization campaign",
        "",
        f"- Mode: `{mode}`",
        f"- Target error weight: `{target_weight}`",
        f"- Coarse trials per configuration: `{coarse_trials}`",
        f"- Target validation trials: `{final_trials}`",
        f"- Stress trials per point: `{stress_trials}`",
        "",
        "## Recommended candidates",
        "",
        "| Message bits | C | Alpha shifts | Alpha |",
        "| ---: | ---: | --- | ---: |",
    ]
    for msg_bits in (3, 4, 5):
        _, c_val, shift_0, shift_1 = recommendations[msg_bits]
        alpha = (2.0**-shift_0) + (2.0**-shift_1)
        lines.append(f"| {msg_bits} | {c_val} | ({shift_0}, {shift_1}) | {alpha:.6f} |")

    lines.extend(
        [
            "",
            "## Validation results",
            "",
            "| Bits | C | Errors | Exact | Syndrome success | Mean residual |",
            "| ---: | ---: | ---: | ---: | ---: | ---: |",
        ]
    )
    for msg_bits in (3, 4, 5):
        _, c_val, shift_0, shift_1 = recommendations[msg_bits]
        for errors in error_weights:
            row = lookup[(msg_bits, c_val, shift_0, shift_1, errors)]
            lines.append(
                f"| {msg_bits} | {c_val} | {errors} | "
                f"{row['exact']}/{row['trials']} | "
                f"{row['syndrome_success']}/{row['trials']} | "
                f"{float(row['mean_residual_weight']):.6f} |"
            )
    lines.extend(
        [
            "",
            "Stress points above the profile target weight are parameter-selection experiments.",
            "They are not cryptographic DFR estimates.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    args = parse_args()
    model = Path(args.model).resolve()
    if not model.is_file():
        raise SystemExit(f"model executable not found: {model}")
    if args.top_per_width < 1:
        raise SystemExit("--top-per-width must be positive")

    preset = MODE_PRESETS[args.mode]
    target_weight = PROFILE_TARGETS[args.profile]
    out_dir = (
        Path(args.out_dir)
        if args.out_dir
        else Path("build/model/campaign") / f"{args.profile}_{args.mode}"
    )
    out_dir.mkdir(parents=True, exist_ok=True)
    coarse_csv = out_dir / "coarse_sweep.csv"
    coarse_log = out_dir / "coarse_sweep.log"
    results_csv = out_dir / "candidate_results.csv"
    summary_md = out_dir / "summary.md"

    print(
        f"[1/3] coarse sweep: profile={args.profile} mode={args.mode} "
        f"trials={preset['coarse_trials']} threads={args.threads}",
        flush=True,
    )
    run_command(
        [
            "python3",
            "scripts/run_quantization_sweep.py",
            "--model",
            str(model),
            "--profile",
            args.profile,
            "--msg-bits",
            "3,4,5",
            "--seed",
            str(args.seed),
            "--trials",
            str(preset["coarse_trials"]),
            "--threads",
            str(args.threads),
            "--output",
            str(coarse_csv),
        ],
        stdout_path=coarse_log,
    )
    candidates = select_candidates(load_csv(coarse_csv), args.top_per_width)

    stress_weights = [target_weight + 11, target_weight + 21, target_weight + 31]
    results: list[dict[str, object]] = []
    total_runs = len(candidates) * (1 + len(stress_weights))
    run_idx = 0
    print(f"[2/3] validating {len(candidates)} candidates", flush=True)
    for candidate in candidates:
        for errors in [target_weight, *stress_weights]:
            run_idx += 1
            trials = (
                preset["final_trials"]
                if errors == target_weight
                else preset["stress_trials"]
            )
            print(
                f"  [{run_idx}/{total_runs}] bits={candidate[0]} C={candidate[1]} "
                f"shifts=({candidate[2]},{candidate[3]}) errors={errors} trials={trials}",
                flush=True,
            )
            results.append(
                run_configuration(
                    model,
                    args.profile,
                    errors,
                    trials,
                    args.threads,
                    args.seed,
                    candidate,
                )
            )
            write_results(results_csv, results)

    recommendations = choose_recommendations(results, target_weight)
    write_summary(
        summary_md,
        args.profile,
        args.mode,
        target_weight,
        preset["coarse_trials"],
        preset["final_trials"],
        preset["stress_trials"],
        recommendations,
        results,
    )
    print("[3/3] campaign complete", flush=True)
    print(f"summary: {summary_md}", flush=True)
    print(f"coarse results: {coarse_csv}", flush=True)
    print(f"candidate results: {results_csv}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
