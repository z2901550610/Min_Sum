"""Shared RAM-I first-column table and hex generation helpers."""

from __future__ import annotations

from pathlib import Path


def first_column_tables(
    banks: list[list[int]],
) -> tuple[list[list[int]], list[list[list[tuple[int, int] | None]]]]:
    group_count_table: list[list[int]] = []
    group_entry_table: list[list[list[tuple[int, int] | None]]] = []

    for bank_support in banks:
        group_counts = [0, 0]
        group_entries: list[list[tuple[int, int] | None]] = [
            [None for _ in range(len(bank_support))],
            [None for _ in range(len(bank_support))],
        ]
        for one_idx, row_idx_global in enumerate(bank_support):
            group_idx = row_idx_global & 1
            row_idx_group = row_idx_global >> 1
            entry_idx = group_counts[group_idx]
            group_entries[group_idx][entry_idx] = (one_idx, row_idx_group)
            group_counts[group_idx] += 1
        group_count_table.append(group_counts)
        group_entry_table.append(group_entries)

    return group_count_table, group_entry_table


def clog2_sv(value: int) -> int:
    if value <= 1:
        return 1
    return (value - 1).bit_length()


def packed_entry(one_idx: int, row_idx_group: int, row_idx_w: int) -> int:
    return (one_idx << row_idx_w) | row_idx_group


def write_hex_file(path: Path, values: list[int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(f"{value:x}" for value in values) + "\n", encoding="utf-8")


def generate_hex_files(
    banks: list[list[int]],
    r_value: int,
    w_value: int,
    tag: str,
    output_dir: Path,
) -> None:
    row_idx_w = clog2_sv(r_value)
    group_counts, group_entries = first_column_tables(banks)
    group_names = ["ram_i0", "ram_i1"]
    tag_suffix = f"_{tag}" if tag else ""

    for group_idx in range(2):
        entries: list[int] = []
        counts: list[int] = []
        for h_block_idx in range(len(banks)):
            counts.append(group_counts[h_block_idx][group_idx])
            for entry_idx in range(w_value):
                item = group_entries[h_block_idx][group_idx][entry_idx]
                if item is None:
                    entries.append(0)
                else:
                    one_idx, row_idx_group = item
                    entries.append(packed_entry(one_idx, row_idx_group, row_idx_w))

        write_hex_file(output_dir / f"{group_names[group_idx]}_entries{tag_suffix}.hex", entries)
        write_hex_file(output_dir / f"{group_names[group_idx]}_counts{tag_suffix}.hex", counts)
