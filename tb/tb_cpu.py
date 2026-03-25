import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


@cocotb.test()
async def tb_cpu(dut):
    
    # generate clock
    clock = Clock(dut.clk_i, 10, unit="ns") # 100MHz
    cocotb.start_soon(clock.start())

    # Initialize
    dut.rst_i.value = 1
    dut.write_data_i.value = 0
    dut.data_address_i.value = 0


    for _ in range(5):
        await RisingEdge(dut.clk_i)
    dut.rst_i.value =0


    for _ in range(10):
        await RisingEdge(dut.clk_i)


    # test

    # observation
    cocotb.log.info(f"complete")

