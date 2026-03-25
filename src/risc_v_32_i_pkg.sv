package risc_v_32_i_pkg;
parameter int IMM_TYPE_LEN = 3; // Bit width of opcode space
parameter int ALU_OP_LEN = 5; // Bit width of ALU opcode space
typedef enum logic [6:0] {
  OP_R_TYPE = 7'b0110011,
  OP_B_TYPE = 7'b1100011,
  OP_S_TYPE = 7'b0100011,
  OP_I_JALR_TYPE = 7'b1100111,
  OP_I_LOAD_TYPE = 7'b0000011,
  OP_I_ALU_TYPE = 7'b0010011,
  OP_I_FENCE_TYPE = 7'b0001111,
  OP_I_ECALL_TYPE = 7'b1110011,
  OP_I_LUI_TYPE = 7'b0110111,
  OP_I_AUIPC_TYPE = 7'b0010111,
  OP_J_TYPE = 7'b1101111
} opcode_t;

typedef enum logic [ALU_OP_LEN-1:0]{
  // OP_LUI,
  // OP_AUIPC,
  // OP_ADDI,
  // OP_ANDI,
  // OP_ORI,
  // OP_XORI,
  OP_ADD,
  // OP_SLLI,
  // OP_SRAI,
  OP_SUB,
  OP_AND,
  OP_OR,
  OP_XOR,
  OP_SLL,
  OP_SRL,
  OP_SRA,
  //OP_FENCE,
  // OP_SLTI,
  // OP_SLTIU
  // OP_SLLI,
  // OP_SRLI,
  // OP_SRAI,
  // OP_SLT,
  // OP_SLTU
  //
  OP_BEQ,
  OP_BNE,
  OP_BLTU,
  OP_BGEU,
  OP_BLT,
  OP_BGE,

  OP_NONE
  } op_alu_t;
endpackage

