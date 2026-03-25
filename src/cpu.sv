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
  logic [31:0] instruction_address;
  logic [31:0] instruction_data;
  // for field extraction
  logic [6:0] opcode;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:7] imm_fileds;
  // for dmem
  logic write_enable;
  logic [XLEN-1:0] read_data;
  // for alu
  logic [XLEN-1:0] alu_port_a;
  logic [XLEN-1:0] alu_port_b;
  logic alu_op;
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
    .instruction_address_i(instruction_address),
    .instruction_data_o(instruction_data)
  );

  field_extraction fe(
    .instruction_i(instruction_data),
    .opcode_o(opcode),
    .rd_o(rd),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .funct3_o(funct3),
    .funct7_o(funct7),
    .imm_fileds_o(imm_fileds)
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

  alu #(
    .XLEN(XLEN),
    .REG_ADDR_WIDTH(5)
  ) alu(
    .alu_port_a_i(alu_port_a),
    .alu_port_b_i(alu_port_b),
    .alu_op_i(alu_op),
    .alu_o(alu_output)
  );
endmodule
