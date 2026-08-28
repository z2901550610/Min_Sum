import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ReadOnly, RisingEdge, Timer


SEED = 918273
WIDTH = 4
MASK = (1 << WIDTH) - 1


async def drive_cycle(dut, *, enable: int, load: int, load_value: int) -> None:
    dut.i_enable.value = enable
    dut.i_load.value = load
    dut.i_load_value.value = load_value
    await RisingEdge(dut.i_clk)
    await ReadOnly()
    await Timer(1, unit="ps")


def check_outputs(dut, *, cycle: int, expected_count: int, expected_wrap: int) -> None:
    actual_count = int(dut.o_count.value)
    actual_wrap = int(dut.o_wrap.value)
    assert (actual_count, actual_wrap) == (expected_count, expected_wrap), (
        "FAIL test_counter "
        f"seed={SEED} cycle={cycle} "
        f"expected_count={expected_count} actual_count={actual_count} "
        f"expected_wrap={expected_wrap} actual_wrap={actual_wrap}"
    )


@cocotb.test()
async def counter_directed_and_random(dut) -> None:
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_rst_n.value = 0
    await drive_cycle(dut, enable=0, load=0, load_value=0)
    await drive_cycle(dut, enable=1, load=0, load_value=0)
    check_outputs(dut, cycle=1, expected_count=0, expected_wrap=0)

    dut.i_rst_n.value = 1
    expected_count = 0

    await drive_cycle(dut, enable=0, load=1, load_value=14)
    expected_count = 14
    check_outputs(dut, cycle=2, expected_count=expected_count, expected_wrap=0)

    await drive_cycle(dut, enable=1, load=0, load_value=0)
    expected_count = 15
    check_outputs(dut, cycle=3, expected_count=expected_count, expected_wrap=0)

    await drive_cycle(dut, enable=1, load=0, load_value=0)
    expected_count = 0
    check_outputs(dut, cycle=4, expected_count=expected_count, expected_wrap=1)

    rng = random.Random(SEED)
    for cycle in range(5, 105):
        load = int(rng.randrange(0, 8) == 0)
        enable = rng.randrange(0, 2)
        load_value = rng.randrange(0, MASK + 1)
        previous_count = expected_count
        await drive_cycle(dut, enable=enable, load=load, load_value=load_value)
        if load:
            expected_count = load_value
            expected_wrap = 0
        elif enable:
            expected_count = (previous_count + 1) & MASK
            expected_wrap = int(previous_count == MASK)
        else:
            expected_wrap = 0
        check_outputs(
            dut,
            cycle=cycle,
            expected_count=expected_count,
            expected_wrap=expected_wrap,
        )
