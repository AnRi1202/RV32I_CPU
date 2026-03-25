TOPLEVEL_LANG = verilog
SIM = icarus # Change your simlator

VERILOG_SOURCES = ../src/risc_v_32_i_pkg.sv \
									../src/cpu.sv \
									../src/instruction_memory.sv \
									../src/data_memory.sv \
									../src/alu.sv

TOPLEVEL = cpu
COCOTB_TEST_MODULES = tb_cpu

export PYTHONPATH := ../tb


COMPILE_ARGS += -g2012

include $(shell cocotb-config --makefiles)/Makefile.sim
