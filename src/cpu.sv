import risc_v_32_i_pkg::*;
module cpu #(
  parameter int XLEN=32,
  parameter [8*256-1:0] IMEM_FILE="",
  parameter [8*256-1:0] DMEM_FILE=""
) (
  input logic clk_i, rst_n_i,
  input logic [XLEN-1:0] write_data_i,
  input logic [31:0] data_address_i,
  output logic write_enable_o
  );
  // for program_counter
  logic [31:0] next_pc;
  logic [31:0] pc;
  // for imem
  logic [31:0] instruction_data;
  // for field extraction
  opcode_t opcode;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:7] imm_fileds;
  // for decoder
  logic alu_port_a_sel;
  logic alu_port_b_sel;
  op_alu_t alu_op_sel;
  // for dmem
  logic write_enable;
  logic [XLEN-1:0] read_data;
  // for alu
  logic [XLEN-1:0] alu_port_a;
  logic [XLEN-1:0] alu_port_b;
  op_alu_t alu_op;
  logic [XLEN-1:0] alu_output;
  // instance

  assign next_pc = pc + 32'd4;
  program_counter program_counter(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .next_pc_i(next_pc),
    .pc_o(pc)
  );
  instruction_memory #(.INIT_FILE(IMEM_FILE)) imem(
    .instruction_address_i(pc),
    .instruction_data_o(instruction_data)
  );

  field_extraction #(.REG_ADDR_WIDTH(REG_ADDR_WIDTH))
  fe(
    .instruction_i(instruction_data),
    .opcode_o(opcode),
    .rd_o(rd),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .funct3_o(funct3),
    .funct7_o(funct7),
    .imm_fileds_o(imm_fileds)
    );
  decoder dec(
    .op_code_i(opcode),
    .funct3_i(funct3),
    .funct7_i(funct7),
    .imm_fields_i(imm_fileds),
    .alu_port_a_sel_o(alu_port_a_sel),
    .alu_port_b_sel_o(alu_port_b_sel),
    .alu_op_sel_o(alu_op_sel)
    );

  alu #(
    .XLEN(XLEN),
    .REG_ADDR_WIDTH(5)
  ) alu(
    .alu_port_a_i(alu_port_a),
    .alu_port_b_i(alu_port_b),
    .alu_op_i(alu_op),
    .alu_o(alu_output)
  );

  data_memory #(
    .XLEN(XLEN),
    .INIT_FILE(DMEM_FILE)
  ) dmem(
    .address_i(data_address_i),
    .write_data_i(write_data_i),
    .clk_i(clk_i),
    .write_enable_i(write_enable),
    .read_data_o(read_data)
    );


endmodule
