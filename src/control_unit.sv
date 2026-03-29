import risc_v_32_i_pkg::*;

module control_unit #(
  parameter int XLEN = 32
) (
  input opcode_t op_code_i,
  input logic [2:0] funct3_i,
  output logic reg_we_o,
  output reg_data_sel_t reg_data_sel_o,
  output logic alu_port_a_sel_o,
  output logic alu_port_b_sel_o,
  output logic comp_port_b_sel_o
);
  always_comb begin
    alu_port_a_sel_o = 1'b0;
    alu_port_b_sel_o = 1'b0;
    comp_port_b_sel_o = 1'b0;
    //reg_we
    unique case (op_code_i)
      OP_R_TYPE, OP_I_ALU_TYPE: reg_we_o = 1'b1;
      default: reg_we_o = 1'b0;
    endcase
    //reg_data_sel
    reg_data_sel_o = RD_N_A;
    unique case (op_code_i)
      OP_R_TYPE: begin
        unique case (funct3_i)
          3'b010, 3'b011: reg_data_sel_o = RD_COMP; //SLT, SLTU
          default: reg_data_sel_o = RD_ALU;
        endcase
      end
      OP_I_ALU_TYPE: begin
        unique case (funct3_i)
          3'b010, 3'b011: reg_data_sel_o = RD_COMP; //SLTI, SLTIU
          default: reg_data_sel_o = RD_ALU;
        endcase
      end
      OP_I_LOAD_TYPE: reg_data_sel_o = RD_DMEM;
      default: reg_data_sel_o = RD_N_A;
    endcase

    unique case (op_code_i)
      OP_I_ALU_TYPE, OP_I_LOAD_TYPE, OP_S_TYPE, OP_B_TYPE: alu_port_b_sel_o = 1'b1;
      default: alu_port_b_sel_o = 1'b0;
    endcase

    unique case (op_code_i)
      OP_I_ALU_TYPE: begin
        unique case (funct3_i)
          3'b010, 3'b011: comp_port_b_sel_o = 1'b1;
          default: comp_port_b_sel_o = 1'b0;
        endcase
      end
      default: comp_port_b_sel_o = 1'b0;
    endcase
  end
endmodule
