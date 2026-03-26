import risc_v_32_i_pkg::*;


module decoder(
  input opcode_t op_code_i,
  input logic [2:0] funct3_i,
  input logic [6:0] funct7_i,
  input logic [24:0] imm_fields_i,
  output logic alu_port_a_sel_o, //rs1 or pc
  output logic alu_port_b_sel_o, //rs2 or imm
  output op_alu_t alu_op_sel_o,
  output logic reg_we_o,
  // output op_branch_t branch_op_sel_o
  // output logic [2:0] is_load,
  // output logic [1:0] is_store
  output logic [31:0] imm_o
);
  logic funct7_bit5;
  assign funct7_bit5 = funct7_i[5];
  // alu_op_sel_o and branch_op_sel_o
  always_comb begin
    //default value
    alu_op_sel_o = OP_NONE;
    alu_port_a_sel_o =1'b0;
    alu_port_b_sel_o =1'b0;
    reg_we_o = 1'b0;
    unique case(op_code_i)
      OP_R_TYPE: begin
        unique case({funct7_bit5,funct3_i})
          4'b0000: alu_op_sel_o = OP_ADD;
          4'b1000: alu_op_sel_o = OP_SUB;
          4'b0001: alu_op_sel_o = OP_SLL;
          4'b0010: alu_op_sel_o = OP_SLT;
          4'b0011: alu_op_sel_o = OP_SLTU;
          4'b0100: alu_op_sel_o = OP_XOR;
          4'b0101: alu_op_sel_o = OP_SRL;
          4'b1101: alu_op_sel_o = OP_SRA;
          4'b0110: alu_op_sel_o = OP_OR;
          4'b0111: alu_op_sel_o = OP_AND;
          default: alu_op_sel_o = OP_NONE;
        endcase
      end
      OP_I_ALU_TYPE: begin
        alu_port_b_sel_o = 1'b1;
        unique case({funct7_bit5,funct3_i})
          4'b0000: alu_op_sel_o = OP_ADDI;
          4'b0001: alu_op_sel_o = OP_SLLI;
          4'b0010: alu_op_sel_o = OP_SLTI;
          4'b0011: alu_op_sel_o = OP_SLTIU;
          4'b0100: alu_op_sel_o = OP_XORI;
          4'b0101: alu_op_sel_o = OP_SRLI;
          4'b1101: alu_op_sel_o = OP_SRAI;
          4'b0110: alu_op_sel_o = OP_ORI;
          4'b0111: alu_op_sel_o = OP_ANDI;
          default: alu_op_sel_o = OP_NONE;
        endcase
      end
      // OP_I_LOAD_TYPE: begin
        // unique case(funct3_i)
        //   3'b000: is_load = OP_LB;
        // endcase
      // end
      default: $error("can't handle this operation rn"); // WIP
    endcase
    //reg_we
    unique case(op_code_i)
      OP_R_TYPE, OP_I_ALU_TYPE: reg_we_o = 1'b1;
      default: reg_we_o = 1'b0;
    endcase

    //imm
    unique case(op_code_i)
      OP_I_ALU_TYPE: imm_o = $signed({7'b0,imm_fields_i});
      default: imm_o = 32'b0;
    endcase
  end
endmodule
