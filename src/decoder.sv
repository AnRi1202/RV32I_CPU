import risc_v_32_i_pkg::*;


module decoder(
  input opcode_t op_code_i,
  input logic [2:0] funct3_i,
  input logic [6:0] funct7_i,
  input logic [31:7] imm_fields_i,
  output op_alu_t alu_op_sel_o,
  output load_store_type_t load_store_sel_o,
  output comp_sel_t comp_op_sel_o,
  // output op_branch_t branch_op_sel_o
  output logic [31:0] imm_o
);
  logic funct7_bit5;
  assign funct7_bit5 = funct7_i[5];
  // alu_op_sel_o and branch_op_sel_o
  always_comb begin
    //default value
    alu_op_sel_o = OP_NONE;
    case(op_code_i)
      OP_R_TYPE: begin
        unique case({funct7_bit5,funct3_i})
          4'b0000: alu_op_sel_o = OP_ADD;
          4'b1000: alu_op_sel_o = OP_SUB;
          4'b0001: alu_op_sel_o = OP_SLL;
          4'b0100: alu_op_sel_o = OP_XOR;
          4'b0101: alu_op_sel_o = OP_SRL;
          4'b1101: alu_op_sel_o = OP_SRA;
          4'b0110: alu_op_sel_o = OP_OR;
          4'b0111: alu_op_sel_o = OP_AND;
          default: alu_op_sel_o = OP_NONE;
        endcase
      end
      OP_I_ALU_TYPE: begin
        unique case(funct3_i)
          3'b000: alu_op_sel_o = OP_ADD;
          3'b001: alu_op_sel_o = OP_SLL;
          3'b100: alu_op_sel_o = OP_XOR;
          3'b101: begin
            if (funct7_bit5) alu_op_sel_o = OP_SRA;
            else alu_op_sel_o = OP_SRL;
          end
          3'b110: alu_op_sel_o = OP_OR;
          3'b111: alu_op_sel_o = OP_AND;
          default: alu_op_sel_o = OP_NONE;
        endcase
      end
      OP_S_TYPE, OP_I_LOAD_TYPE, OP_B_TYPE, OP_J_TYPE, OP_I_JALR_TYPE, OP_U_AUIPC_TYPE: begin
        alu_op_sel_o = OP_ADD;
      end
      default: alu_op_sel_o = OP_NONE;
    endcase

    // load_store_sel
    load_store_sel_o = LS_N_A;
    unique0 case(op_code_i)
    OP_I_LOAD_TYPE: begin
      unique0 case(funct3_i)
        3'b000: load_store_sel_o = L_B;
        3'b001: load_store_sel_o = L_H;
        3'b010: load_store_sel_o = L_W;
        3'b100: load_store_sel_o = L_BU;
        3'b101: load_store_sel_o = L_HU;
        default: load_store_sel_o = LS_N_A;
      endcase
    end
    OP_S_TYPE: begin
      unique0 case(funct3_i)
        3'b000: load_store_sel_o = S_B;
        3'b001: load_store_sel_o = S_H;
        3'b010: load_store_sel_o = S_W;
        default: load_store_sel_o = LS_N_A;
      endcase
    end
    default: load_store_sel_o = LS_N_A;
    endcase
    // compare_sel
    case(op_code_i)
      OP_R_TYPE, OP_I_ALU_TYPE:
        case (funct3_i)
          3'b010: comp_op_sel_o =OP_SLT;
          3'b011: comp_op_sel_o =OP_SLTU;
          default: comp_op_sel_o =OP_BUNKNOWN;
        endcase
      OP_B_TYPE:
        case(funct3_i)
          3'b000: comp_op_sel_o = OP_BEQ;
          3'b001: comp_op_sel_o = OP_BNE;
          3'b100: comp_op_sel_o = OP_BLT;
          3'b101: comp_op_sel_o = OP_BGE;
          3'b110: comp_op_sel_o = OP_BLTU;
          3'b111: comp_op_sel_o = OP_BGEU;
          default: comp_op_sel_o =OP_BUNKNOWN;
        endcase
      default: comp_op_sel_o = OP_BUNKNOWN;
    endcase

    //imm
    imm_o = 32'b0;
    unique case(op_code_i)
      OP_I_ALU_TYPE, OP_I_LOAD_TYPE, OP_I_JALR_TYPE: begin
        imm_o = {{20{imm_fields_i[31]}},imm_fields_i[31:20]};
      end
      OP_S_TYPE: imm_o = {{20{imm_fields_i[31]}},imm_fields_i[31:25],imm_fields_i[11:7]};
      OP_B_TYPE: imm_o = {{19{imm_fields_i[31]}},
                          imm_fields_i[31],
                          imm_fields_i[7],
                          imm_fields_i[30:25],
                          imm_fields_i[11:8],1'b0};
      OP_U_AUIPC_TYPE, OP_U_LUI_TYPE: imm_o = {imm_fields_i[31:12], 12'b0};
      OP_J_TYPE: imm_o = {11'b0, imm_fields_i[31], imm_fields_i[19:12], imm_fields_i[20], imm_fields_i[30:21], 1'b0};
      default: imm_o = 32'b0;

    endcase
  end
endmodule
