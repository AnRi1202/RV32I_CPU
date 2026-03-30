import risc_v_32_i_pkg::*;
module cpu #(
  parameter int XLEN=32,
  parameter int REG_ADDR_WIDTH=2
) (
  input logic clk_i, rst_n_i,
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
  /* Instruction Fetch */
  // for program_counter
  logic next_pc_sel;
  logic [31:0] next_pc;
  logic [31:0] pc;
  // for imem
  logic [31:0] instruction_data;

  if_id_reg_t if_id_reg;
  /* Instruction Decode*/
  // for field extraction
  opcode_t opcode;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:7] imm_fileds;
  // for control_unit
  logic reg_we;
  reg_data_sel_t reg_data_sel;
  // for decoder
  logic alu_port_a_sel;
  logic alu_port_b_sel;
  logic comp_port_b_sel;
  op_alu_t alu_op_sel;
  load_store_type_t load_store_sel;
  comp_sel_t comp_op_sel;
  logic is_store, is_load;
  logic [31:0] imm;
  // for regfile
  logic [XLEN-1:0] read_data_1, read_data_2;
  logic [XLEN-1:0] reg_data;
  id_ex_reg_t id_ex_reg;
  /* Execute */
  // for comparator
  logic [XLEN-1:0] comp_port_a;
  logic [XLEN-1:0] comp_port_b;
  logic comp;
  // for alu
  logic [XLEN-1:0] alu_port_a;
  logic [XLEN-1:0] alu_port_b;
  op_alu_t alu_op;
  logic [XLEN-1:0] alu_output;
  /* Memory */
  // for load_store_unit
  logic [31:0] data_address;
  logic [XLEN-1:0] write_data;
  logic [XLEN-1:0] aligned_read_data;
  // instance

  //////////////////////////////////
  //           Logic              //
  //////////////////////////////////


  /* Instruction Fetch */ 
  assign next_pc = next_pc_sel ? (alu_output & ~32'h1) : pc + 32'd4;
  program_counter program_counter(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .next_pc_i(next_pc),
    .pc_o(pc)
  );
  // access imem
  assign instruction_address_o = pc;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i || next_pc_sel) begin
        if_id_reg.pc<= 32'b0;
        if_id_reg.instr<= OP_NOP;
      end else begin
        if_id_reg.pc<= pc;
        if_id_reg.instr<= instruction_data_i;
      end
    end
  /* Instruction Decode */
  field_extraction fe(
    .instruction_i(if_id_reg.instr),
    .opcode_o(opcode),
    .rd_o(rd),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .funct3_o(funct3),
    .funct7_o(funct7),
    .imm_fileds_o(imm_fileds)
    );

  control_unit cu(
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
    .next_pc_sel_o(next_pc_sel)
    );

  decoder dec(
    .op_code_i(opcode),
    .funct3_i(funct3),
    .funct7_i(funct7),
    .imm_fields_i(imm_fileds),
    .alu_op_sel_o(alu_op_sel),
    .load_store_sel_o(load_store_sel),
    .comp_op_sel_o(comp_op_sel),
    .imm_o(imm)
    );

    always_comb begin
      reg_data = '0;
      unique case(reg_data_sel)
        RD_ALU: reg_data = alu_output;
        RD_DMEM: reg_data = aligned_read_data;
        RD_COMP: reg_data = {{(XLEN-1){1'b0}}, comp};
        RD_PC_N: reg_data = (opcode == OP_U_AUIPC_TYPE) ? if_id_reg.pc+ imm : if_id_reg.pc+ 32'd4;
        RD_IMM : reg_data = imm;
        default: reg_data = '0;
      endcase
    end

  regfile #(
      .XLEN(XLEN),
      .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    )
  rf(
      .clk_i(clk_i),
      .reg_we_i(reg_we),
      .reg_data_i(reg_data),
      .write_address_i(rd),
      .read_address_1_i(rs1),
      .read_address_2_i(rs2),
      .read_data_1_o(read_data_1),
      .read_data_2_o(read_data_2)
    );

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i) begin
        id_ex_reg.read_data_1 <= '0;
        id_ex_reg.read_data_2 <= '0;
        id_ex_reg.opcode <= '0;
      end else begin
        id_ex_reg.read_data_1 <= read_data_1;
        id_ex_reg.read_data_2 <= read_data_2;
        id_ex_reg.opcode <= opcode;
      end
    end
    /* Execute Stage */ 
    assign alu_port_a = (alu_port_a_sel == 1'b0)
                  ? id_ex_reg.read_data_1
                  : if_id_reg.pc;
    assign alu_port_b = (alu_port_b_sel == 1'b0)
                  ? if_id_reg.read_data_2
                  : {{(XLEN-32){1'b0}}, imm};
    assign comp_port_a = if_id_reg.read_data_1;
    assign comp_port_b = (comp_port_b_sel == 1'b0)
                  ? if_id_reg.read_data_2
                  : {{(XLEN-32){1'b0}}, imm};
    // when alu use imm, comp use rs2, and vice versa
  comparator #(
    .XLEN(XLEN)
    )comparator(
      .comp_port_a_i(comp_port_a),
      .comp_port_b_i(comp_port_b),
      .comp_op_sel_i(comp_op_sel),
      .comp_o(comp)
      );
  alu #(
    .XLEN(XLEN)
  ) alu(
    .alu_port_a_i(alu_port_a),
    .alu_port_b_i(alu_port_b),
    .alu_op_sel_i(alu_op_sel),
    .alu_o(alu_output)
  );
  /* Memory */
  // operand gating. 32bit cast
  assign data_address = (is_store || is_load) ? alu_output[31:0] : 32'b0;
  assign data_address_o = data_address;
  assign write_enable_o = (is_store) ? 1'b1: 1'b0;
  assign write_data = (is_store) ? if_id_reg.read_data_2: '0;
  load_store_unit #(
    .XLEN(XLEN)
    ) lsu(
    .load_store_sel_i(load_store_sel),
    .read_data_i(read_data_i),
    .aligned_read_data_o(aligned_read_data),
    .data_address_i(data_address),
    .write_data_i(write_data),
    .aligned_write_data_o(write_data_o),
    .write_strobe_o(write_strobe_o)
    );

    /* Write Back Stage*/
endmodule
