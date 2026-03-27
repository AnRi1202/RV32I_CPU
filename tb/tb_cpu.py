import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


def fmt32(value):
    return f"0x{value.to_unsigned():08x}" if value.is_resolvable else f"0b{str(value)}"


@cocotb.test()
async def tb_cpu(dut):

    # generate clock
    clock = Clock(dut.clk_i, 10, unit="ns")  # 100MHz
    cocotb.start_soon(clock.start())

    # Initialize
    dut.rst_n_i.value = 0
    dut.write_data_i.value = 0
    dut.data_address_i.value = 0


    for _ in range(5):
        await RisingEdge(dut.clk_i)
    dut.rst_n_i.value = 1


    for cycle in range(10):
        await RisingEdge(dut.clk_i)
        cocotb.log.info(
            "cycle=%02d pc=%s alu_a=%s alu_b=%s alu_out=%s",
            cycle,
            fmt32(dut.pc.value),
            fmt32(dut.alu_port_a.value),
            fmt32(dut.alu_port_b.value),
            fmt32(dut.alu_output.value),
        )


    # test

    # observation
    cocotb.log.info(f"complete")
