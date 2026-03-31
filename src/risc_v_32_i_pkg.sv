package risc_v_32_i_pkg;
parameter int IMM_TYPE_LEN = 3; // Bit width of opcode space
parameter int ALU_OP_LEN = 5; // Bit width of ALU opcode space
parameter logic [31:0] OP_NOP = 32'h00000013;
parameter int XLEN = 32;
typedef enum logic [6:0] {
  OP_R_TYPE = 7'b0110011,
  OP_B_TYPE = 7'b1100011,
  OP_S_TYPE = 7'b0100011,
  OP_I_ALU_TYPE = 7'b0010011,
  OP_I_LOAD_TYPE = 7'b0000011,
  OP_I_JALR_TYPE = 7'b1100111,
  OP_I_FENCE_TYPE = 7'b0001111,
  OP_I_ECALL_TYPE = 7'b1110011,
  OP_U_LUI_TYPE = 7'b0110111,
  OP_U_AUIPC_TYPE = 7'b0010111,
  OP_J_TYPE = 7'b1101111
} opcode_t;

typedef enum logic [ALU_OP_LEN-1:0]{
  OP_ADD,
  OP_SUB,
  OP_XOR,
  OP_OR,
  OP_AND,
  OP_SLL,
  OP_SRL,
  OP_SRA,
  // store
  OP_NONE
  } op_alu_t;

typedef enum logic [3:0]{
  L_B,
  L_H,
  L_W,
  L_BU,
  L_HU,
  S_B,
  S_H,
  S_W,
  LS_N_A // none
} load_store_type_t;

typedef enum logic [2:0]{
  RD_ALU,
  RD_DMEM,
  RD_COMP,
  RD_PC_N,
  RD_IMM, //OP_LUI
  RD_N_A
  } reg_data_sel_t;

typedef enum logic [4:0] {
  OP_BEQ,
  OP_BNE,
  OP_BLT,
  OP_BGE,
  OP_BLTU,
  OP_BGEU,
  OP_SLT,
  OP_SLTU,
  OP_BUNKNOWN
  } comp_sel_t;


  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
  }if_id_reg_t;

  typedef struct packed {
    logic [4:0] rd;
    logic reg_we;
    logic br_taken;
    logic [31:0] br_addr;
    logic [XLEN-1:0] reg_data;
  } ex_wb_reg_t;

endpackage
