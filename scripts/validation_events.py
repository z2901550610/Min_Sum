#!/usr/bin/env python3
"""Append and summarize run-scoped validation evidence events."""

from __future__ import annotations

import argparse
import fcntl
import json
import os
import tempfile
from collections import Counter
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


VALID_STATUSES = {"PASS", "FAIL", "NOT_RUN", "NOT_APPLICABLE"}


def event_path() -> Path | None:
    run_id = os.environ.get("VALIDATION_RUN_ID")
    if not run_id:
        return None
    explicit = os.environ.get("VALIDATION_EVENTS_PATH")
    if explicit:
        return Path(explicit)
    root = Path(os.environ.get("VALIDATION_RUN_ROOT", "build/results/runs"))
    return root / run_id / "events.jsonl"


def append_event(event: dict[str, Any]) -> Path | None:
    path = event_path()
    if path is None:
        return None
    status = str(event.get("status", ""))
    if status not in VALID_STATUSES:
        raise ValueError(f"invalid validation status: {status}")

    path.parent.mkdir(parents=True, exist_ok=True)
    record = {
        "schema_version": 1,
        "run_id": os.environ["VALIDATION_RUN_ID"],
        "recorded_at": datetime.now(UTC).isoformat(),
        **event,
    }
    lock_path = path.with_suffix(path.suffix + ".lock")
    with lock_path.open("a+", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
        with path.open("a", encoding="utf-8") as output:
            output.write(json.dumps(record, sort_keys=True) + "\n")
    return path


def load_events(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    events: list[dict[str, Any]] = []
    for line_number, raw_line in enumerate(
        path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        if not raw_line.strip():
            continue
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError as error:
            raise ValueError(f"invalid event JSON at {path}:{line_number}: {error}") from error
        if not isinstance(event, dict):
            raise ValueError(f"validation event at {path}:{line_number} is not an object")
        events.append(event)
    return events


def summarize(events: list[dict[str, Any]], run_id: str) -> dict[str, Any]:
    status_counts = Counter(str(event.get("status", "unknown")) for event in events)
    layer_counts: dict[str, Counter[str]] = {}
    signatures: Counter[str] = Counter()
    for event in events:
        layer = str(event.get("evidence_layer", "unknown"))
        layer_counts.setdefault(layer, Counter())[str(event.get("status", "unknown"))] += 1
        signature = event.get("signature")
        if isinstance(signature, str) and signature:
            signatures[signature] += 1
    duplicated = sorted(key for key, count in signatures.items() if count > 1)
    leaf_events = [
        event
        for event in events
        if isinstance(event.get("duration_seconds"), (int, float))
        and not str(event.get("signature", "")).startswith("stage:")
    ]
    slowest = []
    for event in sorted(
        leaf_events,
        key=lambda item: float(item["duration_seconds"]),
        reverse=True,
    )[:5]:
        slowest.append(
            {
                "duration_seconds": event["duration_seconds"],
                "layer": str(event.get("evidence_layer", "unknown")),
                "name": str(event.get("name", "unknown")),
                "signature": str(event.get("signature", "")),
                "status": str(event.get("status", "unknown")),
            }
        )
    if status_counts.get("FAIL", 0):
        overall = "FAIL"
    elif status_counts.get("NOT_RUN", 0):
        overall = "NOT_RUN"
    elif status_counts.get("PASS", 0):
        overall = "PASS"
    elif events:
        overall = "NOT_APPLICABLE"
    else:
        overall = "NOT_RUN"
    return {
        "schema_version": 1,
        "run_id": run_id,
        "generated_at": datetime.now(UTC).isoformat(),
        "status": overall,
        "event_count": len(events),
        "status_counts": dict(sorted(status_counts.items())),
        "layers": {
            layer: dict(sorted(counts.items()))
            for layer, counts in sorted(layer_counts.items())
        },
        "duplicate_signatures": duplicated,
        "slowest_leaf_events": slowest,
    }


def summary_text(summary: dict[str, Any]) -> str:
    lines = [
        f"validation {summary['status']}: run {summary['run_id']}",
        f"events: {summary['event_count']}",
    ]
    for layer, counts in summary["layers"].items():
        rendered = ", ".join(f"{status}={count}" for status, count in counts.items())
        lines.append(f"{layer}: {rendered}")
    if summary["slowest_leaf_events"]:
        lines.append("slowest recorded leaf events:")
        for event in summary["slowest_leaf_events"]:
            signature = event["signature"]
            prefix, separator, digest = signature.partition(":")
            if separator and digest:
                shortened = f"{prefix}:{digest[:8]}"
            else:
                shortened = signature[:12]
            signature_hint = f" [{shortened}]" if shortened else ""
            lines.append(
                f"  {event['duration_seconds']:.3f}s {event['layer']} "
                f"{event['name']}{signature_hint}"
            )
    duplicate_count = len(summary["duplicate_signatures"])
    lines.append(f"duplicate signatures: {duplicate_count}")
    return "\n".join(lines) + "\n"


def write_summary(events_path: Path, run_id: str) -> tuple[Path, Path, dict[str, Any]]:
    events = load_events(events_path)
    summary = summarize(events, run_id)
    json_path = events_path.with_name("summary.json")
    text_path = events_path.with_name("summary.txt")
    json_path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=json_path.parent,
        prefix=json_path.name + ".",
        suffix=".tmp",
        delete=False,
    ) as output:
        json.dump(summary, output, indent=2, sort_keys=True)
        output.write("\n")
        temporary = Path(output.name)
    os.replace(temporary, json_path)
    text_path.write_text(summary_text(summary), encoding="utf-8")
    return json_path, text_path, summary


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    record_parser = subparsers.add_parser("record")
    record_parser.add_argument("--layer", required=True)
    record_parser.add_argument("--name", required=True)
    record_parser.add_argument("--status", choices=sorted(VALID_STATUSES), required=True)
    record_parser.add_argument("--signature")
    record_parser.add_argument("--returncode", type=int, default=0)
    summary_parser = subparsers.add_parser("summarize")
    summary_parser.add_argument("--events", type=Path, required=True)
    summary_parser.add_argument("--run-id", required=True)
    args = parser.parse_args()

    if args.command == "record":
        append_event(
            {
                "evidence_layer": args.layer,
                "name": args.name,
                "status": args.status,
                "signature": args.signature,
                "returncode": args.returncode,
            }
        )
        return 0

    _, _, summary = write_summary(args.events, args.run_id)
    print(summary_text(summary), end="")
    return 1 if summary["status"] == "FAIL" else 0


if __name__ == "__main__":
    raise SystemExit(main())
