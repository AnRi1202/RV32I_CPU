import risc_v_32_i_pkg::*;


module comparator #(parameter int XLEN= 32)(
    input logic [XLEN-1:0] op_port_a_i,
    input logic [XLEN-1:0] op_port_b_i,
    input op_alu_t comp_op_i,
    output logic comp_o
  );


  always_comb begin
    unique case(comp_op_i)
      OP_BEQ : comp_o = op_port_a_i === op_port_b_i;
      OP_BNE : comp_o = op_port_a_i !== op_port_b_i;
      OP_BLTU: comp_o = op_port_a_i < op_port_b_i;
      OP_BGEU: comp_o = op_port_a_i >= op_port_b_i;
      OP_BLT : comp_o = $signed(op_port_a_i) < $signed(op_port_b_i);
      OP_BGE : comp_o = $signed(op_port_a_i) >= $signed(op_port_b_i);
      default : comp_o = 1'b0;
    endcase
  end

endmodule
