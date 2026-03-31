import os
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


def fmt_sig(value):
    if not value.is_resolvable:
        return "X"
    return f"0x{value.to_unsigned():08x}"


def reg_u32(dut, index: int) -> int:
    return dut.cpu.rf.register[index].value.to_unsigned() & 0xFFFF_FFFF


def active_program() -> str:
    dut_param = os.environ.get("IMEM_FILE", "")
    try:
        dut_param = str(cocotb.top.IMEM_FILE.value)
    except Exception:
        pass

    dut_param = dut_param.strip().strip('"').rstrip("\x00")
    return Path(dut_param).name


EXPECTED_REGS = {
    "r_test.txt": {
        1: 0x00000000,
        2: 0x00000005,
        3: 0x00000001,
        4: 0x00000000,
    },
    "2_stage_test.txt": {
        1: 0x00000008,
        2: 0x00000002,
        3: 0x00000004,
        5: 0x00000000,
    },
    "ls_test.txt": {
        1: 0x00000000,
        2: 0x00000008,
        3: 0x00000008,
        4: 0x0000000C,
        5: 0x0000000C,
        6: 0xFFFF_FFFF,
        7: 0xFFFF_FFFF,
        8: 0x0000000C,
        9: 0x0000000C,
        10: 0x00000008,
        11: 0x0000000C,
        12: 0xFFFF_FFFF,
        13: 0x0000000C,
    },
    "stall_test.txt": {
        1: 0x00000000,
        2: 0x00000015,
        3: 0x00000015,
        4: 0x00000016,
        5: 0x0000002B,
    },
}


async def reset_dut(dut):
    dut.rst_n_i.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk_i)
    dut.rst_n_i.value = 1


async def run_cycles(dut, cycles: int):
    for cycle in range(cycles):
        await RisingEdge(dut.clk_i)
        cocotb.log.info(
            "cycle=%02d pc=%s stall=%d x1=%s x2=%s x3=%s x4=%s x5=%s",
            cycle,
            fmt_sig(dut.cpu.pc.value),
            int(dut.cpu.stall_id.value),
            fmt_sig(dut.cpu.rf.register[1].value),
            fmt_sig(dut.cpu.rf.register[2].value),
            fmt_sig(dut.cpu.rf.register[3].value),
            fmt_sig(dut.cpu.rf.register[4].value),
            fmt_sig(dut.cpu.rf.register[5].value),
        )


def check_expected_registers(dut):
    program = active_program()
    expected = EXPECTED_REGS.get(program)
    if expected is None:
        cocotb.log.warning("No expectations registered for %s", program or "<unknown>")
        return

    for reg_idx, expected_value in expected.items():
        actual = reg_u32(dut, reg_idx)
        assert actual == expected_value, (
            f"x{reg_idx} mismatch for {program}: "
            f"expected 0x{expected_value:08x}, got 0x{actual:08x}"
        )


@cocotb.test()
async def tb_cpu(dut):
    clock = Clock(dut.clk_i, 10, unit="ns")
    cocotb.start_soon(clock.start())

    cocotb.log.info("active program=%s", active_program() or "<unknown>")
    await reset_dut(dut)
    await run_cycles(dut, 24)
    check_expected_registers(dut)
    cocotb.log.info("complete")
