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
  logic [31:0] next_pc;
  logic [31:0] pc;

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
  logic reg_we_id;
  reg_data_sel_t reg_data_sel_id;
  logic alu_port_a_sel_id;
  logic alu_port_b_sel_id;
  logic comp_port_b_sel_id;
  logic is_store_id, is_load_id;
  next_pc_sel_t next_pc_sel_id;
  // for decoder
  op_alu_t alu_op_sel_id;
  load_store_type_t load_store_sel_id;
  comp_sel_t comp_op_sel_id;
  logic [31:0] imm;
  // for regfile
  logic [XLEN-1:0] read_data_1, read_data_2;
  logic [XLEN-1:0] reg_data;
  id_ex_reg_t id_ex_reg;
  /* Execute */
  logic [XLEN-1:0] fwd_read_data_1;
  logic [XLEN-1:0] fwd_read_data_2;
  logic reg_we_ex;
  reg_data_sel_t reg_data_sel_ex;
  logic alu_port_a_sel_ex;
  logic alu_port_b_sel_ex;
  logic comp_port_b_sel_ex;
  next_pc_sel_t next_pc_sel_ex;
  load_store_type_t load_store_sel_ex;
  logic is_load_ex;
  logic uses_rs1, uses_rs2;
  logic stall_id;
  // for comparator
  logic [XLEN-1:0] comp_port_a;
  logic [XLEN-1:0] comp_port_b;
  logic comp;
  // for alu
  logic [XLEN-1:0] alu_port_a;
  logic [XLEN-1:0] alu_port_b;
  logic [XLEN-1:0] alu_output;

  // for next pc
  logic pc_redirect_ex;
  logic [31:0] target_pc_ex;
  reg_data_sel_t reg_data_sel_mem;
  /* Memory */
  ex_mem_reg_t ex_mem_reg;
  logic is_store_mem, is_load_mem;
  load_store_type_t load_store_sel_mem;
  logic reg_we_mem;
  // for load_store_unit
  logic [31:0] data_address;
  logic [XLEN-1:0] write_data;
  logic [XLEN-1:0] aligned_read_data;

  /* Write Back */
  mem_wb_reg_t mem_wb_reg;
  reg_data_sel_t reg_data_sel_wb;
  logic reg_we_wb;
  //////////////////////////////////
  //           Logic              //
  //////////////////////////////////


  /* Instruction Fetch */ 
  assign next_pc = pc_redirect_ex ? target_pc_ex : pc + 32'd4;
  program_counter program_counter(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .next_pc_i(next_pc),
    .enable_i(!stall_id),
    .pc_o(pc)
  );
  // access imem
  assign instruction_address_o = pc;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i || pc_redirect_ex || stall_id) begin
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
    .reg_we_o(reg_we_id),
    .reg_data_sel_o(reg_data_sel_id),
    .uses_rs1_o(uses_rs1),
    .uses_rs2_o(uses_rs2),
    .alu_port_a_sel_o(alu_port_a_sel_id),
    .alu_port_b_sel_o(alu_port_b_sel_id),
    .comp_port_b_sel_o(comp_port_b_sel_id),
    .is_store_o(is_store_id),
    .is_load_o(is_load_id),
    .next_pc_sel_o(next_pc_sel_id)
    );

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || stall_id ) begin
      reg_we_ex <= '0;
      reg_data_sel_ex <= RD_N_A;
      alu_port_a_sel_ex <= '0;
      alu_port_b_sel_ex <= '0;
      comp_port_b_sel_ex <= '0;
      next_pc_sel_ex <= PC_NEXT;
      load_store_sel_ex <= LS_N_A;
      is_load_ex <= '0;
    end else begin
      reg_we_ex <= reg_we_id;
      reg_data_sel_ex <= reg_data_sel_id;
      alu_port_a_sel_ex <= alu_port_a_sel_id;
      alu_port_b_sel_ex <= alu_port_b_sel_id;
      comp_port_b_sel_ex <= comp_port_b_sel_id;
      next_pc_sel_ex <= next_pc_sel_id;
      load_store_sel_ex <= load_store_sel_id;
      is_load_ex <= is_load_id;
    end
  end

  decoder dec(
    .op_code_i(opcode),
    .funct3_i(funct3),
    .funct7_i(funct7),
    .imm_fields_i(imm_fileds),
    .alu_op_sel_o(alu_op_sel_id),
    .load_store_sel_o(load_store_sel_id),
    .comp_op_sel_o(comp_op_sel_id),
    .imm_o(imm)
    );

  assign stall_id =
  is_load_ex &&
  (id_ex_reg.rd != 5'd0) &&
  ((uses_rs1 && (id_ex_reg.rd == rs1)) ||
    uses_rs2 && (id_ex_reg.rd == rs2));
  regfile #(
      .XLEN(XLEN),
      .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    )
  rf(
      .clk_i(clk_i),
      .reg_we_i(reg_we_wb),
      .reg_data_i(reg_data),
      .write_address_i(mem_wb_reg.rd),
      .read_address_1_i(rs1),
      .read_address_2_i(rs2),
      .read_data_1_o(read_data_1),
      .read_data_2_o(read_data_2)
    );

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i || stall_id) begin
        id_ex_reg.pc <= '0;
        id_ex_reg.read_data_1 <= '0;
        id_ex_reg.read_data_2 <= '0;
        id_ex_reg.rd <= '0;
        id_ex_reg.rs1 <= '0;
        id_ex_reg.rs2 <= '0;
        id_ex_reg.imm <= '0;
        id_ex_reg.alu_op_sel <= OP_NONE;
        id_ex_reg.comp_op_sel <= OP_BUNKNOWN;
      end else begin
        id_ex_reg.pc <= if_id_reg.pc;
        id_ex_reg.read_data_1 <= read_data_1;
        id_ex_reg.read_data_2 <= read_data_2;
        id_ex_reg.rd <= rd;
        id_ex_reg.rs1 <= rs1;
        id_ex_reg.rs2 <= rs2;
        id_ex_reg.imm <= imm;
        id_ex_reg.alu_op_sel <= alu_op_sel_id;
        id_ex_reg.comp_op_sel <= comp_op_sel_id;
      end
    end

    /* Execute Stage */ 
    // forwarding
    always_comb begin
      fwd_read_data_1 = id_ex_reg.read_data_1;
      fwd_read_data_2 = id_ex_reg.read_data_2;

      if (reg_we_mem && (ex_mem_reg.rd != '0) && (ex_mem_reg.rd == id_ex_reg.rs1)) begin
        fwd_read_data_1 = ex_mem_reg.alu_output;
      end else if (reg_we_wb && (mem_wb_reg.rd != '0) && (mem_wb_reg.rd == id_ex_reg.rs1)) begin
        fwd_read_data_1 = reg_data;
      end

      if (reg_we_mem && (ex_mem_reg.rd != '0) && (ex_mem_reg.rd == id_ex_reg.rs2)) begin
        fwd_read_data_2 = ex_mem_reg.alu_output;
      end else if (reg_we_wb && (mem_wb_reg.rd != '0) && (mem_wb_reg.rd == id_ex_reg.rs2)) begin
        fwd_read_data_2 = reg_data;
      end
    end

    // alu inputs
    assign alu_port_a = (alu_port_a_sel_ex == 1'b0)
                  ? fwd_read_data_1
                  : id_ex_reg.pc;
    assign alu_port_b = (alu_port_b_sel_ex == 1'b0)
                  ? fwd_read_data_2
                  : {{(XLEN-32){1'b0}}, id_ex_reg.imm};
    assign comp_port_a = fwd_read_data_1;
    assign comp_port_b = (comp_port_b_sel_ex == 1'b0)
                  ? fwd_read_data_2
                  : {{(XLEN-32){1'b0}}, id_ex_reg.imm};
    // when alu use imm, comp use rs2, and vice versa
  comparator #(
    .XLEN(XLEN)
    )comparator(
      .comp_port_a_i(comp_port_a),
      .comp_port_b_i(comp_port_b),
      .comp_op_sel_i(id_ex_reg.comp_op_sel),
      .comp_o(comp)
      );
  alu #(
    .XLEN(XLEN)
  ) alu(
    .alu_port_a_i(alu_port_a),
    .alu_port_b_i(alu_port_b),
    .alu_op_sel_i(id_ex_reg.alu_op_sel),
    .alu_o(alu_output)
  );

  always_comb begin
    pc_redirect_ex = 1'b0;
    target_pc_ex = '0;
    unique case (next_pc_sel_ex)
      PC_NEXT: begin
        pc_redirect_ex = 1'b0;
      end
      PC_BRANCH: begin
        pc_redirect_ex = comp;
        target_pc_ex = alu_output;
      end
      PC_JUMPR: begin
        pc_redirect_ex = 1'b1;
        target_pc_ex = alu_output & ~32'h1;
      end
      default : begin
        pc_redirect_ex = 1'b1;
        target_pc_ex = alu_output;
      end
    endcase
  end


  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || stall_id) begin
      ex_mem_reg.alu_output <= '0;
      ex_mem_reg.read_data_2 <= '0;
      ex_mem_reg.pc <= '0;
      ex_mem_reg.imm <= '0;
      ex_mem_reg.rd <= '0;
      ex_mem_reg.comp <= 1'b0;

      is_store_mem <= 1'b0;
      is_load_mem <= 1'b0;
      load_store_sel_mem <= LS_N_A;
      reg_data_sel_mem <= RD_N_A;
      reg_we_mem <= '0;
    end else begin
      ex_mem_reg.alu_output <= alu_output;
      ex_mem_reg.read_data_2 <= fwd_read_data_2;
      ex_mem_reg.pc <= id_ex_reg.pc;
      ex_mem_reg.imm <= id_ex_reg.imm;
      ex_mem_reg.rd <= id_ex_reg.rd;
      ex_mem_reg.comp <= comp;

      load_store_sel_mem <= load_store_sel_ex;
      reg_data_sel_mem <= reg_data_sel_ex;
      reg_we_mem <= reg_we_ex;
    end
  end
  /* Memory */
  // operand gating. 32bit cast
  always_comb begin
    is_load_mem = 1'b0;
    is_store_mem = 1'b0;
    unique case(load_store_sel_mem)
      L_B, L_H, L_W, L_BU, L_HU: is_load_mem = 1'b1;
      S_B, S_H, S_W : is_store_mem = 1'b1;
      default : is_store_mem =1'b0;
    endcase
  end
  assign data_address = (is_store_mem || is_load_mem) ? ex_mem_reg.alu_output[31:0] : 32'b0;
  assign data_address_o = data_address;
  assign write_enable_o = (is_store_mem) ? 1'b1: 1'b0;
  assign write_data = (is_store_mem) ? ex_mem_reg.read_data_2: '0;
  load_store_unit #(
    .XLEN(XLEN)
    ) lsu(
    .load_store_sel_i(load_store_sel_mem),

    .data_address_i(data_address),
    .write_data_i(write_data),
    .aligned_write_data_o(write_data_o),
    .write_strobe_o(write_strobe_o),
    .read_data_i(read_data_i),
    .aligned_read_data_o(aligned_read_data)
    );

    always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || stall_id) begin
      mem_wb_reg.alu_output <= '0;
      mem_wb_reg.dmem_data <= '0;
      mem_wb_reg.comp <= 1'b0;
      mem_wb_reg.pc <= '0;
      mem_wb_reg.imm <= '0;
      mem_wb_reg.rd <= '0;
      reg_data_sel_wb <= RD_N_A;
      reg_we_wb <= '0;

    end else begin
      mem_wb_reg.alu_output <= ex_mem_reg.alu_output;
      mem_wb_reg.dmem_data <= aligned_read_data;
      mem_wb_reg.comp <= ex_mem_reg.comp;
      mem_wb_reg.pc <= ex_mem_reg.pc;
      mem_wb_reg.imm <= ex_mem_reg.imm;
      mem_wb_reg.rd <= ex_mem_reg.rd;
      reg_data_sel_wb <= reg_data_sel_mem;
      reg_we_wb <= reg_we_mem;
    end
  end  

    /* Write Back Stage*/
    always_comb begin
      reg_data = '0;
      unique case(reg_data_sel_wb)
        RD_ALU: reg_data = mem_wb_reg.alu_output;
        RD_DMEM: reg_data = mem_wb_reg.dmem_data;
        RD_COMP: reg_data = {{(XLEN-1){1'b0}}, mem_wb_reg.comp};
        RD_PC4: reg_data = mem_wb_reg.pc+ 32'd4;
        RD_PCI: reg_data = mem_wb_reg.pc + mem_wb_reg.imm;  
        RD_IMM : reg_data = mem_wb_reg.imm;
        default: reg_data = '0;
      endcase
    end
endmodule
