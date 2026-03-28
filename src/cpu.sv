import risc_v_32_i_pkg::*;
module cpu #(
  parameter int XLEN=32,
  parameter int REG_ADDR_WIDTH=5
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
  load_store_type_t load_store_sel;
  logic reg_we;
  reg_data_sel_t reg_data_sel;
  logic [31:0] imm;
  // for regfile
  logic [XLEN-1:0] read_data_1, read_data_2;
  logic [XLEN-1:0] reg_data;
  // for alu
  logic [XLEN-1:0] alu_port_a;
  logic [XLEN-1:0] alu_port_b;
  op_alu_t alu_op;
  logic [XLEN-1:0] alu_output;
  // for load_store_unit
  logic [31:0] data_address;
  logic [XLEN-1:0] write_data;
  logic [XLEN-1:0] aligned_read_data;
  logic [XLEN-1:0] aligned_write_data;
  // instance

  assign instruction_address_o = pc;
  assign next_pc = pc + 32'd4;
  program_counter program_counter(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .next_pc_i(next_pc),
    .pc_o(pc)
  );

  field_extraction fe(
    .instruction_i(instruction_data_i),
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
    .alu_op_sel_o(alu_op_sel),
    .reg_we_o(reg_we),
    .load_store_sel_o(load_store_sel),
    .reg_data_sel_o(reg_data_sel),
    .imm_o(imm)
    );

    always_comb begin
      reg_data = '0;
      unique case(reg_data_sel)
        RD_ALU: reg_data = alu_output;
        RD_DMEM: reg_data = aligned_read_data;
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
    assign alu_port_a = read_data_1;
    assign alu_port_b = (alu_port_b_sel == 1'b0)
                  ? read_data_2
                  : {{(XLEN-32){1'b0}}, imm};
  alu #(
    .XLEN(XLEN)
  ) alu(
    .alu_port_a_i(alu_port_a),
    .alu_port_b_i(alu_port_b),
    .alu_op_sel_i(alu_op_sel),
    .alu_o(alu_output)
  );
  // operand gating. 32bit cast
  assign data_address = ((opcode == OP_S_TYPE) || (opcode ==OP_I_LOAD_TYPE)) ? alu_output[31:0] : 32'b0;
  assign data_address_o = data_address;
  assign write_enable_o = (opcode == OP_S_TYPE) ? 1'b1: 1'b0;
  assign write_data = (opcode == OP_S_TYPE) ? read_data_2: '0;
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

endmodule
