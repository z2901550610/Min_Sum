#!/usr/bin/env python3
"""Evaluate a proposed serial K2 direct-fold schedule, not RTL/QoR evidence.

Existing SDP operands are transformed/restored in place. Virtual padded words
read as zero and suppress writes by public geometry. The model materializes
leaf products for checking; that Python storage is not proposed hardware RAM.
"""
import argparse
import random

from trike_fixture_utils import cyclic_multiply

OFFSETS = ((0, 1, 2, 3), (1, 2, 3, 4), (1, 3), (2, 3, 4, 5),
           (3, 4, 5, 6), (3, 5), (2, 3), (3, 4), (3,))


def clmul(a, b):
    result = 0
    while a:
        bit = a & -a
        result ^= b << (bit.bit_length() - 1)
        a ^= bit
    return result


def evaluate(a, b, r, word_bits=64):
    w = (r + word_bits - 1) // word_bits
    q = (w + 3) // 4
    quarter_bits = q * word_bits
    quarter_mask = (1 << quarter_bits) - 1
    aa = [(a >> (i * quarter_bits)) & quarter_mask for i in range(4)]
    bb = [(b >> (i * quarter_bits)) & quarter_mask for i in range(4)]
    original_a, original_b = aa[:], bb[:]
    result = 0
    word_mask = (1 << word_bits) - 1
    valid_product_mask = (1 << (2 * r)) - 1
    ring_mask = (1 << r) - 1
    scan_words = 0

    def xor_quarter(low, high):
        nonlocal scan_words
        aa[low] ^= aa[high]
        bb[low] ^= bb[high]
        scan_words += q

    def leaf(phase, bank):
        nonlocal result
        product = clmul(aa[bank], bb[bank])
        # Emit 2Q words. Truncate each shifted term before linear cyclic folding.
        for j in range(2 * q):
            value = (product >> (j * word_bits)) & word_mask
            for offset in OFFSETS[phase]:
                shifted = (value << ((j + offset * q) * word_bits)) & valid_product_mask
                result ^= (shifted & ring_mask) ^ (shifted >> r)

    leaf(0, 0)
    leaf(1, 1)
    xor_quarter(0, 1)
    leaf(2, 0)
    xor_quarter(0, 1)
    leaf(3, 2)
    leaf(4, 3)
    xor_quarter(2, 3)
    leaf(5, 2)
    xor_quarter(2, 3)
    xor_quarter(0, 2)
    xor_quarter(1, 3)
    leaf(6, 0)
    leaf(7, 1)
    xor_quarter(0, 1)
    leaf(8, 0)
    xor_quarter(0, 1)
    xor_quarter(0, 2)
    xor_quarter(1, 3)
    assert aa == original_a and bb == original_b
    assert scan_words == 10 * q
    assert result == cyclic_multiply(a, b, r)

    # Proposed FSM budget: pairs, diagonal prefetch, word advance, RMW,
    # operand scans, result clear/output, input load and wrapper control.
    second = sum(1 for offsets in OFFSETS for off in offsets for j in range(2*q)
                 if w-1 <= j+off*q <= 2*w-2) if r % word_bits else 0
    cycles = 9*q*q + 9*(2*q-1) + 18*q + 100*q + 3*scan_words + 5*w + 2 + 2*second
    h = (w+1)//2
    k1_second = sum(mult for off, mult in ((0, 1), (h, 3), (2*h, 1))
                    for j in range(2*h) if w-1 <= j+off <= 2*w-2) if r % word_bits else 0
    hidden = 0
    for offsets in ((0, h), (2*h, h), (h,)):
        for k in range(2*h-2):
            writes = sum(1 + int(r % word_bits != 0 and w-1 <= k+off <= 2*w-2)
                         for off in offsets)
            next_length = min(k+2, 2*h-2-k)
            hidden += min(2*writes+1, next_length+1)
    current = 3*h*h + 38*h + 5*w - 1 + 2*k1_second - hidden
    return current, cycles


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--r-bits", nargs="+", type=int, default=[12589, 106781])
    args = parser.parse_args()
    rng = random.Random(20260909)
    count = 0
    for r in [2, 63, 64, 65, 127, 128, 129, 191, 192, 193, 255, 256, 257] + args.r_bits:
        if r < 2:
            parser.error("r must be at least 2")
        for a, b in [(0, (1 << r)-1), ((1 << r)-1, (1 << r)-1),
                     (rng.getrandbits(r), rng.getrandbits(r))]:
            k1, k2 = evaluate(a, b, r)
            count += 1
        print(f"r={r} arithmetic_restore=PASS K1_current_formula={k1} K2_proposed_budget={k2}")
    print(f"PASS {count} software cases; K2 RTL/synthesis/Vivado NOT_RUN")


if __name__ == "__main__":
    main()
