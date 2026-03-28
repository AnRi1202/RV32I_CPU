import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


def fmt_sig(value):
    if not value.is_resolvable:
        return "X"
    return f"0x{value.to_unsigned():08x}"


@cocotb.test()
async def tb_cpu(dut):

    # generate clock
    clock = Clock(dut.clk_i, 10, unit="ns")  # 100MHz
    cocotb.start_soon(clock.start())

    # Initialize
    dut.rst_n_i.value = 0


    for _ in range(3):
        await RisingEdge(dut.clk_i)
    dut.rst_n_i.value = 1


    for cycle in range(20):
        await RisingEdge(dut.clk_i)
        cocotb.log.info(
            "cycle=%02d pc=%s alu_out=%s write_data=%s read_data=%s",
            cycle,
            fmt_sig(dut.cpu.pc.value),
            fmt_sig(dut.cpu.alu_output.value),
            fmt_sig(dut.cpu.write_data_o.value),
            fmt_sig(dut.cpu.read_data_i.value)
        )


    # test

    # observation
    cocotb.log.info(f"complete")
