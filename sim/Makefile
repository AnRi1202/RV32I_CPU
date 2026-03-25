TOPLEVEL_LANG = verilog
SIM = icarus # Change your simlator

VERILOG_SOURCES = ../src/risc_v_32_i_pkg.sv \
									../src/program_counter.sv \
									../src/cpu.sv \
									../src/instruction_memory.sv \
									../src/field_extraction.sv \
									../src/data_memory.sv \
									../src/alu.sv

TOPLEVEL = cpu
COCOTB_TEST_MODULES = tb_cpu

export PYTHONPATH := ../tb

IMEM_FILE ?= ../tb/hex/r_test.txt
DMEM_FILE ?=


COMPILE_ARGS += -g2012
COMPILE_ARGS += -Pcpu.IMEM_FILE=\"$(IMEM_FILE)\"
COMPILE_ARGS += -Pcpu.DMEM_FILE=\"$(DMEM_FILE)\"

include $(shell cocotb-config --makefiles)/Makefile.sim
