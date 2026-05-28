"""Shared RAM-I first-column table and hex generation helpers."""

from __future__ import annotations

from pathlib import Path


def first_column_tables(
    banks: list[list[int]],
    group_count: int = 2,
) -> tuple[list[list[int]], list[list[list[tuple[int, int] | None]]]]:
    group_count_table: list[list[int]] = []
    group_entry_table: list[list[list[tuple[int, int] | None]]] = []

    for bank_support in banks:
        group_counts = [0 for _ in range(group_count)]
        group_entries: list[list[tuple[int, int] | None]] = [
            [None for _ in range(len(bank_support))] for _ in range(group_count)
        ]
        for one_idx, row_idx_global in enumerate(bank_support):
            group_idx = one_idx % group_count
            entry_idx = group_counts[group_idx]
            group_entries[group_idx][entry_idx] = (one_idx, row_idx_global)
            group_counts[group_idx] += 1
        group_count_table.append(group_counts)
        group_entry_table.append(group_entries)

    return group_count_table, group_entry_table


def schedule_depth_from_counts(group_counts: list[int], issue_width: int) -> int:
    remaining = list(group_counts)
    depth = 0
    while any(count > 0 for count in remaining):
        issued = 0
        for group_idx, count in enumerate(remaining):
            if issued >= issue_width:
                break
            if count > 0:
                remaining[group_idx] = count - 1
                issued += 1
        depth += 1
    return depth


def lane_depth_from_counts(group_counts: list[list[int]], issue_width: int | None = None) -> int:
    bank_depth = max(max(counts) for counts in group_counts)
    if issue_width is None:
        return bank_depth
    slot_depth = max(schedule_depth_from_counts(counts, issue_width) for counts in group_counts)
    return max(bank_depth, slot_depth)


def row_bank_schedule_depth(
    banks: list[list[int]],
    r_value: int,
    row_bank_count: int,
    issue_width: int,
) -> int:
    depth = 0
    for bank_support in banks:
        for col_idx in range(r_value):
            edge_banks: list[int] = []
            for source_group_idx in range(issue_width):
                for one_idx, row_idx_global in enumerate(bank_support):
                    if (one_idx % issue_width) != source_group_idx:
                        continue
                    shifted_row = row_idx_global + col_idx
                    if shifted_row >= r_value:
                        shifted_row -= r_value
                    edge_banks.append(shifted_row % row_bank_count)

            issued = [False for _ in edge_banks]
            slot_depth = 0
            while not all(issued):
                used_banks: set[int] = set()
                issued_this_slot = 0
                for edge_idx, edge_bank in enumerate(edge_banks):
                    if issued[edge_idx]:
                        continue
                    if edge_bank in used_banks:
                        continue
                    if issued_this_slot >= issue_width:
                        break
                    used_banks.add(edge_bank)
                    issued[edge_idx] = True
                    issued_this_slot += 1
                slot_depth += 1
            depth = max(depth, slot_depth)
    return depth


def select_row_bank_count(
    banks: list[list[int]],
    r_value: int,
    issue_width: int,
    target_depth: int,
) -> int:
    row_bank_count = 1
    while row_bank_count < r_value:
        if row_bank_schedule_depth(banks, r_value, row_bank_count, issue_width) <= target_depth:
            return row_bank_count
        row_bank_count *= 2
    return r_value


def shifted_row_bank_depth(banks: list[list[int]], r_value: int, lane_count: int) -> int:
    return row_bank_schedule_depth(banks, r_value, lane_count, lane_count)


def clog2_sv(value: int) -> int:
    if value <= 1:
        return 1
    return (value - 1).bit_length()


def packed_entry(_one_idx: int, row_idx_group: int, _row_idx_w: int) -> int:
    return row_idx_group


def write_hex_file(path: Path, values: list[int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(f"{value:x}" for value in values) + "\n", encoding="utf-8")


def generate_hex_files(
    banks: list[list[int]],
    r_value: int,
    w_value: int,
    tag: str,
    output_dir: Path,
    group_count: int = 2,
    memory_depth: int | None = None,
) -> None:
    group_counts, group_entries = first_column_tables(banks, group_count)
    row_idx_w = clog2_sv(r_value)
    bank_depth = lane_depth_from_counts(group_counts)
    lane_depth = bank_depth if memory_depth is None else memory_depth
    if lane_depth < bank_depth:
        raise ValueError(f"RAM-I memory depth {lane_depth} is smaller than bank depth {bank_depth}")
    tag_suffix = f"_{tag}" if tag else ""

    for group_idx in range(group_count):
        entries: list[int] = []
        counts: list[int] = []
        for h_block_idx in range(len(banks)):
            counts.append(group_counts[h_block_idx][group_idx])
            for entry_idx in range(lane_depth):
                item = (
                    group_entries[h_block_idx][group_idx][entry_idx]
                    if entry_idx < len(group_entries[h_block_idx][group_idx])
                    else None
                )
                if item is None:
                    entries.append(0)
                else:
                    one_idx, row_idx_group = item
                    entries.append(packed_entry(one_idx, row_idx_group, row_idx_w))

        write_hex_file(output_dir / f"ram_i{group_idx}_entries{tag_suffix}.hex", entries)
        write_hex_file(output_dir / f"ram_i{group_idx}_counts{tag_suffix}.hex", counts)
