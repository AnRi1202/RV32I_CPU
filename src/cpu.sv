import risc_v_32_i_pkg::*;

module cpu #(
  parameter int XLEN = 32,
  parameter int REG_ADDR_WIDTH = 2
) (
  input logic clk_i,
  input logic rst_n_i,
  // dmem
  input logic [XLEN-1:0] read_data_i,
  output logic [XLEN-1:0] write_data_o,
  output logic [31:0] data_address_o,
  output logic write_enable_o,
  output logic [3:0] write_strobe_o,
  // imem
  input logic [31:0] instruction_data_i,
  output logic [31:0] instruction_address_o
);
  /* Fetch / PC */
  logic [31:0] next_pc;
  logic [31:0] pc;

  /* Decode / EX */
  opcode_t opcode;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:7] imm_fileds;

  logic reg_we;
  reg_data_sel_t reg_data_sel;
  logic alu_port_a_sel;
  logic alu_port_b_sel;
  logic comp_port_b_sel;
  op_alu_t alu_op_sel;
  load_store_type_t load_store_sel;
  comp_sel_t comp_op_sel;
  logic is_store;
  logic is_load;
  logic br_taken_ex;
  logic [31:0] imm;

  logic [XLEN-1:0] read_data_1;
  logic [XLEN-1:0] read_data_2;

  logic [XLEN-1:0] comp_port_a;
  logic [XLEN-1:0] comp_port_b;
  logic comp;

  logic [XLEN-1:0] alu_port_a;
  logic [XLEN-1:0] alu_port_b;
  logic [XLEN-1:0] alu_output;

  logic [31:0] data_address;
  logic [31:0] br_addr_ex;
  logic [XLEN-1:0] aligned_read_data;
  logic [XLEN-1:0] aligned_write_data;
  logic [3:0] write_strobe;
  logic [XLEN-1:0] reg_data_ex;

  logic uses_rs1;
  logic uses_rs2;
  logic raw_hazard;
  logic stall_ex;
  logic flush_ex;

  /* WB */
  ex_wb_reg_t ex_wb_reg;

  assign instruction_address_o = pc;
  assign flush_ex = ex_wb_reg.br_taken;
  assign next_pc = flush_ex ? ex_wb_reg.br_addr : (stall_ex ? pc : (pc + 32'd4));

  program_counter program_counter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .next_pc_i(next_pc),
    .pc_o(pc)
  );

  field_extraction fe (
    .instruction_i(instruction_data_i),
    .opcode_o(opcode),
    .rd_o(rd),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .funct3_o(funct3),
    .funct7_o(funct7),
    .imm_fileds_o(imm_fileds)
  );

  control_unit cu (
    .op_code_i(opcode),
    .funct3_i(funct3),
    .comp_i(comp),
    .reg_we_o(reg_we),
    .reg_data_sel_o(reg_data_sel),
    .alu_port_a_sel_o(alu_port_a_sel),
    .alu_port_b_sel_o(alu_port_b_sel),
    .comp_port_b_sel_o(comp_port_b_sel),
    .is_store_o(is_store),
    .is_load_o(is_load),
    .next_pc_sel_o(br_taken_ex)
  );

  decoder dec (
    .op_code_i(opcode),
    .funct3_i(funct3),
    .funct7_i(funct7),
    .imm_fields_i(imm_fileds),
    .alu_op_sel_o(alu_op_sel),
    .load_store_sel_o(load_store_sel),
    .comp_op_sel_o(comp_op_sel),
    .imm_o(imm)
  );

  regfile #(
    .XLEN(XLEN),
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
  ) rf (
    .clk_i(clk_i),
    .reg_we_i(ex_wb_reg.reg_we),
    .reg_data_i(ex_wb_reg.reg_data),
    .write_address_i(ex_wb_reg.rd),
    .read_address_1_i(rs1),
    .read_address_2_i(rs2),
    .read_data_1_o(read_data_1),
    .read_data_2_o(read_data_2)
  );

  assign alu_port_a = alu_port_a_sel ? pc : read_data_1;
  assign alu_port_b = alu_port_b_sel ? imm : read_data_2;
  assign comp_port_a = read_data_1;
  assign comp_port_b = comp_port_b_sel ? imm : read_data_2;

  comparator #(
    .XLEN(XLEN)
  ) comparator (
    .comp_port_a_i(comp_port_a),
    .comp_port_b_i(comp_port_b),
    .comp_op_sel_i(comp_op_sel),
    .comp_o(comp)
  );

  alu #(
    .XLEN(XLEN)
  ) alu (
    .alu_port_a_i(alu_port_a),
    .alu_port_b_i(alu_port_b),
    .alu_op_sel_i(alu_op_sel),
    .alu_o(alu_output)
  );

  assign data_address = (is_store || is_load) ? alu_output[31:0] : 32'b0;
  assign br_addr_ex = alu_output[31:0] & ~32'h1;

  load_store_unit #(
    .XLEN(XLEN)
  ) lsu (
    .load_store_sel_i(load_store_sel),
    .read_data_i(read_data_i),
    .aligned_read_data_o(aligned_read_data),
    .data_address_i(data_address),
    .write_data_i(read_data_2),
    .aligned_write_data_o(aligned_write_data),
    .write_strobe_o(write_strobe)
  );

  always_comb begin
    uses_rs1 = 1'b0;
    uses_rs2 = 1'b0;
    unique case (opcode)
      OP_R_TYPE: begin
        uses_rs1 = 1'b1;
        uses_rs2 = 1'b1;
      end
      OP_I_ALU_TYPE, OP_I_LOAD_TYPE, OP_I_JALR_TYPE: uses_rs1 = 1'b1;
      OP_S_TYPE, OP_B_TYPE: begin
        uses_rs1 = 1'b1;
        uses_rs2 = 1'b1;
      end
      default: begin
        uses_rs1 = 1'b0;
        uses_rs2 = 1'b0;
      end
    endcase
  end

  assign raw_hazard =
    ex_wb_reg.reg_we &&
    (ex_wb_reg.rd != 5'd0) &&
    (((uses_rs1 && (rs1 == ex_wb_reg.rd))) ||
     ((uses_rs2 && (rs2 == ex_wb_reg.rd))));
  assign stall_ex = !flush_ex && raw_hazard;

  always_comb begin
    reg_data_ex = '0;
    unique case (reg_data_sel)
      RD_ALU: reg_data_ex = alu_output;
      RD_DMEM: reg_data_ex = aligned_read_data;
      RD_COMP: reg_data_ex = {{(XLEN-1){1'b0}}, comp};
      RD_PC_N: reg_data_ex = (opcode == OP_U_AUIPC_TYPE) ? (pc + imm) : (pc + 32'd4);
      RD_IMM: reg_data_ex = imm;
      default: reg_data_ex = '0;
    endcase
  end

  assign data_address_o = (!stall_ex && !flush_ex && (is_store || is_load)) ? data_address : 32'b0;
  assign write_enable_o = (!stall_ex && !flush_ex && is_store);
  assign write_data_o = (!stall_ex && !flush_ex && is_store) ? aligned_write_data : '0;
  assign write_strobe_o = (!stall_ex && !flush_ex && is_store) ? write_strobe : 4'b0000;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      ex_wb_reg <= '0;
    end else if (stall_ex || flush_ex) begin
      ex_wb_reg <= '0;
    end else begin
      ex_wb_reg.rd <= rd;
      ex_wb_reg.reg_we <= reg_we;
      ex_wb_reg.br_taken <= br_taken_ex;
      ex_wb_reg.br_addr <= br_addr_ex;
      ex_wb_reg.reg_data <= reg_data_ex;
    end
  end
endmodule
