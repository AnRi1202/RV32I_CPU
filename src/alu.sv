import risc_v_32_i_pkg::*;


module alu #(paramter XLEN = 32, parameter REG_ADDR_WIDTH=5) (
  input logic [XLEN-1:0] alu_port_a_i,
  input logic [XLEN-1:0] alu_port_b_i,
  input op_t alu_op_i,
  output logic [XLEN-1:0] alu_o
  );
  
  always_comb begin
    unique case (alu_op_i) 
      OP_ADD: alu_o = alu_port_a_i + alu_port_b_i;
      OP_SUB: alu_o = alu_port_a_i - alu_port_b_i;
      OP_AND: alu_o = alu_port_a_i & alu_port_b_i;
      OP_OR : alu_o = alu_port_a_i | alu_port_b_i;
      OP_XOR: alu_o = alu_port_a_i ^ alu_port_b_i;
      OP_SLL: alu_o = alu_port_a_i << alu_port_b_i[REG_ADDR_WIDTH-1:0];
      OP_SRL: alu_o = alu_port_a_i >> alu_port_b_i[REG_ADDR_WIDTH-1:0];
      OP_SRA: alu_o = $signed(alu_port_a_i) >>> alu_port_b_i[REG_ADDR_WIDTH-1:0];
      OP_NONE: alu_o = {XLEN{1'b0}};
    endcase
  end
endmodule
