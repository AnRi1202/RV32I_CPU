module field_extraction(
  input logic [31:0] instruction_i,
  output logic [6:0] opcode_o,
  output logic [4:0] rd_o,
  output logic [4:0] rs1_o,
  output logic [4:0] rs2_o,
  output logic [2:0] funct3_o,
  output logic [6:0] funct7_o,
  output logic [31:7] imm_fileds_o
);
  assign opcode_o = instruction_i[6:0];
  assign rd_o     = instruction_i[11:7];
  assign rs1_o    = instruction_i[19:15];
  assign rs2_o    = instruction_i[24:20];
  assign funct3_o = instruction_i[14:12];
  assign funct7_o = instruction_i[31:25];
  assign imm_fileds_o = instruction_i[31:7];
endmodule
